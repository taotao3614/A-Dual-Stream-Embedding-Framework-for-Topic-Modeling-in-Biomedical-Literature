"""
Per-topic coherence extraction and significance test (R1.7).

Compares Dual PubMedBERT (α=0.45, β=0.40, pre-computed embedding) against the
single-stream baseline (all-MiniLM-L6-v2, abstract only — matching the Lezhnina
2023 reference model, TC=0.536).  Applies a Mann-Whitney U test on per-topic
c_v coherence scores.

Usage:
    python per_topic_significance_test.py

Outputs:
    per_topic_tc_results.csv          -- per-topic TC for both configs
    significance_test_results.txt     -- test statistics and p-value
"""

import os, json, random
import numpy as np
import pandas as pd
from scipy import stats
from sentence_transformers import SentenceTransformer

from bertopic import BERTopic
from umap import UMAP
from hdbscan import HDBSCAN
from sklearn.feature_extraction.text import CountVectorizer
from bertopic.representation import MaximalMarginalRelevance
from bertopic.vectorizers import ClassTfidfTransformer
from gensim.models import CoherenceModel
from gensim.corpora import Dictionary

RANDOM_STATE = 34
np.random.seed(RANDOM_STATE)
random.seed(RANDOM_STATE)

# --------------------------------------------------------------------------
# Paths
# --------------------------------------------------------------------------
SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
CSV_PATH    = os.path.join(SCRIPT_DIR, "dual-stream", "data", "raw data.csv")

# Optimal Dual PubMedBERT embedding (pre-computed on server)
PUBMED_EMB  = os.path.join(
    SCRIPT_DIR, "dual-stream", "results",
    "dual pubmedbert-Title + Abstract + MeSH embedding",
    "MaxTC+TD=1.3443@a45b40.npy")

# Single-stream baseline: all-MiniLM-L6-v2 on abstract only
# (replicates the Lezhnina 2023 reference model, TC=0.536)
BASELINE_MODEL = "all-MiniLM-L6-v2"


# --------------------------------------------------------------------------
def load_docs(csv_path):
    df = pd.read_csv(csv_path).dropna(subset=["abstract"])

    def mesh_str(row):
        try:
            items = json.loads(row["mesh_terms"])
            return " ".join(i["DescriptorName"] for i in items if "DescriptorName" in i)
        except Exception:
            return ""

    df["mesh_str"] = df.apply(mesh_str, axis=1)
    # full docs for Dual PubMedBERT (title + abstract + MeSH)
    full_docs = (df["title"] + " " + df["abstract"] + " " + df["mesh_str"]).values
    # abstract-only docs for single-stream baseline
    abstract_docs = df["abstract"].values
    return full_docs, abstract_docs


def build_topic_model():
    return BERTopic(
        umap_model=UMAP(
            n_neighbors=15, n_components=5, min_dist=0.0,
            metric="cosine", random_state=RANDOM_STATE),
        hdbscan_model=HDBSCAN(
            min_cluster_size=30, min_samples=10,
            metric="euclidean", cluster_selection_method="eom",
            prediction_data=True),
        vectorizer_model=CountVectorizer(stop_words="english"),
        ctfidf_model=ClassTfidfTransformer(),
        representation_model=MaximalMarginalRelevance(diversity=0.2),
        calculate_probabilities=True,
        verbose=True,
    )


def per_topic_tc(topic_model, docs, topics):
    """Return list of per-topic c_v coherence scores and the mean."""
    doc_info   = topic_model.get_document_info(docs)
    per_topic  = doc_info.groupby("Topic", as_index=False).agg({"Document": " ".join})
    cleaned    = topic_model._preprocess_text(per_topic.Document.values)
    analyzer   = topic_model.vectorizer_model.build_analyzer()
    tokens     = [analyzer(d) for d in cleaned]

    n_topics   = len(set(topics)) - 1   # exclude outlier topic -1
    topic_words = [
        [w for w, _ in topic_model.get_topic(i)[:10]]
        for i in range(n_topics)
    ]

    dictionary = Dictionary(tokens)
    cm = CoherenceModel(
        topics=topic_words, texts=tokens,
        dictionary=dictionary, coherence="c_v")
    scores = cm.get_coherence_per_topic()
    return scores, cm.get_coherence()


# --------------------------------------------------------------------------
def main():
    print("Loading documents …")
    full_docs, abstract_docs = load_docs(CSV_PATH)
    print(f"  {len(full_docs)} documents loaded.")

    print("\nLoading Dual PubMedBERT embedding …")
    emb_pubmed = np.load(PUBMED_EMB)
    print(f"  PubMedBERT embedding: {emb_pubmed.shape}")

    print("\nComputing single-stream baseline embeddings (all-MiniLM-L6-v2, abstract only) …")
    baseline_model = SentenceTransformer(BASELINE_MODEL)
    emb_baseline = baseline_model.encode(
        abstract_docs, batch_size=256, show_progress_bar=True)
    print(f"  Baseline embedding: {emb_baseline.shape}")

    # --- Dual PubMedBERT (dual-stream, full text) ---
    print("\nRunning BERTopic on Dual PubMedBERT (α=0.45, β=0.40) …")
    tm_pubmed = build_topic_model()
    topics_p, _ = tm_pubmed.fit_transform(full_docs, embeddings=emb_pubmed)
    tc_p, mean_p = per_topic_tc(tm_pubmed, full_docs, topics_p)
    n_p = len(set(topics_p)) - 1
    print(f"  → {n_p} topics, mean TC = {mean_p:.4f}")

    # --- Single-stream baseline (abstract only) ---
    print("\nRunning BERTopic on single-stream baseline (abstract only) …")
    tm_base = build_topic_model()
    topics_b, _ = tm_base.fit_transform(abstract_docs, embeddings=emb_baseline)
    tc_b, mean_b = per_topic_tc(tm_base, abstract_docs, topics_b)
    n_b = len(set(topics_b)) - 1
    print(f"  → {n_b} topics, mean TC = {mean_b:.4f}")

    # --- Mann-Whitney U (no pairing assumption needed) ---
    u_stat, p_val = stats.mannwhitneyu(tc_p, tc_b, alternative="greater")

    # Rank-biserial correlation as effect size
    n1, n2   = len(tc_p), len(tc_b)
    r_rb     = 1 - (2 * u_stat) / (n1 * n2)

    # --- Save per-topic CSV ---
    max_len = max(n_p, n_b)
    tc_p_pad = list(tc_p) + [np.nan] * (max_len - n_p)
    tc_b_pad = list(tc_b) + [np.nan] * (max_len - n_b)
    df_out = pd.DataFrame({
        "topic_rank":   range(max_len),
        "tc_pubmedbert": tc_p_pad,
        "tc_baseline":   tc_b_pad,
    })
    out_csv = os.path.join(SCRIPT_DIR, "per_topic_tc_results.csv")
    df_out.to_csv(out_csv, index=False)

    # --- Save test summary ---
    out_txt = os.path.join(SCRIPT_DIR, "significance_test_results.txt")
    lines = [
        "=== Per-Topic TC: Mann-Whitney U Test ===\n",
        f"Dual PubMedBERT (α=0.45, β=0.40, dual-stream, full text): {n_p} topics, mean TC = {mean_p:.4f}",
        f"Single-stream baseline (all-MiniLM-L6-v2, abstract only): {n_b} topics, mean TC = {mean_b:.4f}",
        "",
        f"Group TC_PubMedBERT:  mean={np.mean(tc_p):.4f}, std={np.std(tc_p):.4f}, n={n_p}",
        f"Group TC_Baseline:    mean={np.mean(tc_b):.4f}, std={np.std(tc_b):.4f}, n={n_b}",
        "",
        f"Mann-Whitney U statistic: {u_stat:.2f}",
        f"p-value (one-sided, 'greater'): {p_val:.6f}",
        f"Rank-biserial correlation r: {r_rb:.4f}",
        f"Significant at α=0.05: {p_val < 0.05}",
    ]
    with open(out_txt, "w") as f:
        f.write("\n".join(lines) + "\n")

    print("\n=== Results ===")
    for line in lines:
        print(line)
    print(f"\nSaved: {out_txt}")
    print(f"Saved: {out_csv}")


if __name__ == "__main__":
    main()
