# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库概述

这是一个 IEEE Access 格式的学术论文仓库，论文题目为 "Topic Modelling for Biomedical Literature Retrieval via a Dual-Stream Embedding Framework"（基于双流嵌入框架的生物医学文献检索主题建模）。该论文提出了一种双流嵌入框架，通过基于 Transformer 的编码器将非结构化文本内容与结构化的 MeSH（医学主题词表）元数据进行整合。

## 文档结构

**主 LaTeX 文件**：[access.tex](access.tex)
- 使用 `ieeeaccess` 文档类
- 包含完整论文：摘要、引言、方法论、结果、讨论和结论
- 引用参考文献文件 [tm-ref.bib](tm-ref.bib)

**关键 LaTeX 依赖包**：
- `cite`, `amsmath`, `amssymb`, `amsfonts` - 数学排版
- `graphicx` - 图片插入
- `algorithm`, `algpseudocode` - 算法格式化（注意：`algorithmic` 已禁用以避免冲突）
- `float` - 图片位置控制
- `bm` - 粗体数学符号

## 编译文档

编译 LaTeX 文档的命令：

```bash
pdflatex access.tex
bibtex access
pdflatex access.tex
pdflatex access.tex
```

需要多次运行 `pdflatex` 来解析交叉引用和参考文献引用。

## 重要技术细节

### 算法格式化
- **不要**使用 `algorithmic` 包 - 它与 `algpseudocode` 冲突
- access.tex 第 4 行已明确禁用 `algorithmic` 以防止冲突
- 使用带 `[noend]` 选项的 `algpseudocode` 来编写算法块

### 数学符号
论文使用自定义粗体数学字体配置（第 14-24 行）以确保在 IEEE Access 格式中正确渲染粗体数学符号。不要修改这个代码块。

### 核心研究内容

1. **双流嵌入框架**：通过由参数 α 和 β 控制的加权融合机制，将文本嵌入（标题/摘要）与 MeSH 术语嵌入相结合

2. **评估的模型**：
   - Dual PubMedBERT（性能最佳：TC+TD = 1.3443）
   - Hybrid PubMedBERT-BioBERT
   - Dual MiniLM（基线模型）
   - Dual BioBERT

3. **评估指标**：
   - Topic Coherence (TC) - 主题一致性，衡量语义一致性
   - Topic Diversity (TD) - 主题多样性，衡量主题间的差异性

## 参考文件

- **[tm-ref.bib](tm-ref.bib)**：包含所有论文引用的 BibTeX 参考文献库
- **[Access_Word_Template.docx](Access_Word_Template.docx)**：IEEE Access Word 模板

## 图片文件

论文包含以下可视化图片：
- `fig_tc_heatmap.png` - α-β 参数空间中的主题一致性热力图
- `fig_td_heatmap.png` - α-β 参数空间中的主题多样性热力图
- `fig_combined_heatmap.png` - 组合的 TC+TD 分数热力图
- `fig_model_comparison_bar.png` - 模型比较柱状图
- `fig_ablation_comparison.png` - 消融实验对比图

热力图文件较大（每个 26+ MB）。

## 常见修改操作

编辑论文内容时：
1. 保持 IEEE Access 格式标准
2. 保持章节编号与模板一致
3. 使用 `\cite{}` 引用 tm-ref.bib 中的条目
4. 图片引用使用 `Fig.~\ref{fig:label}` 格式
5. 表格引用使用 `Table~\ref{tab:label}` 格式
6. 公式使用 `\label{eq:name}` 标记，引用格式为 `Equation~(\ref{eq:name})`

## 作者信息

详见 [author.md](author.md)

1. **Tao Tao**（第一作者）
   - Graduate School of Science and Technology, Sophia University, Tokyo, Japan
   - Ph.D. candidate in Green Science and Engineering
   - M.Com. in Information Systems and Technology, Curtin University, 2021
   - B.S. in Food Technology and Nutrition, RMIT, 2018
   - 研究方向：topic modeling, natural language processing, biomedical informatics, machine learning
   - ORCID: 0009-0005-5277-0001

2. **Eiko Takaoka**（通讯作者/导师）
   - Department of Information and Communication Sciences, Faculty of Science and Technology, Sophia University, Tokyo, Japan
   - Visiting Professor, Open University of Japan
   - Ph.D. in Engineering, Keio University, 1996
   - Fellow, Information Processing Society of Japan; Associate Member, Science Council of Japan
   - 研究方向：medical informatics, information education, natural language processing, database
   - ORCID: 0009-0009-2199-8803

3. **Amena Mahmoud**
   - Department of Computer Science, Faculty of Computers and Information, Kafrelsheikh University, Egypt
   - Visiting Associate Professor, Sophia University, Japan
   - Associate Professor
   - 研究方向：Bioinformatics, Machine Learning, Pattern Recognition, Image Processing, Natural Language Processing
   - ORCID: 0000-0001-5415-2972

## 仓库元数据

- **发表期刊**：IEEE Access
- **DOI**：10.1109/ACCESS.2024.0429000
- **GitHub 仓库**：https://github.com/taotao3614/Topic-Modeling-via-a-Dual-Stream-Embedding-Framework
