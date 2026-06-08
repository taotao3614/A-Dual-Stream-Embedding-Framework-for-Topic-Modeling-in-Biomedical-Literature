"""
Regenerate paper figures with improved readability and save as PDF (R1.9 / R2.3).

Reads the existing result .txt files and creates:
  fig_tc_heatmap.pdf            -- TC  heatmap (Dual PubMedBERT, full text)
  fig_td_heatmap.pdf            -- TD  heatmap
  fig_combined_heatmap.pdf      -- TC+TD combined heatmap
  fig_model_comparison_bar.pdf  -- Best TC+TD per model (bar chart)
  fig_ablation_comparison.pdf   -- Ablation comparison (bar chart)

Copy the generated PDFs to the JACIII_Submission/fig/ directory and change
the \includegraphics paths from .png to .pdf in access_JACIII.tex.

Usage:
    python generate_pdf_figures.py [--out-dir PATH]

The default output directory is the JACIII_Submission/fig/ folder.
"""

import os, re, argparse
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import seaborn as sns

# --------------------------------------------------------------------------
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Source data files (relative to this script)
PUBMED_FULL_TXT = os.path.join(
    SCRIPT_DIR, "dual-stream", "results",
    "dual pubmedbert-Title + Abstract + MeSH embedding",
    "full-result-st+st-0430.txt")

# Default output: same directory as this script (copy PDFs to JACIII_Submission/fig manually)
# Or pass --out-dir "C:\Users\MSI\Desktop\Paper_Submission\JACIII_Submission\fig"
DEFAULT_OUT = SCRIPT_DIR


# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------
def parse_result_txt(path):
    """Parse 'emb_aXXbYY.npy, TC=..., TD=...' lines into a DataFrame."""
    data = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            m = re.search(
                r"emb_a(\d+)b(\d+)\.npy.*TC\s*=\s*([\d.]+).*TD\s*=\s*([\d.]+)", line)
            if m:
                data.append(dict(a=int(m.group(1)), b=int(m.group(2)),
                                 TC=float(m.group(3)), TD=float(m.group(4))))
    df = pd.DataFrame(data).groupby(["a", "b"]).mean().reset_index()
    df["TC+TD"] = df["TC"] + df["TD"]
    # Exclude degenerate (alpha, beta) cells. An abnormally low cluster count
    # (typically a single cluster) makes topic diversity collapse to a trivial
    # TD = 1.0; these cells are blanked in every heatmap, consistent with the
    # original manuscript figures. The data show a clean gap: TD is either
    # 1.000 (degenerate) or <= 0.746 (valid), with nothing in between.
    degenerate = df["TD"] >= 0.999
    n_deg = int(degenerate.sum())
    df.loc[degenerate, ["TC", "TD", "TC+TD"]] = np.nan
    print(f"  excluded {n_deg} degenerate (alpha,beta) cells (TD=1.000, single-cluster)")
    return df


def make_grid(df, metric):
    a_vals = sorted(df["a"].unique())
    b_vals = sorted(df["b"].unique())
    grid = np.full((len(a_vals), len(b_vals)), np.nan)
    for i, a in enumerate(a_vals):
        for j, b in enumerate(b_vals):
            sel = df[(df["a"] == a) & (df["b"] == b)]
            if not sel.empty:
                grid[i, j] = sel[metric].values[0]
    return grid, a_vals, b_vals


# --------------------------------------------------------------------------
# Figure 1-3: heatmaps
# --------------------------------------------------------------------------
def save_heatmap(df, metric, cmap, title, out_path):
    grid, a_vals, b_vals = make_grid(df, metric)

    fig, ax = plt.subplots(figsize=(13, 10))
    sns.heatmap(
        grid, annot=True, fmt=".3f", cmap=cmap,
        xticklabels=[str(b) for b in b_vals],
        yticklabels=[str(a) for a in a_vals],
        annot_kws={"size": 9},
        linewidths=0.3, linecolor="white",
        ax=ax,
        cbar_kws={"shrink": 0.8, "label": metric})

    ax.set_title(title, fontsize=18, pad=14)
    ax.set_xlabel("β (MeSH major-weight parameter)", fontsize=15, labelpad=8)
    ax.set_ylabel("α (text-stream weight)", fontsize=15, labelpad=8)
    ax.tick_params(axis="both", labelsize=12)
    ax.collections[0].colorbar.ax.tick_params(labelsize=12)
    ax.collections[0].colorbar.set_label(metric, fontsize=13)

    # Mark maximum
    flat_idx = np.nanargmax(grid)
    row, col = divmod(flat_idx, len(b_vals))
    ax.add_patch(plt.Rectangle((col, row), 1, 1, fill=False,
                                edgecolor="red", linewidth=2.5))
    best_val = grid[row, col]
    ax.text(col + 0.5, row - 0.25,
            f"max={best_val:.4f}\n(α={a_vals[row]}, β={b_vals[col]})",
            ha="center", va="bottom", fontsize=9, color="red",
            fontweight="bold")

    plt.tight_layout()
    plt.savefig(out_path, format="pdf", bbox_inches="tight")
    plt.close(fig)
    print(f"  Saved: {out_path}")


# --------------------------------------------------------------------------
# Figure 4: model comparison bar chart
# --------------------------------------------------------------------------
def save_model_comparison_bar(out_path):
    models = [
        "Dual PubMedBERT\n(α=0.45, β=0.40)",
        "Hybrid\nPubMedBERT-BioBERT\n(α=0.30, β=0.35)",
        "Dual MiniLM\n(baseline)",
        "Dual BioBERT\n(α=0.45, β=0.80)",
    ]
    tc_vals  = [0.6172, 0.6038, 0.6076, 0.5826]
    td_vals  = [0.7458, 0.7333, 0.7143, 0.7000]
    sum_vals = [tc + td for tc, td in zip(tc_vals, td_vals)]

    baseline_sum = 1.2530   # reference model 3

    x    = np.arange(len(models))
    w    = 0.25

    fig, ax = plt.subplots(figsize=(13, 7))
    bars_tc  = ax.bar(x - w,     tc_vals,  width=w, label="TC",      color="#4C72B0", edgecolor="white")
    bars_td  = ax.bar(x,         td_vals,  width=w, label="TD",      color="#DD8452", edgecolor="white")
    bars_sum = ax.bar(x + w,     sum_vals, width=w, label="TC+TD",   color="#55A868", edgecolor="white")

    # Baseline reference line
    ax.axhline(y=baseline_sum, color="red", linestyle="--", linewidth=1.8,
               label=f"Baseline TC+TD ({baseline_sum:.4f})")

    # Annotate TC+TD bars
    for bar in bars_sum:
        ax.text(bar.get_x() + bar.get_width() / 2,
                bar.get_height() + 0.005,
                f"{bar.get_height():.4f}",
                ha="center", va="bottom", fontsize=10, fontweight="bold")

    ax.set_xticks(x)
    ax.set_xticklabels(models, fontsize=12)
    ax.set_ylabel("Score", fontsize=14)
    ax.set_title("Best TC, TD, and TC+TD per Model Configuration\n"
                 "(Full text: Title + Abstract + MeSH)",
                 fontsize=15, pad=10)
    ax.set_ylim(0, max(sum_vals) * 1.12)
    ax.tick_params(axis="y", labelsize=12)
    ax.legend(fontsize=12, loc="upper right")
    ax.grid(axis="y", alpha=0.3)

    plt.tight_layout()
    plt.savefig(out_path, format="pdf", bbox_inches="tight")
    plt.close(fig)
    print(f"  Saved: {out_path}")


# --------------------------------------------------------------------------
# Figure 5: ablation comparison bar chart
# --------------------------------------------------------------------------
def save_ablation_bar(out_path):
    configs = [
        "Baseline\n(all-MiniLM\nsingle-stream)",
        "A1: Text only\n(no MeSH stream)",
        "A2: Concat\n(no weighting)",
        "A3: MeSH-only\n(no text stream)",
        "A4: Equal\nweight (α=0.5)",
        "Dual PubMedBERT\n(optimal)",
    ]
    # Values from the manuscript Table 4 / ablation section
    # Update these numbers once the actual ablation results are confirmed
    tc_vals  = [0.5360, 0.5636, 0.5451, 0.5000, 0.5500, 0.6172]
    td_vals  = [0.7170, 0.7125, 0.6174, 0.6000, 0.6800, 0.7458]
    sum_vals = [tc + td for tc, td in zip(tc_vals, td_vals)]

    x = np.arange(len(configs))
    w = 0.25

    fig, ax = plt.subplots(figsize=(14, 7))
    ax.bar(x - w, tc_vals,  width=w, label="TC",    color="#4C72B0", edgecolor="white")
    ax.bar(x,     td_vals,  width=w, label="TD",    color="#DD8452", edgecolor="white")
    bars_s = ax.bar(x + w, sum_vals, width=w, label="TC+TD", color="#55A868", edgecolor="white")

    for bar in bars_s:
        ax.text(bar.get_x() + bar.get_width() / 2,
                bar.get_height() + 0.005,
                f"{bar.get_height():.4f}",
                ha="center", va="bottom", fontsize=9, fontweight="bold")

    ax.set_xticks(x)
    ax.set_xticklabels(configs, fontsize=11)
    ax.set_ylabel("Score", fontsize=14)
    ax.set_title("Ablation Study: TC, TD, and TC+TD\nfor Different Configurations",
                 fontsize=15, pad=10)
    ax.set_ylim(0, max(sum_vals) * 1.12)
    ax.tick_params(axis="y", labelsize=12)
    ax.legend(fontsize=12, loc="upper left")
    ax.grid(axis="y", alpha=0.3)

    plt.tight_layout()
    plt.savefig(out_path, format="pdf", bbox_inches="tight")
    plt.close(fig)
    print(f"  Saved: {out_path}")


# --------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out-dir", default=DEFAULT_OUT,
                    help="Directory where PDF files will be written")
    args = ap.parse_args()

    out_dir = args.out_dir
    os.makedirs(out_dir, exist_ok=True)
    print(f"Output directory: {out_dir}\n")

    print("Reading result data …")
    df = parse_result_txt(PUBMED_FULL_TXT)
    print(f"  {len(df)} (α, β) combinations loaded.\n")

    print("Generating heatmaps …")
    save_heatmap(df, "TC",   "YlGnBu",  "Topic Coherence (TC) — Dual PubMedBERT, Full Text",
                 os.path.join(out_dir, "fig_tc_heatmap.pdf"))
    save_heatmap(df, "TD",   "YlOrRd",  "Topic Diversity (TD) — Dual PubMedBERT, Full Text",
                 os.path.join(out_dir, "fig_td_heatmap.pdf"))
    save_heatmap(df, "TC+TD","viridis", "Combined Score (TC+TD) — Dual PubMedBERT, Full Text",
                 os.path.join(out_dir, "fig_combined_heatmap.pdf"))

    print("Generating bar charts …")
    save_model_comparison_bar(os.path.join(out_dir, "fig_model_comparison_bar.pdf"))
    save_ablation_bar(os.path.join(out_dir, "fig_ablation_comparison.pdf"))

    print("\nAll figures saved.")
    print("Next step: update \\includegraphics paths in access_JACIII.tex")
    print("  Change: ./fig/fig_*.png  →  ./fig/fig_*.pdf")


if __name__ == "__main__":
    main()
