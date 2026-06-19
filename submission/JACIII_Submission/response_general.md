# General Response to the Associate Editor

**Manuscript:** Topic Modelling for Biomedical Literature Retrieval via a Dual-Stream Embedding Framework
**Journal:** Journal of Advanced Computational Intelligence and Intelligent Informatics (JACIII)

We thank the Associate Editor and the three reviewers for their careful evaluation. Several concerns were raised by more than one reviewer; we group these into five themes below, then list the points specific to a single reviewer. All changes are marked in the revised manuscript.

---

## Category 1 — Writing Quality, Coherence, and Section Structure
*(Raised by: Reviewer 1, Comment 8 · Reviewer 2, Comments 1 and 4)*

All three concerns point to the same underlying issue: the original manuscript relied too heavily on subsections and lacked coherent transitions. We have made the following structural revisions:

- **Introduction** (R2.1): All four subsections were removed; the Introduction is now continuous prose.
- **Related Work** (R2.4): Reorganized from seven subsections into three thematic subsections.
- **Methodology** (R2.4): Four short fusion-related subsections were merged into a single subsection.
- **Results** (R2.4): Reduced from six to five subsections by merging the parameter-sensitivity analysis into the main results discussion.
- **Discussion** (R2.4, R2.8): The "Key Findings" subsection was condensed from seven paragraphs to three; off-topic material was removed.
- **Language** (R1.8): The Introduction, Related Work, and Discussion were rewritten for shorter sentences and improved grammar throughout.

---

## Category 2 — Figure Readability and Vector Graphics
*(Raised by: Reviewer 1, Comment 9 · Reviewer 2, Comment 3)*

Both reviewers noted that the heatmap figures have small axis labels, a dense layout, and insufficient image resolution. We have regenerated all five figures with the following improvements:

- Axis label font size increased (≥15 pt), annotation font size increased (≥9 pt).
- Colour-bar labels enlarged and clearly annotated.
- All figures exported as PDF vector graphics (replacing the original PNG bitmaps).
- The optimal parameter region is highlighted with a red bounding box in each heatmap.

*(Note: The regenerated PDF figures are submitted as separate files.)*

---

## Category 3 — Related Work: Condensing and Contextualisation
*(Raised by: Reviewer 1, Comment 11 · Reviewer 2, Comment 2)*

Both reviewers asked for a more concise Related Work section that explicitly links cited studies to the present research. We have:

- Reorganized seven subsections into three thematic groups:
  (i) Probabilistic and Neural Topic Models,
  (ii) Domain-Specific Embeddings and Structured Knowledge,
  (iii) Evaluation and Gaps in Biomedical Topic Modelling.
- Added explicit linking sentences at the end of each subsection explaining how each group of studies motivates or contrasts with our approach.
- Forward-referenced the methodological comparison in Table 5 from the Introduction.

---

## Category 4 — Ablation Study: Deeper Mechanistic Explanation
*(Raised by: Reviewer 1, Comment 6 · Reviewer 2, Comment 7)*

Both reviewers felt the ablation discussion did not fully explain *why* the single-stream configurations underperform. We have extended the ablation discussion to provide a metric-level explanation:

Across configurations A2–A4, topic coherence (TC) remains roughly stable (0.527–0.545) while topic diversity (TD) collapses sharply (from 0.714 to 0.609). The root cause is that naive text-concatenation of MeSH descriptors injects a small, heavily-reused controlled vocabulary (e.g., *Humans*, *Female*) that the class-based TF-IDF cannot sufficiently down-weight, inflating keyword overlap across topics. The dual-stream design avoids this by encoding MeSH in a *separate* embedding space and weighting major against minor descriptors, so generic terms never contaminate the keyword-extraction stage.

---

## Category 5 — Factual Accuracy: Consistency Claim
*(Raised by: Reviewer 2, Comment 6)*

The original manuscript incorrectly stated that the dual-stream framework "consistently outperforms the baseline under all parameter settings." Table 2 shows that Dual BioBERT achieves TC+TD = 1.2331, which is 1.6 % *below* the baseline. We have corrected this in the Abstract, Results, and Discussion to accurately state: "three of the four dual-stream configurations outperform the baseline on the combined TC+TD metric; Dual BioBERT falls below it by 1.6 %, indicating that the benefit of dual-stream fusion is conditional on a well-matched embedding model."

---

## Additional Individual Concerns

The following concerns were unique to a single reviewer and are addressed in full in the respective per-reviewer response files:

| Item | Reviewer | Summary |
|------|----------|---------|
| Novelty statement | R1.1 | New paragraph added to Introduction |
| Generalization, overfitting, scalability | R1.2 | Expanded Limitations subsection |
| External validation | R1.3 | Acknowledged in Limitations |
| Grid-search runtime and deployment | R1.4 | New paragraph in Experiment Design |
| LLM labelling reliability | R1.5 | New paragraph in LLM section |
| Statistical significance | R1.7 | Per-topic coherence analysis and Mann-Whitney U test added to Results |
| Table captions | R1.10 | All five captions rewritten |
| UMAP/HDBSCAN hyperparameters | R1.12 | Justification added in pipeline description |
| "Minimal pre-processing" justification | R1.13 | Explanation added in Data Preprocessing |
| Reference formatting | R1.14 | Audited; citation error corrected |
| β design (document-level normalisation) | R3.1 | β description corrected; group-normalised variant added and compared |
| MeSH hierarchy rationale | R3.2 | Design Rationale paragraph added |

All reviewer comments have been addressed in the revised manuscript and the accompanying
per-reviewer response files.

---

## Summary of All Manuscript Changes

| Section | Change | Reviewer(s) |
|---------|--------|------------|
| Abstract | "consistently outperforms" → "3/4 configurations outperform" | R2.6 |
| Introduction | Removed 4 subsections; added novelty paragraph | R2.1, R1.1 |
| Related Work | 7 → 3 subsections; added contextualisation sentences | R1.11, R2.2 |
| Methodology | Merged 4 fusion subsections; added Design Rationale paragraph; UMAP/HDBSCAN justification; preprocessing justification; corrected β description | R2.4, R3.2, R1.12, R1.13, R3.1 |
| Experiment Design | New paragraph on grid-search cost and deployment | R1.4 |
| LLM section | New paragraph on reliability and alternatives | R1.5 |
| Results | Ablation discussion deepened; per-topic significance analysis added; β weighting-scheme subsection added | R1.6, R2.7, R1.7, R3.1 |
| Discussion | Condensed 7 → 3 paragraphs; factual contradiction corrected | R2.8, R2.6 |
| Limitations | Added generalization, overfitting, external validation, future MeSH work | R1.2, R1.3, R3.2 |
| Table 1 | Model name column corrected | R2.6 (related) |
| Table captions (all 5) | Rewritten to be self-contained | R1.10 |
| Notation | "formula" → "equation"; Eq. 3–4 given `\label` and `\ref` | R2.5 |
| References | Format audited; dataset citation corrected | R1.14 |
| Figures (all 5) | Regenerated as PDF vector graphics with larger fonts | R1.9, R2.3 |
