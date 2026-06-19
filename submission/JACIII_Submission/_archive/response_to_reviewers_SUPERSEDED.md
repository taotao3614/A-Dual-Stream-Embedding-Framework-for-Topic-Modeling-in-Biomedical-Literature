# Response to Reviewers

**Manuscript:** Topic Modelling for Biomedical Literature Retrieval via a Dual-Stream Embedding Framework
**Journal:** Journal of Advanced Computational Intelligence and Intelligent Informatics (JACIII)

We thank the editor and the three reviewers for their careful and constructive comments.
We have revised the manuscript accordingly; all changes are marked in the revised file.
Below, each reviewer comment is quoted (in italics) and followed by our response.
Line numbers refer to the revised manuscript.

> **Status legend:** ✅ done · ⏳ pending author-supplied code/data (see note at end).

---

## Reviewer 1

**Overall:** *Accept with Minor Revisions.* We are grateful for the positive assessment
and have addressed all 14 points.

**1.1 — *Articulate novelty more explicitly; distinguish from BERTopic extensions and
multimodal topic modelling.*** ✅
We added a dedicated paragraph to the Introduction that contrasts our framework with
(a) single-stream BERTopic extensions, which treat metadata as auxiliary text, and
(b) multimodal topic models, which fuse sources by simple concatenation or fixed-weight
averaging. We state explicitly that, to our knowledge, this is the first topic-modelling
framework to treat curated biomedical metadata as an independent, separately weighted
embedding stream, and we forward-reference the methodological comparison in Table 5.

**1.2 — *Discuss generalization, overfitting risk, scalability.*** ✅
The Limitations subsection now discusses all three: generalizability of the dataset-specific
optimal (α, β); the overfitting risk of selecting α and β on the same corpus used for
evaluation (mitigated by the broad, contiguous high-performing region of the grid); and
expected linear scalability (embeddings computed once; fusion is an O(d) operation).

**1.3 — *Single dataset; lack of external validation.*** ✅
The Limitations subsection now explicitly acknowledges that all results derive from one
corpus, that external validation on independent datasets is required before production
adoption, and recommends a train/validation/test protocol for parameter selection.

**1.4 — *Runtime complexity and deployment considerations of the grid search.*** ✅
A new paragraph ("Computational cost and deployment considerations") in the Experiment
Design section explains that the grid search evaluates 19×19 = 361 combinations per model,
that text/MeSH embeddings are cached and only the O(d) fusion and clustering are repeated,
that the search is an offline one-time cost and embarrassingly parallel, and that
deployment overhead over a standard BERTopic pipeline is negligible.

**1.5 — *Comment on LLM topic-labelling reliability and alternative strategies.*** ✅
A new paragraph ("Reliability and alternative labelling strategies") clarifies that the
LLM titles are a presentation-layer enhancement that does not affect the TC/TD scores
(computed from c-TF-IDF keywords), discusses the hallucination risk and its mitigations
(keyword-constrained prompt, low-temperature decoding), and compares the approach with
alternatives (raw c-TF-IDF keywords, KeyBERT, representative-document titles).

**1.6 — *Deeper discussion of why some ablation configurations underperform.*** ✅
The ablation discussion now provides a metric-level explanation: across A2–A4, TC stays
roughly stable while TD collapses, because naive concatenation injects the small, heavily
reused MeSH vocabulary (generic descriptors such as *Humans*, *Female*) that c-TF-IDF
cannot down-weight, inflating cross-topic keyword overlap. This motivates the separate,
weighted MeSH stream.

**1.7 — *Statistical significance of improvements over the baseline.*** ⏳
We will add a paired statistical test (Wilcoxon signed-rank / paired t-test) over the
per-topic TC and TD scores comparing the best dual-stream configuration with the baseline,
and report p-values / confidence intervals in the Results section.
*(Pending: per-topic score files.)*

**1.8 — *Proofread; reduce overly long sentences.*** ✅
The Introduction, Related Work, and Discussion have been substantially rewritten with
shorter sentences; remaining sections were proofread for grammar and clarity.

**1.9 — *Heatmaps visually dense; improve axis labels and colour-bar readability.*** ⏳
The heatmaps will be regenerated with larger axis-label fonts, a clearer colour bar, and
exported as vector graphics. *(Pending: plotting scripts.)*

**1.10 — *Make table captions more descriptive and self-contained.*** ✅
All five table captions were rewritten to be self-contained (defining metrics, the meaning
of each column, and the comparison reference).

**1.11 — *Condense Related Work; add a comparison table.*** ✅
Related Work was reorganized from seven subsections into three. A methodological comparison
table (Table 5) already exists and is now forward-referenced from the Introduction.

**1.12 — *Justify the UMAP and HDBSCAN hyperparameters.*** ✅
The pipeline description now justifies each value: n_neighbors=15, n_components=5,
min_dist=0.0 are standard BERTopic defaults (with their rationale), and min_cluster_size=30
/ min_samples=10 were adopted from the baseline study for a comparable topic count on the
3,000-document corpus.

**1.13 — *Justify the "minimal pre-processing" claim.*** ✅
The Data Preprocessing subsection now explains that subword (WordPiece/BPE) tokenization
already handles rare/morphologically complex biomedical terms, and that stopword removal
and lowercasing would discard cues the transformer's contextual attention exploits.

**1.14 — *Verify reference formatting consistency.*** ✅
The reference list was audited against the fujipressbib style. We additionally corrected a
citation error: the dataset source (the "Depression, anxiety, and burnout in academia"
study) had been cited with the wrong key and now correctly cites Lezhnina (2023).

---

## Reviewer 2

**2.1 — *The Introduction should not use subsections.*** ✅
All four Introduction subsections were removed; the Introduction is now continuous prose.

**2.2 — *Related Work merely lists literature without relating it to the present study;
seven subsections is too long.*** ✅
Related Work was reorganized into three thematic subsections, and each now includes
explicit sentences relating the cited work to the present study (e.g., how our framework
differs from BERTopic and from TopicalMeSH).

**2.3 — *Figure fonts too small / images blurry; use vector graphics.*** ⏳
All figures will be regenerated with larger fonts and exported as vector graphics (PDF).
*(Pending: plotting scripts.)*

**2.4 — *Writing quality; too many subsections; lack of coherence.*** ✅
The subsection count was reduced throughout (Introduction 4→0, Related Work 7→3, the four
fusion-related Methodology subsections merged into one, Results 6→5). The prose of the
restructured sections was rewritten for coherence and concision.

**2.5 — *Mixture of "formula" and "equation" notation.*** ✅
The single occurrence of "formula" was changed to "equation". Equations 3 and 4 were given
labels and are now referenced via the same `\ref` mechanism as Equations 1 and 2.

**2.6 — *The manuscript claims dual-stream consistently outperforms the baseline, but
Table 2 shows Dual BioBERT underperforming.*** ✅
We corrected this contradiction in the Abstract, the Results, and the Discussion. The text
now states accurately that three of the four configurations outperform the baseline on
TC+TD, while Dual BioBERT falls 1.6% below it, and explains that the benefit of dual-stream
fusion is conditional on a well-matched embedding model.
We also corrected the model-name column of Table 1, whose entries had been misaligned with
their embedding models and descriptions.

**2.7 — *The ablation experiments do not fully demonstrate the advantage of the
dual-stream framework.*** ✅ (with ⏳ supplement)
The ablation discussion was deepened (see 1.6) to explain mechanistically why single-stream
concatenation fails and why weighted fusion succeeds. The β control experiment requested by
Reviewer 3 (below) provides further evidence and will be added. *(Pending: experiment code.)*

**2.8 — *The Discussion is too long and contains irrelevant content.*** ✅
The "Key Findings and Implications" subsection was condensed from seven paragraphs to three,
removing material that duplicated the Conclusion and Data Availability statement, and
sharpening the focus on the paper's contributions.

---

## Reviewer 3

We thank the reviewer for recognizing the soundness of the dual-stream design and for two
insightful technical comments.

**3.1 — *β assigns a uniform weight per term, so the effective major/minor contribution
ratio depends on term counts; document-level normalization would better reflect the
intended control.*** ⏳
We agree this is a valid and important observation. We will (a) implement a document-level
group-normalized variant in which the major and minor groups contribute exactly β and 1−β
regardless of term counts —
`MeSH_Embedding = β·mean(major embeddings) + (1−β)·mean(minor embeddings)` —
(b) re-run a small controlled comparison at the optimal Dual PubMedBERT configuration, and
(c) report the comparison in the Results section together with a clarification, in the
Methodology, of the rationale and trade-offs of the two formulations.
*(Pending: α–β fusion / experiment code.)*

**3.2 — *MeSH encodes hierarchy, synonyms, and qualifiers; the framework treats descriptors
as independent tokens averaged together — clarify the rationale and discuss richer use.*** ✅
We added a paragraph to the Methodology ("Design Rationale") explaining why the current
formulation deliberately treats descriptors as independent terms: the contextual encoders
already capture much hierarchical/synonymous relatedness implicitly; relying only on
descriptor strings and the MajorTopicYN flag keeps the method applicable to every MEDLINE
record; and the minimal formulation isolates the contribution of the dual-stream
architecture for a controlled comparison. The Limitations section now discusses how
hierarchy-aware aggregation, graph-based encoders over the MeSH tree, or qualifier-conditioned
embeddings could further enrich the structured stream as future work.

---

## Note on pending items (⏳)

Three items require regenerating experiments/figures and are in progress:
**1.7** (statistical significance — needs per-topic TC/TD scores),
**1.9 / 2.3** (vector-graphics figures — needs plotting scripts),
**3.1 / 2.7 supplement** (β document-level normalization experiment — needs the α–β
fusion code). These will be completed and folded into the revised manuscript and this
letter before resubmission.
