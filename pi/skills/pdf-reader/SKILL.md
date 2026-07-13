---
name: pdf-reader
description: Read and comprehend PDF files, especially academic papers, math notes, scanned documents, tables, and multi-column layouts. Use when the user asks to read, search, analyze, summarize, or extract content from a PDF.
---

# PDF Reader

Use PyMuPDF4LLM for layout-aware Markdown, structured JSON, plain text, table detection, and selective OCR. Combine extraction with rendered-page inspection when equations, figures, or visual layout require it.

## Setup

The scripts use a virtual environment at `SKILL_DIR/.venv`. Create it once if it is missing:

```bash
python3 -m venv SKILL_DIR/.venv
SKILL_DIR/.venv/bin/pip install -r SKILL_DIR/requirements.txt
```

Always invoke a helper with the skill's interpreter:

```bash
SKILL_DIR/.venv/bin/python SKILL_DIR/scripts/<script>.py [args]
```

Resolve `SKILL_DIR` to the directory containing this `SKILL.md`.

For scanned documents, install Tesseract and the required language packs. PyMuPDF4LLM automatically OCRs only image-covered or illegible regions by default. If no OCR engine is installed, automatic OCR is disabled with a warning.

## Scripts

All page specifications are 1-indexed and accept `all`, `1-5`, `1,3,7`, or `3`.

| Script | Purpose | Key options |
|---|---|---|
| `pdf_info.py <path>` | Metadata, TOC, and per-page text/image/table/math/OCR analysis | `--force-ocr`, `--no-ocr`, `--ocr-dpi`, `--ocr-language` |
| `pdf_extract.py <path>` | Layout-aware extraction | `--pages`, `--format markdown\|text\|json`, `--output`, OCR options |
| `pdf_search.py <path> <query>` | Regex or literal search over layout-aware plain text | `--context`, `--literal`, `--case-sensitive`, OCR options |
| `pdf_render.py <path>` | Render complete pages as PNG files under `/tmp/pi-pdf-*/` | `--pages`, `--dpi` (default 150) |

Markdown is the default extraction format and usually gives the best LLM input: it preserves reading order, headings, inline formatting, lists, and detected tables. Use JSON when bounding boxes and layout elements matter, and plain text for simple processing.

## Reading Workflow

### 1. Triage every new document

Run:

```bash
SKILL_DIR/.venv/bin/python SKILL_DIR/scripts/pdf_info.py <path>
```

Use the result to assess page count, TOC, text density, tables, images, math density, and whether full-page OCR was applied.

### 2. Extract layout-aware Markdown

```bash
SKILL_DIR/.venv/bin/python SKILL_DIR/scripts/pdf_extract.py <path> --format markdown
```

PyMuPDF4LLM reconstructs natural reading order for multi-column pages and converts detected tables to GitHub-compatible Markdown. Prefer this output over raw PDF text.

- **Short documents (up to 15 pages):** extract all pages, then render all pages if figures or equations are important.
- **Medium documents (15–60 pages):** extract all pages; render pages with images, tables needing visual confirmation, high math density, or very little extracted text.
- **Long documents (60+ pages):** use the TOC and extraction for structure, then search and render only relevant sections. Offer to focus the analysis if the requested scope is too broad.

### 3. Search before targeted reading

```bash
SKILL_DIR/.venv/bin/python SKILL_DIR/scripts/pdf_search.py <path> "theorem 3.2"
SKILL_DIR/.venv/bin/python SKILL_DIR/scripts/pdf_render.py <path> --pages <page>
```

Render the matching page and, when a proof or section crosses a boundary, its neighboring pages.

### 4. Inspect visually when needed

Read rendered PNGs with the `read` tool when a page contains:

- dense or poorly extracted equations;
- diagrams, plots, or full-page figures;
- tables whose structure needs verification;
- handwriting, unusual notation, or complex spatial layout;
- low extracted text despite visible content.

Use 150 DPI normally, 200 DPI for small or dense notation, and 100 DPI only for quick structural scans. State equations in LaTeX, describe figures clearly, and cite PDF page numbers.

## OCR Controls

Default selective OCR is preferred because full-page OCR is much slower and can degrade clean digital text.

```bash
# Force OCR only when the native text layer is known to be corrupt
SKILL_DIR/.venv/bin/python SKILL_DIR/scripts/pdf_extract.py <path> --force-ocr

# Disable OCR
SKILL_DIR/.venv/bin/python SKILL_DIR/scripts/pdf_extract.py <path> --no-ocr

# Select language packs and OCR resolution
SKILL_DIR/.venv/bin/python SKILL_DIR/scripts/pdf_extract.py <path> --ocr-language eng+fra --ocr-dpi 150
```

`--force-ocr` applies to selected pages in `pdf_extract.py` and to all processed pages in the info/search helpers.

## Common Tasks

### Summarize a paper

1. Run `pdf_info.py`.
2. Extract Markdown for the full paper.
3. Read the abstract, introduction, results, and conclusion first.
4. Render key figures, equations, and ambiguous tables.
5. Provide a structured summary with page references.

### Explain a theorem or proof

1. Find it with `pdf_search.py`.
2. Extract the matching and neighboring pages.
3. Render those pages for accurate notation.
4. State the result precisely and explain the proof step by step.

### Extract structured layout

```bash
SKILL_DIR/.venv/bin/python SKILL_DIR/scripts/pdf_extract.py <path> --format json --output document.json
```

Use this when the task needs bounding boxes, element types, font details, tables, or custom downstream processing.
