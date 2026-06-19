# Convert the four response-letter Markdown files to clean plain text (.txt)
# for pasting into the journal's "Author Response" text boxes.
import re, os

SUB = r'C:\Users\MSI\Desktop\Paper_Submission\JACIII_Submission'
OUT = os.path.join(SUB, 'Submission_Revised', 'Response_Letters')

FILES = [
    ('response_general.md',   'Response_to_AssociateEditor.txt'),
    ('response_reviewer1.md', 'Response_to_Reviewer1.txt'),
    ('response_reviewer2.md', 'Response_to_Reviewer2.txt'),
    ('response_reviewer3.md', 'Response_to_Reviewer3.txt'),
]


def md_to_txt(md):
    out = []
    for line in md.split('\n'):
        s = line.rstrip()
        if s.strip() == '---':
            out.append('')
            continue
        s = s.replace('✅ ', '').replace('✅', '')      # drop check emoji
        s = re.sub(r'\*\*([^*]+)\*\*', r'\1', s)           # bold
        s = re.sub(r'\*([^*]+)\*', r'\1', s)               # italic
        s = re.sub(r'`([^`]+)`', r'\1', s)                 # code
        if s.startswith('## '):
            s = s[3:]
        elif s.startswith('# '):
            s = s[2:]
        if s.strip().startswith('|'):
            cells = [c.strip() for c in s.strip().strip('|').split('|')]
            if all(set(c) <= set('-: ') for c in cells):   # separator row
                continue
            s = '  ' + '  |  '.join(cells)
        out.append(s.rstrip())
    text = '\n'.join(out)
    text = re.sub(r'\n{3,}', '\n\n', text).strip() + '\n'
    return text


for src, dst in FILES:
    with open(os.path.join(SUB, src), encoding='utf-8') as f:
        md = f.read()
    with open(os.path.join(OUT, dst), 'w', encoding='utf-8') as f:
        f.write(md_to_txt(md))
    print('written:', dst)
