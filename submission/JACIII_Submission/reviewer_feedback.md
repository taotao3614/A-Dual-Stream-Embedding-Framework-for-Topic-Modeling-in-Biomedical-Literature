# JACIII 审稿意见记录

**论文题目**：Topic Modelling for Biomedical Literature Retrieval via a Dual-Stream Embedding Framework
**期刊**：Journal of Advanced Computational Intelligence and Intelligent Informatics (JACIII)
**记录日期**：2026-05-20

---

## 编辑意见 (Editor Comments)

<!-- 在此填写编辑的总体意见 -->


---

## Reviewer 1 (1st review)

### Comments to Author

The manuscript presents a dual-stream embedding framework for biomedical topic modelling by integrating textual embeddings with MeSH metadata. The work addresses an important and timely problem in biomedical information retrieval and demonstrates promising improvements over baseline approaches. The methodology is technically sound, well motivated, and the experimental results are encouraging. The paper is generally suitable for publication; however, a few minor revisions are recommended to further improve clarity, rigor and presentation quality.

- The novelty of the proposed approach should be articulated more explicitly in the Introduction. The authors are encouraged to clearly distinguish how the dual-stream fusion advances beyond existing BERTopic extensions and multimodal topic modelling methods.
- Although the dataset of 3,000 PubMed records is acceptable, the authors should briefly discuss generalization capability, possible overfitting risks, and expected scalability to larger biomedical corpora.
- The study currently relies on a single dataset. A short discussion acknowledging the lack of external validation and its implications would strengthen the manuscript.
- The exhaustive grid search over α and β is valuable but potentially computationally expensive. Including a brief note on runtime complexity and practical deployment considerations would improve completeness.
- The LLM-based topic labelling is an interesting component; however, the authors should briefly comment on its reliability and possible comparison with alternative labelling strategies.
- The ablation study is useful; a slightly deeper discussion explaining why certain configurations underperform would improve interpretability of the results.
- If feasible, include a brief note regarding statistical significance of improvements over the baseline.
- The manuscript should be carefully proofread to correct minor grammatical issues and reduce overly long sentences in a few sections.
- Some figures (particularly heatmaps) appear visually dense; improving axis label size and color bar readability is recommended.
- Table captions should be made more descriptive and self-contained.
- The Related Work section, while comprehensive, could be slightly condensed; a small comparison table may improve readability.
- Provide brief justification for the chosen UMAP and HDBSCAN hyperparameters.
- The claim of "minimal pre-processing" would benefit from a short justification explaining why additional normalization steps were unnecessary.
- Carefully verify reference formatting for consistency with the journal style.

**Final Recommendation: Accept with Minor Revisions.**

---

## Reviewer 2 (1st review)

### Comments to Author

This manuscript proposed the Topic Modelling for Biomedical Literature Retrieval via a Dual-Stream Embedding Framework. Here are some modification comments.

1. It is not common for an article to use subsections in the introduction.

2. In the "Related Work" section, the authors merely provide a brief analysis of the literature without explaining how these studies relate to the present research. Additionally, the "Related Work" section is divided into seven subsections, which is overly lengthy; we recommend that the authors reorganize this section.

3. The font size in the figures within the manuscript is too small, which affects the overall readability of the article. Additionally, the images in the manuscript are too blurry; we recommend using vector graphics.

4. The author's writing is poor. Each section in the manuscript contains too many subsections, resulting in a lack of coherence throughout the manuscript.

5. The manuscript contains a mixture of "formula" and "equation" notation.

6. The manuscript notes that the Dual-Flow model consistently outperforms the baseline model under various parameter settings; however, in Table 2, Dual BioBERT actually performs worse than the baseline.

7. The ablation experiments in the manuscript do not fully demonstrate the advantages of the dual-flow framework proposed in this paper.

8. The discussion section takes up a significant portion of the paper, but much of the content is irrelevant and fails to highlight the manuscript's key contributions.

---

## Reviewer 3 (1st review)

### Comments to Author

In this study, the idea of treating expert-generated structured data (MeSH) as a separate stream from text and integrating them in a dual-stream manner is a simple yet effective design choice, and constitutes a sound overall approach.

On the other hand, there is one point of concern regarding the design of parameter β. Currently, each MeSH term is assigned a uniform weight depending on whether it is major or minor; however, given that the number of major and minor terms varies across documents, this formulation may cause the effective contribution ratio between them to depend on term counts. Therefore, rather than assigning weights to individual terms, it may be more appropriate to define β in terms of the overall weight distribution—e.g., by normalizing so that the contribution ratio of major and minor terms remains constant at the document level—which would better reflect the intended control.

In addition, MeSH is not merely a collection of independent terms, but a rich knowledge organization system that encodes hierarchical relationships, synonym mappings, and contextual information through qualifiers. However, in the current framework, these descriptors are treated essentially as independent tokens and aggregated via simple averaging. It would be helpful to clarify the rationale for not leveraging such structured information, and to discuss whether incorporating these richer aspects of MeSH could further improve the representation.

---

## 回复计划 (Response Plan)

| # | 来源 | 问题摘要 | 计划修改 | 状态 |
|---|------|---------|---------|------|
| 1 | R1   |         |         | 待处理 |
| 2 | R2   |         |         | 待处理 |

---

## 修改日志 (Revision Log)

| 日期 | 修改内容 | 对应意见 |
|------|---------|---------|
|      |         |         |
