// Convert the four response-letter Markdown files to Word .docx
const fs = require('fs');
const path = require('path');
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  AlignmentType, LevelFormat, HeadingLevel, BorderStyle, WidthType, ShadingType,
} = require('docx');

const SUB = 'C:/Users/MSI/Desktop/Paper_Submission/JACIII_Submission';
const OUT = SUB + '/Submission_Revised/Response_Letters';
fs.mkdirSync(OUT, { recursive: true });

const FILES = [
  ['response_general.md',   'Response_to_AssociateEditor.docx'],
  ['response_reviewer1.md', 'Response_to_Reviewer1.docx'],
  ['response_reviewer2.md', 'Response_to_Reviewer2.docx'],
  ['response_reviewer3.md', 'Response_to_Reviewer3.docx'],
];

const TABLE_WIDTH = 9360; // US Letter, 1" margins

// ---- inline parser: **bold**, *italic*, `code` ----
function parseInline(text) {
  text = text.replace(/✅/g, '').replace(/[ \t]{2,}/g, ' ').trim();
  const runs = [];
  const re = /(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`)/g;
  let last = 0, m;
  while ((m = re.exec(text)) !== null) {
    if (m.index > last) runs.push(new TextRun(text.slice(last, m.index)));
    const tok = m[0];
    if (tok.startsWith('**')) runs.push(new TextRun({ text: tok.slice(2, -2), bold: true }));
    else if (tok.startsWith('`')) runs.push(new TextRun({ text: tok.slice(1, -1), font: 'Consolas' }));
    else runs.push(new TextRun({ text: tok.slice(1, -1), italics: true }));
    last = m.index + tok.length;
  }
  if (last < text.length) runs.push(new TextRun(text.slice(last)));
  if (runs.length === 0) runs.push(new TextRun(''));
  return runs;
}

function isSpecialStart(line) {
  const t = line.trimStart();
  return t === '' || t === '---' || t.startsWith('#') || t.startsWith('|') ||
         t.startsWith('*') || /^-\s+/.test(t) || /^\d+\.\s+/.test(t);
}

function splitRow(line) {
  let cells = line.split('|').map(c => c.trim());
  if (cells.length && cells[0] === '') cells.shift();
  if (cells.length && cells[cells.length - 1] === '') cells.pop();
  return cells;
}

function buildTable(tblLines) {
  const header = splitRow(tblLines[0]);
  const rows = tblLines.slice(2).map(splitRow);
  const ncol = header.length;
  const base = Math.floor(TABLE_WIDTH / ncol);
  const colW = Array(ncol).fill(base);
  colW[ncol - 1] = TABLE_WIDTH - base * (ncol - 1);
  const b = { style: BorderStyle.SINGLE, size: 1, color: 'CCCCCC' };
  const borders = { top: b, bottom: b, left: b, right: b };
  const mk = (text, w, header) => new TableCell({
    borders,
    width: { size: w, type: WidthType.DXA },
    shading: header ? { fill: 'D5E8F0', type: ShadingType.CLEAR } : undefined,
    margins: { top: 80, bottom: 80, left: 120, right: 120 },
    children: [new Paragraph({
      children: header ? [new TextRun({ text, bold: true })] : parseInline(text),
    })],
  });
  const trs = [new TableRow({ children: header.map((h, j) => mk(h, colW[j], true)) })];
  for (const r of rows) {
    const cells = [];
    for (let j = 0; j < ncol; j++) cells.push(mk(r[j] || '', colW[j], false));
    trs.push(new TableRow({ children: cells }));
  }
  return new Table({
    width: { size: TABLE_WIDTH, type: WidthType.DXA },
    columnWidths: colW, rows: trs,
  });
}

function convert(md) {
  const lines = md.split(/\r?\n/);
  const out = [];
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    const t = line.trim();
    if (t === '' || t === '---') { i++; continue; }

    if (t.startsWith('|')) {
      const tbl = [];
      while (i < lines.length && lines[i].trim().startsWith('|')) { tbl.push(lines[i]); i++; }
      out.push(buildTable(tbl));
      continue;
    }
    if (line.startsWith('# ')) {
      out.push(new Paragraph({ heading: HeadingLevel.HEADING_1, children: parseInline(line.slice(2)) }));
      i++; continue;
    }
    if (line.startsWith('## ')) {
      out.push(new Paragraph({ heading: HeadingLevel.HEADING_2, children: parseInline(line.slice(3)) }));
      i++; continue;
    }
    if (/^\s*-\s+/.test(line)) {
      let txt = line.replace(/^\s*-\s+/, '');
      while (i + 1 < lines.length && !isSpecialStart(lines[i + 1])) { txt += ' ' + lines[i + 1].trim(); i++; }
      out.push(new Paragraph({ numbering: { reference: 'bullets', level: 0 }, children: parseInline(txt) }));
      i++; continue;
    }
    if (/^\s*\d+\.\s+/.test(line)) {
      let txt = line.replace(/^\s*\d+\.\s+/, '');
      while (i + 1 < lines.length && !isSpecialStart(lines[i + 1])) { txt += ' ' + lines[i + 1].trim(); i++; }
      out.push(new Paragraph({ numbering: { reference: 'numbers', level: 0 },
        spacing: { after: 80 }, children: parseInline(txt) }));
      i++; continue;
    }
    // normal paragraph (may start with ** or *) — gather soft-wrapped continuation
    let txt = t;
    const isQuote = t.startsWith('*"') || t.startsWith('*“');
    while (i + 1 < lines.length && !isSpecialStart(lines[i + 1])) { txt += ' ' + lines[i + 1].trim(); i++; }
    out.push(new Paragraph({
      spacing: { after: 140 },
      indent: isQuote ? { left: 420 } : undefined,
      children: parseInline(txt),
    }));
    i++;
  }
  return out;
}

function makeDoc(children) {
  return new Document({
    styles: {
      default: { document: { run: { font: 'Arial', size: 22 } } },
      paragraphStyles: [
        { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { size: 30, bold: true, font: 'Arial' },
          paragraph: { spacing: { before: 120, after: 240 }, outlineLevel: 0 } },
        { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { size: 25, bold: true, font: 'Arial' },
          paragraph: { spacing: { before: 240, after: 120 }, outlineLevel: 1 } },
      ],
    },
    numbering: {
      config: [
        { reference: 'bullets', levels: [{ level: 0, format: LevelFormat.BULLET, text: '•',
          alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 540, hanging: 280 } } } }] },
        { reference: 'numbers', levels: [{ level: 0, format: LevelFormat.DECIMAL, text: '%1.',
          alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 540, hanging: 280 } } } }] },
      ],
    },
    sections: [{
      properties: {
        page: {
          size: { width: 12240, height: 15840 },
          margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 },
        },
      },
      children,
    }],
  });
}

(async () => {
  for (const [src, dst] of FILES) {
    const md = fs.readFileSync(path.join(SUB, src), 'utf8');
    const doc = makeDoc(convert(md));
    const buf = await Packer.toBuffer(doc);
    fs.writeFileSync(path.join(OUT, dst), buf);
    console.log('written:', dst);
  }
})();
