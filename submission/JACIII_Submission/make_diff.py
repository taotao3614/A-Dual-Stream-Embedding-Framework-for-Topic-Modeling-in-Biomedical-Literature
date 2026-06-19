# -*- coding: utf-8 -*-
"""
make_diff.py  --  LaTeX 修订标红工具

用途:对比修订前 (OLD) 与修订后 (NEW) 两个 .tex 文件,
      生成一个新的 *_diff.tex,本次修订新增/改动的内容用红色显示,
      方便审稿人查阅。

安全性:
  * 只读取 OLD / NEW 两个文件,绝不修改它们。
  * 只新建一个输出文件 (_diff.tex)。
  * 按 LaTeX 结构切块,保证 \\begin/\\end 环境与花括号在每个块内闭合,
    不会把 LaTeX 命令截断。
  * 表格 / 列表 / 公式等"易碎"结构遇到改动时,自动回退为整块包红。
  * 导言区 (\\begin{document} 之前) 不上色 (\\color 不允许出现在导言区)。

用法:
    python make_diff.py
  或
    python make_diff.py 旧文件.tex 新文件.tex 输出.tex

只用 Python 标准库,无需安装任何东西。
"""

import sys
import os
from difflib import SequenceMatcher

# ----------------------------------------------------------------------
# 默认文件名(与本脚本放在同一目录)
# ----------------------------------------------------------------------
OLD_DEFAULT = "access_JACIII_backup.tex"   # 修订前
NEW_DEFAULT = "access_JACIII.tex"          # 修订后(当前正式稿)
OUT_DEFAULT = "access_JACIII_diff.tex"     # 输出

RED = "red"  # 标红颜色

# 句子级标红时,遇到"易碎" token 就放弃句子级、回退为整块包红(避免破坏结构)。
# 1) \begin/\end/\item/&/\\/\hline... :单独包红会破坏环境配对、表格行、列表项。
# 2) \caption/\section 系列 :这些命令会步进计数器并(局部地)设置 \@currentlabel,
#    若单独包进颜色组,组结束后 \@currentlabel 被还原,使紧跟的 \label 抓不到
#    正确编号 -> 交叉引用失效。整块包红可让 \caption 与 \label 同处一个组内。
_FRAGILE_PREFIXES = (
    r"\begin", r"\end", r"\item", r"\\",
    r"\hline", r"\toprule", r"\midrule", r"\bottomrule",
    r"\cmidrule", r"\noalign", r"\[", r"\]",
    r"\caption", r"\section", r"\subsection", r"\subsubsection",
    r"\paragraph",
)


def is_fragile(tok):
    """判断一个 token 是否属于易碎结构(不能单独包进颜色组)。"""
    if tok == "&":
        return True
    for p in _FRAGILE_PREFIXES:
        if tok.startswith(p):
            return True
    return False


# 句子切分用到的缩写表(小写、不含末尾点)。前一个词若是这些 -> "." 不算句末。
# 单字母(如 e.g./i.e. 的 e/i/g)由长度=1 规则单独处理,不必在此列出。
_ABBREV = {
    "al", "fig", "figs", "eq", "eqs", "vs", "cf", "etc", "no", "tab",
    "ref", "sec", "vol", "approx", "ca", "dr", "mr", "ms", "mrs", "st",
    "ie", "eg", "resp", "inc", "ltd", "jr", "sr",
}

# 纯排版/骨架命令(不携带散文语义)。位于块首尾时直接剥离,不参与 diff。
# 章节标题命令(\section / \subsection ...)也算骨架:这样原稿与新稿的块结构
# 不同时(如 R2.1 删除引言子节),把旧块的 \subsection 剥掉后,剩下的散文中段
# 可以与新块的散文中段做正常的句子级 diff,只标红实际变化。
# 注意:全新的章节标题块(整块只有 \subsection{...})会通过 insert 路径找不到
# 相似旧块而被整块红——这是想要的行为。
_SKELETON_CMDS = (
    r"\noindent", r"\indent", r"\par",
    r"\bigskip", r"\medskip", r"\smallskip",
    r"\centering", r"\raggedright", r"\raggedleft",
    r"\clearpage", r"\newpage", r"\pagebreak",
    r"\vspace", r"\hspace",
    r"\section", r"\subsection", r"\subsubsection", r"\paragraph",
    r"\label",
)


def is_skeleton(tok):
    """判断一个 token 是否属于"骨架":空白、注释、环境分界(\\begin/\\end)、
    或纯排版命令。块首/块尾这类 token 不参与 diff,原样输出。"""
    if tok.strip() == "":
        return True
    if tok.startswith("%"):
        return True
    if tok.startswith("\\begin") or tok.startswith("\\end"):
        return True
    for s in _SKELETON_CMDS:
        if tok == s or tok.startswith(s + "{") or tok.startswith(s + "["):
            return True
    return False


def split_sentences(tokens):
    """把 token 列表按句子切分。每个返回项是一个 token 子列表;句末空白并入本句。
    句末判定:遇到 '.' / '!' / '?' 单字符 token 时,综合考量:
      - 后一个非空白 token 是否以小写字母开头(若是 -> 句子继续)
      - 前一个非空白词是否为缩写或单字母(若是 -> 不算句末,如 e.g.、et al.)
      - 前后皆为数字 -> 小数点
    """
    sentences = []
    cur = []
    n = len(tokens)
    i = 0
    while i < n:
        tok = tokens[i]
        cur.append(tok)
        if tok in (".", "!", "?"):
            # 前一个非空白 token
            pw = None
            for t in reversed(cur[:-1]):
                if t.strip() != "":
                    pw = t
                    break
            # 后一个非空白 token
            j = i + 1
            while j < n and tokens[j].strip() == "":
                j += 1
            nxt = tokens[j] if j < n else None

            is_end = True
            if nxt is not None and nxt:
                c0 = nxt[0]
                if c0.isalpha() and c0.islower():
                    is_end = False
                if pw is not None and pw.isdigit() and c0.isdigit():
                    is_end = False
            if pw is not None:
                pwl = pw.lower().rstrip(".")
                if pwl in _ABBREV:
                    is_end = False
                if len(pwl) == 1 and pwl.isalpha():
                    is_end = False
            if is_end:
                # 把句末标点之后的空白也并入本句
                while i + 1 < n and tokens[i + 1].strip() == "":
                    cur.append(tokens[i + 1])
                    i += 1
                sentences.append(cur)
                cur = []
        i += 1
    if cur:
        sentences.append(cur)
    return sentences


# ----------------------------------------------------------------------
# 读文件
# ----------------------------------------------------------------------
def read_text(path):
    with open(path, "r", encoding="utf-8-sig") as f:
        return f.read().replace("\r\n", "\n").replace("\r", "\n")


# ----------------------------------------------------------------------
# 工具:去掉一行里的注释部分(用于数花括号 / 环境)
# ----------------------------------------------------------------------
def strip_comment(line):
    out = []
    i = 0
    while i < len(line):
        c = line[i]
        if c == "\\" and i + 1 < len(line):
            out.append(line[i:i + 2])
            i += 2
            continue
        if c == "%":
            break
        out.append(c)
        i += 1
    return "".join(out)


def count_envs(line):
    """返回 (\\begin 数, \\end 数),不含 document 环境。"""
    import re
    code = strip_comment(line)
    begins = len([m for m in re.findall(r"\\begin\s*\{([^}]*)\}", code)
                  if m.strip() != "document"])
    ends = len([m for m in re.findall(r"\\end\s*\{([^}]*)\}", code)
                if m.strip() != "document"])
    return begins, ends


def net_braces(line):
    code = strip_comment(line)
    return code.count("{") - code.count("}")


# ----------------------------------------------------------------------
# 把正文切成"块":空行分隔,但只在环境深度=0 且花括号深度=0 时才算分隔。
# 这样每个块内部的 \begin/\end、花括号都是闭合的。
# ----------------------------------------------------------------------
def split_blocks(text):
    lines = text.split("\n")
    blocks = []
    cur = []
    env_depth = 0
    brace_depth = 0
    for line in lines:
        if line.strip() == "" and env_depth <= 0 and brace_depth <= 0:
            if cur:
                blocks.append("\n".join(cur))
                cur = []
            continue
        cur.append(line)
        b, e = count_envs(line)
        env_depth += b - e
        if env_depth < 0:
            env_depth = 0
        brace_depth += net_braces(line)
        if brace_depth < 0:
            brace_depth = 0
    if cur:
        blocks.append("\n".join(cur))
    return blocks


def normalize(block):
    """把块压成一行、合并空白,用于判断两块是否"实质相同"(忽略重新换行)。"""
    return " ".join(block.split())


# ----------------------------------------------------------------------
# 把正文拆成 "主体" + "文末事务性内容"。
# 参考文献、致谢类条目、作者简介等不属于审稿修订内容,且两版文件用的命令
# 不同(\section* vs \acknowledgments 等),不应标红 —— 整段原样输出。
# ----------------------------------------------------------------------
_ENDMATTER_MARKERS = (
    "\\bibliographystyle", "\\bibliography",
    "\\acknowledgments", "\\acknowledgment",
    "\\section*{Data Availability", "\\section*{Acknowled",
    "\\section*{Conflict",
)


def split_endmatter(body):
    lines = body.split("\n")
    for idx, ln in enumerate(lines):
        st = ln.strip()
        if any(st.startswith(m) for m in _ENDMATTER_MARKERS):
            return "\n".join(lines[:idx]), "\n".join(lines[idx:])
    return body, ""


# ----------------------------------------------------------------------
# LaTeX 词法切分:把一段文本切成 token
#   * \命令[...]{...}  -> 命令连同其紧跟的 * / [可选参] / {参数} 作为一个整体 token
#                         (这样染色时整体包在外面,绝不会插进参数内部)
#   * {...} 平衡组      -> 一个 token
#   * $...$ 行内公式    -> 一个 token
#   * %注释            -> 一个 token(到行尾)
#   * 连续字母数字     -> 一个 token
#   * 空白             -> 一个 token
#   * 其它单字符       -> 一个 token
# ----------------------------------------------------------------------
def tokenize(s):
    tokens = []
    i = 0
    n = len(s)

    def read_group(start):
        """s[start]=='{',返回匹配 '}' 之后的下标;不平衡返回 -1。"""
        depth = 0
        j = start
        while j < n:
            if s[j] == "\\" and j + 1 < n:
                j += 2
                continue
            if s[j] == "{":
                depth += 1
            elif s[j] == "}":
                depth -= 1
                if depth == 0:
                    return j + 1
            j += 1
        return -1

    def read_optarg(start):
        """s[start]=='[',返回匹配 ']' 之后的下标(花括号深度为0处);找不到返回 -1。"""
        depth = 0
        j = start + 1
        while j < n:
            if s[j] == "\\" and j + 1 < n:
                j += 2
                continue
            if s[j] == "{":
                depth += 1
            elif s[j] == "}":
                depth -= 1
            elif s[j] == "]" and depth == 0:
                return j + 1
            j += 1
        return -1

    while i < n:
        c = s[i]
        if c == "%":
            j = s.find("\n", i)
            if j == -1:
                j = n
            tokens.append(s[i:j])
            i = j
        elif c == "\\":
            # 控制序列名
            if i + 1 < n and s[i + 1].isalpha():
                j = i + 1
                while j < n and s[j].isalpha():
                    j += 1
            elif i + 1 < n:
                j = i + 2
            else:
                j = i + 1
            # 吸收紧跟的参数:* / [可选参] / {参数}(允许中间有空白)
            while j < n:
                k = j
                while k < n and s[k].isspace():
                    k += 1
                if k < n and s[k] == "*":
                    j = k + 1
                elif k < n and s[k] == "{":
                    e = read_group(k)
                    if e == -1:
                        break
                    j = e
                elif k < n and s[k] == "[":
                    e = read_optarg(k)
                    if e == -1:
                        break
                    j = e
                else:
                    break
            tokens.append(s[i:j])
            i = j
        elif c == "{":
            e = read_group(i)
            if e == -1:
                tokens.append(c)
                i += 1
            else:
                tokens.append(s[i:e])
                i = e
        elif c == "$":
            j = i + 1
            if j < n and s[j] == "$":
                k = s.find("$$", j + 1)
                j = (k + 2) if k != -1 else n
            else:
                while j < n:
                    if s[j] == "\\" and j + 1 < n:
                        j += 2
                        continue
                    if s[j] == "$":
                        j += 1
                        break
                    j += 1
            tokens.append(s[i:j])
            i = j
        elif c.isspace():
            j = i
            while j < n and s[j].isspace():
                j += 1
            tokens.append(s[i:j])
            i = j
        elif c.isalnum():
            j = i
            while j < n and s[j].isalnum():
                j += 1
            tokens.append(s[i:j])
            i = j
        else:
            tokens.append(c)
            i += 1
    return tokens


def is_space(tok):
    return tok.strip() == ""


# ----------------------------------------------------------------------
# 整块包红:外层套 {\color{red} ... } 分组(开头 %吃换行,结尾 } 单独成行)。
# 注意:浮动环境(table / figure / algorithm)的内容(caption / cells)会被
#       fujipressarticle 类延迟排版,且 \caption 强制使用黑色——外层颜色
#       到那时已失效。曾尝试在 \begin{X}[...] 后注入 \color{red} 让内容变红,
#       但 caption 仍是黑、反而让未改动的数据行/表头变红,容易误导审稿人。
#       因此回退为统一的外层包法:浮动环境在 PDF 里不会呈现红色,审稿人
#       不会被表格/图的"虚假红色"误导;具体哪些图表 caption 改了,在回复
#       信里手动列出即可。
# ----------------------------------------------------------------------
def wrap_block(block):
    return "{\\color{" + RED + "}%\n" + block + "\n}%"


# ----------------------------------------------------------------------
# 句子级精修:对一对"改动块"做句子级 diff,改动的句子整句包红。
# 流程:
#   1. tokenize 老块和新块。
#   2. 剥皮:去掉首尾的骨架 token(空白/注释/\begin/\end/排版命令),
#      它们不参与 diff,原样输出。
#   3. 若剥皮后中段仍含易碎结构(表格、列表、标题、caption、公式分隔等),
#      不是纯散文 -> 整块包红。
#   4. 否则按句号/问号/感叹号切句,做句子级 SequenceMatcher diff,
#      变了或新增的句子整句包红,未变的句子保持黑色。
# ----------------------------------------------------------------------
def refine_block(old_block, new_block):
    ot = tokenize(old_block)
    nt = tokenize(new_block)

    def peel(tokens):
        """从首尾各自剥掉骨架 token,返回 (lead, mid, tail)。"""
        a = 0
        b = len(tokens)
        while a < b and is_skeleton(tokens[a]):
            a += 1
        while b > a and is_skeleton(tokens[b - 1]):
            b -= 1
        return tokens[:a], tokens[a:b], tokens[b:]

    o_lead, o_mid, o_tail = peel(ot)
    n_lead, n_mid, n_tail = peel(nt)

    # 中段若仍含易碎结构或注释 -> 不是纯散文,整块包红
    def has_fragile_or_comment(toks):
        for t in toks:
            if is_fragile(t) or t.startswith("%"):
                return True
        return False

    if has_fragile_or_comment(n_mid) or has_fragile_or_comment(o_mid):
        return wrap_block(new_block)

    # 中段为空(整块只有骨架,如 \subsection{...} 单行块):
    # 若骨架内容相对旧块发生变化(如子节改名)-> 整块红;否则原样输出。
    if not n_mid:
        if normalize(new_block) != normalize(old_block):
            return wrap_block(new_block)
        return "".join(nt)

    # 句子级 diff
    old_sents = split_sentences(o_mid)
    new_sents = split_sentences(n_mid)
    old_keys = [normalize("".join(s)) for s in old_sents]
    new_keys = [normalize("".join(s)) for s in new_sents]
    sm = SequenceMatcher(None, old_keys, new_keys, autojunk=False)

    body_pieces = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            for s in new_sents[j1:j2]:
                body_pieces.append("".join(s))
        elif tag == "delete":
            continue
        else:  # insert / replace -> 整句包红
            for s in new_sents[j1:j2]:
                text = "".join(s)
                # 把句首/句末空白挪到颜色组外,组内只包实质内容
                lead_len = len(text) - len(text.lstrip())
                lead = text[:lead_len]
                rest = text[lead_len:]
                core = rest.rstrip()
                trail = rest[len(core):]
                if core.strip():
                    body_pieces.append(
                        lead + "{\\color{" + RED + "}" + core + "}" + trail)
                else:
                    body_pieces.append(text)

    return "".join(n_lead) + "".join(body_pieces) + "".join(n_tail)


# ----------------------------------------------------------------------
# 主流程
# ----------------------------------------------------------------------
def main():
    args = sys.argv[1:]
    here = os.path.dirname(os.path.abspath(__file__))
    old_path = args[0] if len(args) > 0 else os.path.join(here, OLD_DEFAULT)
    new_path = args[1] if len(args) > 1 else os.path.join(here, NEW_DEFAULT)
    out_path = args[2] if len(args) > 2 else os.path.join(here, OUT_DEFAULT)

    for p in (old_path, new_path):
        if not os.path.isfile(p):
            print("[错误] 找不到文件:", p)
            sys.exit(1)

    old_text = read_text(old_path)
    new_text = read_text(new_path)

    # --- 找 \begin{document} 切分 导言区 / 正文 ---
    def split_preamble(text, label):
        lines = text.split("\n")
        for idx, ln in enumerate(lines):
            if ln.strip().startswith("\\begin{document}"):
                preamble = "\n".join(lines[:idx + 1])
                body = "\n".join(lines[idx + 1:])
                return preamble, body
        print("[错误] 在 %s 中找不到 \\begin{document}" % label)
        sys.exit(1)

    new_preamble, new_body = split_preamble(new_text, new_path)
    _old_preamble, old_body = split_preamble(old_text, old_path)

    # --- 在 diff 文件导言区注入 xcolor(若尚未加载)---
    if "xcolor" not in new_preamble and "{color}" not in new_preamble:
        pre_lines = new_preamble.split("\n")
        for idx, ln in enumerate(pre_lines):
            if ln.strip().startswith("\\begin{document}"):
                pre_lines.insert(
                    idx,
                    "\\usepackage{xcolor}  % [diff] 用于修订标红")
                break
        new_preamble = "\n".join(pre_lines)

    # --- 分离文末事务性内容(不标红,原样输出)---
    new_main, new_end = split_endmatter(new_body)
    old_main, _old_end = split_endmatter(old_body)

    # --- 切块 + diff(只对主体)---
    new_blocks = split_blocks(new_main)
    old_blocks = split_blocks(old_main)
    sm = SequenceMatcher(None,
                         [normalize(b) for b in old_blocks],
                         [normalize(b) for b in new_blocks],
                         autojunk=False)

    # 预计算所有旧块的归一化,供相似度匹配
    old_norm_all = [normalize(b) for b in old_blocks]

    # 第一遍:把 equal opcode 配对到的旧块标记为已用(它们是 100% 命中)
    used_old = set()
    opcodes = sm.get_opcodes()
    for tag, i1, i2, j1, j2 in opcodes:
        if tag == "equal":
            for k in range(i1, i2):
                used_old.add(k)

    SIM_THRESHOLD = 0.5  # 相似度阈值

    def find_best(nb_norm, candidates):
        best_k = -1
        best_r = 0.0
        for k in candidates:
            r = SequenceMatcher(None, old_norm_all[k], nb_norm).ratio()
            if r > best_r:
                best_r = r
                best_k = k
        return best_k, best_r

    out_blocks = []
    n_equal = n_insert = n_replace = 0
    for tag, i1, i2, j1, j2 in opcodes:
        if tag == "equal":
            out_blocks.extend(new_blocks[j1:j2])
            n_equal += (j2 - j1)
        elif tag == "delete":
            continue  # 删掉的内容不出现在新稿,跳过
        elif tag in ("insert", "replace"):
            # insert / replace 共用同一逻辑:对每个新块,在"未用"的旧块里按相似度配对。
            # 优先在 opcode 的本地 [i1:i2] 找(若是 replace 才有本地候选),
            # 找不到再扩到全文未用旧块。
            # 这样即使原文有重构(原 4 子节 -> 新连贯叙述)导致块级 diff 把段落判成 insert,
            # 也能在全文找到对应的旧段落,做句子级标红而非整块红。
            for nb in new_blocks[j1:j2]:
                nb_norm = normalize(nb)
                local_cand = [k for k in range(i1, i2) if k not in used_old]
                best_k, best_r = find_best(nb_norm, local_cand)
                if best_k < 0 or best_r < SIM_THRESHOLD:
                    global_cand = [k for k in range(len(old_blocks))
                                   if k not in used_old]
                    best_k, best_r = find_best(nb_norm, global_cand)
                if best_k >= 0 and best_r >= SIM_THRESHOLD:
                    used_old.add(best_k)
                    out_blocks.append(refine_block(old_blocks[best_k], nb))
                else:
                    out_blocks.append(wrap_block(nb))
            if tag == "insert":
                n_insert += (j2 - j1)
            else:
                n_replace += (j2 - j1)

    output = new_preamble + "\n\n" + "\n\n".join(out_blocks) + "\n"
    if new_end.strip():
        output += "\n" + new_end.strip("\n") + "\n"

    with open(out_path, "w", encoding="utf-8") as f:
        f.write(output)

    print("=" * 60)
    print("完成!输出文件:", out_path)
    print("-" * 60)
    print("正文块统计:")
    print("  未改动块 :", n_equal)
    print("  新增块   :", n_insert, " (整块标红)")
    print("  改动块   :", n_replace, " (句子级标红,易碎结构回退整块)")
    print("=" * 60)
    print("下一步,在本目录依次运行编译命令:")
    print("  lualatex access_JACIII_diff.tex")
    print("  bibtex   access_JACIII_diff")
    print("  lualatex access_JACIII_diff.tex")
    print("  lualatex access_JACIII_diff.tex")
    print("=" * 60)


if __name__ == "__main__":
    main()
