# Response to Reviewer 1

**Manuscript:** Topic Modelling for Biomedical Literature Retrieval via a Dual-Stream Embedding Framework
**Journal:** Journal of Advanced Computational Intelligence and Intelligent Informatics (JACIII)

We thank Reviewer 1 for the positive assessment ("Accept with Minor Revisions") and the detailed comments. We respond to all 14 points below; line numbers refer to the revised manuscript.

---

**Comment 1:**
*"The novelty of the proposed approach should be articulated more explicitly in the Introduction. The authors are encouraged to clearly distinguish how the dual-stream fusion advances beyond existing BERTopic extensions and multimodal topic modelling methods."*

**Response:** ✅ Addressed.
We added a dedicated paragraph to the Introduction that explicitly contrasts our framework with (a) single-stream BERTopic extensions, which treat metadata as auxiliary text and encode all inputs homogeneously, and (b) multimodal topic models, which fuse sources by simple concatenation or fixed-weight averaging. We state that, to our knowledge, this is the first topic-modelling framework to treat curated biomedical metadata (MeSH) as an independent, separately-weighted embedding stream, and we forward-reference the methodological comparison in Table 5.

---

**Comment 2:**
*"Although the dataset of 3,000 PubMed records is acceptable, the authors should briefly discuss generalization capability, possible overfitting risks, and expected scalability to larger biomedical corpora."*

**Response:** ✅ Addressed.
The Limitations subsection now discusses all three aspects: (i) the generalizability of the dataset-specific optimal (α, β) to other corpora; (ii) the overfitting risk of selecting α and β on the same corpus used for evaluation, mitigated by the broad, contiguous high-performing region of the parameter grid; and (iii) expected linear scalability, since embeddings are computed once and the α–β fusion is an O(d) vector operation.

---

**Comment 3:**
*"The study currently relies on a single dataset. A short discussion acknowledging the lack of external validation and its implications would strengthen the manuscript."*

**Response:** ✅ Addressed.
The Limitations subsection now explicitly acknowledges that all results derive from one corpus, that external validation on independent datasets is required before production adoption, and recommends a train/validation/test protocol for parameter selection in future work.

---

**Comment 4:**
*"The exhaustive grid search over α and β is valuable but potentially computationally expensive. Including a brief note on runtime complexity and practical deployment considerations would improve completeness."*

**Response:** ✅ Addressed.
A new paragraph ("Computational cost and deployment considerations") was added to the Experiment Design section. It explains that the grid search evaluates 19×19 = 361 combinations per model; text and MeSH embeddings are cached once, so only the O(d) fusion and UMAP/HDBSCAN clustering are repeated per combination; the search is an offline one-time cost and is embarrassingly parallel; and deployment overhead over a standard BERTopic pipeline is negligible once the optimal (α, β) is identified.

---

**Comment 5:**
*"The LLM-based topic labelling is an interesting component; however, the authors should briefly comment on its reliability and possible comparison with alternative labelling strategies."*

**Response:** ✅ Addressed.
A new paragraph ("Reliability and alternative labelling strategies") was added in the LLM Topic Labelling section. It clarifies that the LLM titles are a presentation-layer enhancement that does not affect TC/TD scores (which are computed from c-TF-IDF keywords before LLM post-processing), discusses the hallucination risk and its mitigations (keyword-constrained prompt, low-temperature decoding at temperature = 0.3), and briefly compares the approach with alternatives: raw c-TF-IDF keyword lists, KeyBERT-based extraction, and representative-document title selection.

---

**Comment 6:**
*"The ablation study is useful; a slightly deeper discussion explaining why certain configurations underperform would improve interpretability of the results."*

**Response:** ✅ Addressed.
*(This concern is shared by Reviewer 2, Comment 7; we have provided a unified response in the General Response, Category 4.)*

The ablation discussion now provides a metric-level explanation. Across A2–A4, TC stays roughly stable (0.527–0.545) while TD deteriorates sharply (0.714 → 0.609). The underlying cause is that naive concatenation injects a small, heavily-reused MeSH vocabulary (generic descriptors such as *Humans* or *Female*) that the class-based TF-IDF cannot down-weight, inflating cross-topic keyword overlap and collapsing TD. The dual-stream architecture avoids this by encoding MeSH in a separate embedding space.

---

**Comment 7:**
*"If feasible, include a brief note regarding statistical significance of improvements over the baseline."*

**Response:** ✅ Addressed.
We examined the statistical reliability of the coherence improvement at the topic level. Per-topic c_v coherence scores were computed for the optimal Dual PubMedBERT configuration (α = 0.45, β = 0.40; 24 topics) and the single-stream baseline (all-MiniLM-L6-v2 on abstracts; 24 topics). The dual-stream model showed a higher mean per-topic coherence (0.597 vs. 0.568), with the per-topic distribution favouring the dual-stream model (common-language effect size = 56 %). A one-sided Mann-Whitney U test did not reach significance at α = 0.05 (p = 0.25); we attribute this to the small number of topics (n = 24) and the high inter-topic variance inherent to topic models, which makes topic-level hypothesis testing inherently low-powered. A brief, transparent note reporting this analysis has been added to the Results section (Model-Specific Performance subsection). We note that aggregate TC/TD evaluation, consistent with the baseline study and standard practice in topic modelling, remains the primary basis of comparison.

---

**Comment 8:**
*"The manuscript should be carefully proofread to correct minor grammatical issues and reduce overly long sentences in a few sections."*

**Response:** ✅ Addressed.
*(This concern is shared by Reviewer 2, Comments 1 and 4; see also General Response, Category 1.)*

The Introduction, Related Work, and Discussion were substantially rewritten with shorter, clearer sentences. All four Introduction subsections were removed and replaced with continuous prose. In addition, several paragraphs in the Methodology, Experiment Design, and Results sections were also touched up for clarity and concision — for example, the Experiment Design opening was simplified to two core points, the BERTopic pipeline description was streamlined, and a redundant LLM-methodology summary in the Results section was removed. The remaining sections were proofread for grammar and clarity throughout.

---

**Comment 9:**
*"Some figures (particularly heatmaps) appear visually dense; improving axis label size and color bar readability is recommended."*

**Response:** ✅ Addressed.
*(This concern is shared by Reviewer 2, Comment 3; see also General Response, Category 2.)*

All five figures have been regenerated with enlarged axis-label fonts (≥15 pt), clearer colour-bar labels, larger annotation text, and exported as PDF vector graphics. The regenerated figures are submitted as separate files, and the `\includegraphics` paths in the manuscript have been updated to reference the new PDF files.

---

**Comment 10:**
*"Table captions should be made more descriptive and self-contained."*

**Response:** ✅ Addressed.
All five table captions were rewritten to be fully self-contained, including definitions of the metrics reported, the meaning of each column, and explicit references to the comparison baseline where applicable.

---

**Comment 11:**
*"The Related Work section, while comprehensive, could be slightly condensed; a small comparison table may improve readability."*

**Response:** ✅ Addressed.
*(This concern is shared by Reviewer 2, Comment 2; see also General Response, Category 3.)*

Related Work was reorganized from seven subsections into three thematic subsections. The methodological comparison table (Table 5) was already present in the original manuscript and is now explicitly forward-referenced from the Introduction.

---

**Comment 12:**
*"Provide brief justification for the chosen UMAP and HDBSCAN hyperparameters."*

**Response:** ✅ Addressed.
The pipeline description now justifies each value: `n_neighbors = 15`, `n_components = 5`, and `min_dist = 0.0` follow standard BERTopic defaults (with rationale for each), and `min_cluster_size = 30` / `min_samples = 10` were adopted directly from the baseline study to ensure a comparable number of topics on the 3,000-document corpus, facilitating a fair comparison.

---

**Comment 13:**
*"The claim of 'minimal pre-processing' would benefit from a short justification explaining why additional normalization steps were unnecessary."*

**Response:** ✅ Addressed.
The Data Preprocessing subsection now explains that subword tokenization (WordPiece / BPE) used by the transformer models already handles rare and morphologically complex biomedical terms, and that stopword removal and lowercasing would discard lexical cues that the model's contextual attention mechanism exploits for semantic representation.

---

**Comment 14:**
*"Carefully verify reference formatting for consistency with the journal style."*

**Response:** ✅ Addressed.
The reference list was audited against the fujipressbib bibliography style. We additionally corrected a citation error: the dataset source ("Depression, anxiety, and burnout in academia: topic modeling of PubMed abstracts") had been mistakenly cited with the wrong BibTeX key and now correctly cites Lezhnina (2023).
