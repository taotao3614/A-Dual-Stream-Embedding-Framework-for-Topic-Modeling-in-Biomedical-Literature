"""
β document-level normalization comparison experiment (R3.1).

Compares the current per-term weighting (Formula A) against the proposed
group-level normalization (Formula B) at the optimal Dual PubMedBERT
configuration (α=0.45) across five β values: 0.20, 0.30, 0.40, 0.50, 0.60.

Formula A (current, per-term):
    weight_i = β if major else (1−β);  weights normalized across all terms.

Formula B (proposed, group-level):
    MeSH_emb = β · mean(major embeddings) + (1−β) · mean(minor embeddings)
    Degenerates to mean(major) if no minor terms exist, and vice versa.

Usage:
    python beta_normalization_experiment.py

Outputs:
    beta_comparison_results.csv    -- TC / TD / TC+TD for both formulas
    beta_comparison_results.txt    -- human-readable summary table
"""

import os, json, random
import numpy as np
import pandas as pd

from sentence_transformers import SentenceTransformer
from bertopic import BERTopic
from umap import UMAP
from hdbscan import HDBSCAN
from sklearn.feature_extraction.text import CountVectorizer
from bertopic.representation import MaximalMarginalRelevance
from bertopic.vectorizers import ClassTfidfTransformer
from octis.evaluation_metrics.coherence_metrics import Coherence
from octis.evaluation_metrics.diversity_metrics import TopicDiversity
from tqdm import tqdm

RANDOM_STATE  = 34
ALPHA_FIXED   = 0.45          # fix α at the known optimum
BETA_VALUES   = [0.20, 0.30, 0.40, 0.50, 0.60]
TEXT_MODEL    = "NeuML/pubmedbert-base-embeddings"
MESH_MODEL    = "NeuML/pubmedbert-base-embeddings"
BATCH_SIZE    = 64

np.random.seed(RANDOM_STATE)
random.seed(RANDOM_STATE)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH   = os.path.join(SCRIPT_DIR, "dual-stream", "data", "raw data.csv")


# --------------------------------------------------------------------------
# Data loading
# --------------------------------------------------------------------------
def load_data(csv_path):
    df = pd.read_csv(csv_path).dropna(subset=["abstract"])
    docs = (df["title"] + " " + df["abstract"]).values   # text stream input

    mesh_list_all = []
    for raw in df["mesh_terms"]:
        try:
            if raw and raw != "[]":
                mesh_list_all.append(json.loads(raw))
            else:
                mesh_list_all.append([])
        except Exception:
            mesh_list_all.append([])

    # For BERTopic: full text (title + abstract + MeSH strings)
    def mesh_str(terms):
        return " ".join(t["DescriptorName"] for t in terms if "DescriptorName" in t)

    full_docs = np.array([
        row["title"] + " " + row["abstract"] + " " + mesh_str(ml)
        for (_, row), ml in zip(df.iterrows(), mesh_list_all)
    ])
    return full_docs, docs, mesh_list_all


# --------------------------------------------------------------------------
# Text embedding (unchanged between formulas)
# --------------------------------------------------------------------------
def embed_texts(texts, model_name, batch_size=BATCH_SIZE):
    print(f"  Embedding texts with {model_name} …")
    model = SentenceTransformer(model_name)
    return model.encode(texts, batch_size=batch_size, show_progress_bar=True)


# --------------------------------------------------------------------------
# MeSH embedding — Formula A (current per-term weighting)
# --------------------------------------------------------------------------
def embed_mesh_formula_a(mesh_list, beta, model, batch_size=BATCH_SIZE):
    """Original: per-term β/(1-β), then global normalize."""
    embeddings, has_mesh = [], []
    vector_dim = None

    for terms in tqdm(mesh_list, desc=f"  MeSH (Formula A, β={beta:.2f})"):
        valid = [t for t in terms if "DescriptorName" in t]
        if not valid:
            has_mesh.append(False)
            if vector_dim is None:
                vector_dim = model.encode(["dummy"]).shape[1]
            embeddings.append(np.zeros(vector_dim))
            continue

        names = [t["DescriptorName"] for t in valid]
        flags = [t.get("MajorTopicYN", "N") == "Y" for t in valid]
        embs  = model.encode(names, batch_size=batch_size)
        if vector_dim is None:
            vector_dim = embs.shape[1]

        w = np.array([beta if f else (1 - beta) for f in flags])
        w = w / w.sum()
        embeddings.append((embs * w[:, None]).sum(axis=0))
        has_mesh.append(True)

    return np.array(embeddings), np.array(has_mesh)


# --------------------------------------------------------------------------
# MeSH embedding — Formula B (proposed group-level normalization)
# --------------------------------------------------------------------------
def embed_mesh_formula_b(mesh_list, beta, model, batch_size=BATCH_SIZE):
    """Proposed: β·mean(major) + (1-β)·mean(minor)."""
    embeddings, has_mesh = [], []
    vector_dim = None

    for terms in tqdm(mesh_list, desc=f"  MeSH (Formula B, β={beta:.2f})"):
        valid = [t for t in terms if "DescriptorName" in t]
        if not valid:
            has_mesh.append(False)
            if vector_dim is None:
                vector_dim = model.encode(["dummy"]).shape[1]
            embeddings.append(np.zeros(vector_dim))
            continue

        major_names = [t["DescriptorName"] for t in valid if t.get("MajorTopicYN", "N") == "Y"]
        minor_names = [t["DescriptorName"] for t in valid if t.get("MajorTopicYN", "N") != "Y"]

        if vector_dim is None:
            probe = model.encode([valid[0]["DescriptorName"]], batch_size=1)
            vector_dim = probe.shape[1]

        def group_mean(names):
            if not names:
                return None
            return model.encode(names, batch_size=batch_size).mean(axis=0)

        major_emb = group_mean(major_names)
        minor_emb = group_mean(minor_names)

        if major_emb is not None and minor_emb is not None:
            emb = beta * major_emb + (1 - beta) * minor_emb
        elif major_emb is not None:
            emb = major_emb
        else:
            emb = minor_emb

        embeddings.append(emb)
        has_mesh.append(True)

    return np.array(embeddings), np.array(has_mesh)


# --------------------------------------------------------------------------
# α-fusion
# --------------------------------------------------------------------------
def fuse(text_embs, mesh_embs, has_mesh, alpha):
    out = np.zeros_like(text_embs)
    out[has_mesh]  = alpha * text_embs[has_mesh]  + (1 - alpha) * mesh_embs[has_mesh]
    out[~has_mesh] = text_embs[~has_mesh]
    return out


# --------------------------------------------------------------------------
# BERTopic + metrics
# --------------------------------------------------------------------------
def run_bertopic(docs, embeddings):
    tm = BERTopic(
        umap_model=UMAP(n_neighbors=15, n_components=5, min_dist=0.0,
                        metric="cosine", random_state=RANDOM_STATE),
        hdbscan_model=HDBSCAN(min_cluster_size=30, min_samples=10,
                               metric="euclidean", cluster_selection_method="eom",
                               prediction_data=True),
        vectorizer_model=CountVectorizer(stop_words="english"),
        ctfidf_model=ClassTfidfTransformer(),
        representation_model=MaximalMarginalRelevance(diversity=0.2),
        calculate_probabilities=True,
        verbose=False,
    )
    topics, _ = tm.fit_transform(docs, embeddings=embeddings)
    return tm, topics


def compute_metrics(topic_model, docs, topics):
    doc_info   = topic_model.get_document_info(docs)
    per_topic  = doc_info.groupby("Topic", as_index=False).agg({"Document": " ".join})
    cleaned    = topic_model._preprocess_text(per_topic.Document.values)
    analyzer   = topic_model.vectorizer_model.build_analyzer()
    tokens     = [analyzer(d) for d in cleaned]
    n_topics   = len(set(topics)) - 1
    topic_words = [
        [w for w, _ in topic_model.get_topic(i)[:10]]
        for i in range(n_topics)
    ]
    tc = Coherence(texts=tokens, topk=10, measure="c_v").score({"topics": topic_words})
    td = TopicDiversity().score({"topics": topic_words})
    return tc, td, n_topics


# --------------------------------------------------------------------------
def main():
    print("=== β Normalization Comparison (R3.1) ===\n")
    print(f"Text model:  {TEXT_MODEL}")
    print(f"MeSH model:  {MESH_MODEL}")
    print(f"Fixed α = {ALPHA_FIXED}")
    print(f"β values:    {BETA_VALUES}\n")

    print("Loading data …")
    full_docs, text_docs, mesh_list = load_data(CSV_PATH)

    print("\nEmbedding text stream (once) …")
    text_embs = embed_texts(text_docs, TEXT_MODEL)

    mesh_model = SentenceTransformer(MESH_MODEL)

    records = []

    for beta in BETA_VALUES:
        print(f"\n--- β = {beta} ---")

        # Formula A
        mesh_a, has_a = embed_mesh_formula_a(mesh_list, beta, mesh_model)
        comb_a = fuse(text_embs, mesh_a, has_a, ALPHA_FIXED)
        tm_a, topics_a = run_bertopic(full_docs, comb_a)
        tc_a, td_a, n_a = compute_metrics(tm_a, full_docs, topics_a)
        print(f"  Formula A: TC={tc_a:.4f}, TD={td_a:.4f}, TC+TD={tc_a+td_a:.4f}  ({n_a} topics)")

        # Formula B
        mesh_b, has_b = embed_mesh_formula_b(mesh_list, beta, mesh_model)
        comb_b = fuse(text_embs, mesh_b, has_b, ALPHA_FIXED)
        tm_b, topics_b = run_bertopic(full_docs, comb_b)
        tc_b, td_b, n_b = compute_metrics(tm_b, full_docs, topics_b)
        print(f"  Formula B: TC={tc_b:.4f}, TD={td_b:.4f}, TC+TD={tc_b+td_b:.4f}  ({n_b} topics)")

        records.append({
            "beta": beta, "formula": "A (per-term)",
            "TC": tc_a, "TD": td_a, "TC+TD": tc_a + td_a, "n_topics": n_a})
        records.append({
            "beta": beta, "formula": "B (group-level)",
            "TC": tc_b, "TD": td_b, "TC+TD": tc_b + td_b, "n_topics": n_b})

    df = pd.DataFrame(records)

    # --- CSV ---
    out_csv = os.path.join(SCRIPT_DIR, "beta_comparison_results.csv")
    df.to_csv(out_csv, index=False)

    # --- Readable table ---
    out_txt = os.path.join(SCRIPT_DIR, "beta_comparison_results.txt")
    with open(out_txt, "w") as f:
        f.write("β Normalization Experiment (α=0.45 fixed, Dual PubMedBERT)\n")
        f.write("=" * 65 + "\n")
        f.write(f"{'β':>6}  {'Formula':>18}  {'TC':>7}  {'TD':>7}  {'TC+TD':>8}  {'Topics':>6}\n")
        f.write("-" * 65 + "\n")
        for _, row in df.iterrows():
            f.write(f"{row['beta']:6.2f}  {row['formula']:>18}  "
                    f"{row['TC']:7.4f}  {row['TD']:7.4f}  {row['TC+TD']:8.4f}  "
                    f"{int(row['n_topics']):6d}\n")
            if row["formula"].startswith("B"):
                f.write("-" * 65 + "\n")

    print(f"\nSaved: {out_csv}")
    print(f"Saved: {out_txt}")
    print("\nPaste the table from beta_comparison_results.txt into the manuscript.")


if __name__ == "__main__":
    main()
