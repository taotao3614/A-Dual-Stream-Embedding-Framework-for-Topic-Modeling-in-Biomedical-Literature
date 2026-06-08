"""
Descriptive analysis of MeSH major/minor term counts (for R3.1 response).

Quantifies how far the per-term weighting (Formula A) effective major-group
weight deviates from the nominal beta, using only the corpus metadata.
Fully reproducible — no embeddings, no BERTopic.
"""
import os, json
import numpy as np
import pandas as pd

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CSV = os.path.join(SCRIPT_DIR, "dual-stream", "data", "raw data.csv")

df = pd.read_csv(CSV)
M, m = [], []
for raw in df["mesh_terms"]:
    try:
        terms = json.loads(raw) if raw and raw != "[]" else []
    except Exception:
        terms = []
    maj  = sum(1 for t in terms if t.get("MajorTopicYN", "N") == "Y" and "DescriptorName" in t)
    minr = sum(1 for t in terms if t.get("MajorTopicYN", "N") != "Y" and "DescriptorName" in t)
    M.append(maj); m.append(minr)

M = np.array(M); m = np.array(m)
print("Docs total:", len(df))
print("Docs with >=1 major AND >=1 minor:", int(((M > 0) & (m > 0)).sum()))
print("Docs with no major:", int((M == 0).sum()), "| no minor:", int((m == 0).sum()))
print(f"Major per doc: mean={M.mean():.2f}, median={np.median(M):.0f}, min={M.min()}, max={M.max()}")
print(f"Minor per doc: mean={m.mean():.2f}, median={np.median(m):.0f}, min={m.min()}, max={m.max()}")
print()

mask = (M > 0) & (m > 0)
for beta in [0.2, 0.4, 0.6]:
    wA = (M[mask] * beta) / (M[mask] * beta + m[mask] * (1 - beta))
    dev = np.abs(wA - beta)
    print(f"beta={beta}: effective major-weight w_A  "
          f"mean={wA.mean():.3f}, median={np.median(wA):.3f}, std={wA.std():.3f}, "
          f"min={wA.min():.3f}, max={wA.max():.3f}  (nominal={beta})")
    print(f"          |w_A - beta|  mean={dev.mean():.3f}, "
          f"90th pct={np.percentile(dev, 90):.3f}")
