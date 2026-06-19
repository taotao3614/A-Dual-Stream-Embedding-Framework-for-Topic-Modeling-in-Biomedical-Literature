# JACIII 修订进度记录

**最后更新**：2026-05-21（全部修订完成，已发 Amena 老师审阅，等待反馈）
**稿件**：access_JACIII.tex（lualatex 完整周期编译通过，17 页，无未定义引用）

## 当前状态：等待 Amena 老师反馈

- 修订全部完成，提交文件夹 `Submission_Revised/` 已就绪（16 个文件）
- 已通过 Slack 把 4 份回复信 docx + Revised_Manuscript.pdf 发给 Amena 老师审阅
- 待老师反馈后，若无修改即可正式上传期刊系统（截止 2026-06-09）
- 上传方式：每位审稿人文本框粘 .txt + 附件传 .docx；顶部传稿件 PDF 和图片

## 退化值过时内容核查（2026-05-21）

全文核查"因 TD=1.000 退化值导致的过时内容"：
- 正文 headline 数字（0.6172/0.7458/1.3443）、Table 2、热力图讨论 — 均为非退化正确值，原作者本就排除了退化格 ✓
- **发现并修正一处**：β 小节原写"across β ∈ [0.20, 0.60]...within 0.02"，但 β=0.30 时 Formula A 退化（单簇 TD=1.000），破坏该 claim。已改为"4 个有效 β 值 {0.20,0.40,0.50,0.60}"，稿件 + response_reviewer3 同步修正
- 其余位置（Optimal Parameters 范围、消融数字、R1.7）均未受污染

## 审计修正记录（2026-05-21）

逐条核对 24 条意见后修正：
- B1：稿件移除"A reviewer observed"（发表版不应提审稿人）→ "It should be noted"
- B2：response_reviewer1 R1.9、response_reviewer2 R2.3 的 ⏳ 改为 ✅
- B3：response_reviewer2 R2.7 删除"实验待完成"措辞
- B4：旧版合并回复 response_to_reviewers.md 移入 `_archive/`
- C1：R1.7 段落加澄清——每主题 c_v 与 Table 2 聚合 TC 不同尺度
- C2：精简 Results 中重复描述 LLM 方法的两段
- 另修：response_reviewer3.md 去掉别扭的"(§\ref labelled...)"
**提交截止**：2026-06-09
**相关文件**：
- 审稿意见原文：[reviewer_feedback.md](reviewer_feedback.md)
- AE 汇总回复：[response_general.md](response_general.md)
- R1 逐条回复：[response_reviewer1.md](response_reviewer1.md)
- R2 逐条回复：[response_reviewer2.md](response_reviewer2.md)
- R3 逐条回复：[response_reviewer3.md](response_reviewer3.md)
- 旧版合并回复（备份）：[response_to_reviewers.md](response_to_reviewers.md)
- 完整方案计划：`C:\Users\MSI\.claude\plans\fluttering-spinning-tarjan.md`
- 实验代码库：`E:\aMyProject\vscodeProjects\A-Dual-Stream-Embedding-Framework-for-Topic-Modeling-in-Biomedical-Literature\`

---

## 用户已确认的关键决策

- R3 β 设计 → 补做小型对照实验（文档级归一化 vs 现行逐词归一化）
- 图片 → 用户有脚本和数据，重制为矢量图
- 统计显著性 → 用户可拿到每主题 TC/TD 分数，做配对检验
- 结构重构 → 中等程度
- Table 1 名称列 → 按"嵌入模型+描述"修正（已确认）
- Table 2 "(The Baseline's model)" → 指基线研究所用编码器（已确认）
- 回复信格式 → 期刊要求"AE 汇总回复 + 每位审稿人独立回复"，已按此拆分

---

## 阶段进度

| 阶段 | 状态 | 说明 |
|------|------|------|
| A 结构重构 | ✅ 完成 | 引言去子节、Related Work 7→3、方法融合子节合并、Results 6→5、Discussion 精简 |
| B 内容增补 | ✅ 完成 | 新颖性段落、泛化/过拟合/外部验证、网格复杂度、LLM 可靠性、消融深化、超参理由、预处理论证、MeSH 结构讨论 |
| C 新实验与分析 | ✅ 完成 | R1.7 显著性检验（p=0.25，如实写）、R3.1 β 对照（语料统计为主）均完成 |
| D 图片重制 | ✅ 完成 | 5 张 PDF 矢量图已生成，稿件 5 处已改为 .pdf |
| E 一致性与润色 | ✅ 完成 | R2.6 矛盾修正、Table 1 名称修正、formula→equation、Eq 加 label、5 个表格 caption 重写、Table 3 "ten"→"five"、引用错误修正 |
| F 回复信 | ✅ 完成 | 四份文件（general + 三位审稿人）全部完成，无 ⏳ 待办项 |

---

## 已完成的具体修改（access_JACIII.tex）

- 引言：删除 4 个子节改连贯叙述；新增新颖性段落（区别于 BERTopic 扩展与多模态方法）；前向引用 Table 5
- Related Work：7 子节 → 3 子节，每节加入与本研究的衔接句
- 方法：First/Second-Layer Fusion、Implementation 三个子节降级为粗体段落引导
- 方法：Design Rationale 增补 MeSH 结构信息说明段落（R3.2）
- 方法：预处理论证增强（子词分词）（R1.13）
- 方法：UMAP/HDBSCAN 超参理由（R1.12）
- Experiment Design：新增"Computational cost and deployment considerations"段落（R1.4）
- LLM 标注：新增"Reliability and alternative labelling strategies"段落（R1.5）
- Results：Optimal Parameters and Robustness 两子节合并；消融讨论深化（R1.6）
- Discussion：Key Findings 7 段 → 3 段（R2.8）
- Limitations：增补泛化/外部验证/过拟合三点 + MeSH 结构未来工作（R1.2/R1.3/R3.2）
- R2.6 矛盾修正：摘要、Results L480、Results L551 三处"consistently outperform"改为"3/4 配置优于基线"
- Table 1：名称列错乱修正，行序对齐 Table 2
- formula→equation；Eq.(3)(4) 加 \label{eq:tc}/\label{eq:td}，正文改 \ref 引用
- 5 个表格 caption 全部重写为自包含
- Table 3 正文"ten"→"five"
- 引用错误修正：L143 数据集来源 ma_ai-powered_2025 → lezhnina_depression_2023

---

## 待办

实验代码库：`E:\aMyProject\vscodeProjects\A-Dual-Stream-Embedding-Framework-for-Topic-Modeling-in-Biomedical-Literature\experiment\`

### R1.7 统计显著性 —— ✅ 完成

- `per_topic_significance_test.py` 已修正为 **Dual PubMedBERT（双流）vs 单流基线（all-MiniLM，仅 abstract）**
- 结果：每主题 TC 均值 0.5972 vs 0.5684（+5%），Mann-Whitney U 检验 **p=0.25，不显著**
- 决定：不追加实验，如实写诚实的 brief note
- 已应用：
  - `access_JACIII.tex` Model-Specific Performance 段落已替换为诚实版本（用 `$c_v$` 数学模式）
  - `response_reviewer1.md` R1.7 已改为 ✅
  - `response_general.md` 已更新
  - 加载了 `multirow` 宏包（修复 β 表格的编译错误）
  - 编译通过，17 页

### R3.1 β 对照实验 —— ✅ 完成

- `beta_normalization_experiment.py` 已跑完
- 关键发现：语料每篇约 2 major / 12 minor 词，逐词公式下名义 β=0.4 时 major 有效权重仅约 0.13 —— R3 的意见量化后是实质问题
- β 实验重跑数值与 Table 2 有偏差、β=0.30 退化 —— 故**不用绝对值表格**
- 处理（小修分寸）：稿件克制（L180 改一个词 + β 小节改紧凑两段、相对表述、撤表格），回复信严谨（出示语料统计数字）
- `mesh_count_analysis.py` 为可复现的语料统计脚本
- 已更新：access_JACIII.tex、response_reviewer3.md、response_general.md，编译通过 17 页

### R1.9/R2.3 PDF 矢量图 —— ✅ 完成

- `generate_pdf_figures.py` 已运行，5 张 PDF 矢量图已生成到 `fig/`
- 稿件中 5 处 `\includegraphics` 已从 `.png` 改为 `.pdf`
- **退化格修复**：脚本原先把 28 个退化格（TD=1.000 单簇）画进热力图，导致 TD/TC+TD 最大值标错。已加判据 `TD≥0.999` 剔除，三张图留白这些格；剔除后最大值回到 0.6172/0.7458/1.3443，与正文一致
- 编译通过，17 页

### 运行环境

- 用 `conda activate bertopic-tut`（依赖齐全，本地 3070 笔记本足够，不需服务器）
- 当年实验在服务器跑；本地 `pubmed_search` 环境无 bertopic
