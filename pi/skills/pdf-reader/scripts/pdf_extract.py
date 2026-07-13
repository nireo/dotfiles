#!/usr/bin/env python3
"""Extract PDF pages with PyMuPDF4LLM as Markdown, plain text, or JSON."""

import argparse
import json
from pathlib import Path

import pymupdf4llm


def parse_pages(spec: str, total: int) -> list[int]:
    """Parse a 1-indexed page spec into a sorted list of 0-indexed pages."""
    if spec.strip().lower() == "all":
        return list(range(total))

    pages: set[int] = set()
    for raw_part in spec.split(","):
        part = raw_part.strip()
        if not part:
            raise ValueError("empty page number")
        if "-" in part:
            start_text, end_text = part.split("-", 1)
            start, end = int(start_text), int(end_text)
            if start < 1 or end < start:
                raise ValueError(f"invalid page range: {part}")
            pages.update(range(start - 1, min(end, total)))
        else:
            page = int(part)
            if page < 1:
                raise ValueError(f"invalid page number: {part}")
            if page <= total:
                pages.add(page - 1)

    if not pages:
        raise ValueError(f"page specification selects no pages (document has {total})")
    return sorted(pages)


def extraction_options(args: argparse.Namespace) -> dict:
    return {
        "use_ocr": not args.no_ocr,
        "force_ocr": args.force_ocr,
        "ocr_dpi": args.ocr_dpi,
        "ocr_language": args.ocr_language,
    }


def extract(path: str, pages: list[int], output_format: str, options: dict) -> str:
    """Return selected pages in the requested PyMuPDF4LLM format."""
    if output_format == "json":
        result = pymupdf4llm.to_json(path, pages=pages, **options)
        # Normalize formatting while preserving the full structured payload.
        return json.dumps(json.loads(result), indent=2, ensure_ascii=False)

    converter = (
        pymupdf4llm.to_markdown
        if output_format == "markdown"
        else pymupdf4llm.to_text
    )
    chunks = converter(path, pages=pages, page_chunks=True, **options)
    sections = []
    for chunk in chunks:
        page_number = chunk.get("metadata", {}).get("page_number", "?")
        sections.append(f"--- Page {page_number} ---\n{chunk.get('text', '').rstrip()}")
    return "\n\n".join(sections) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Extract layout-aware content from a document with PyMuPDF4LLM"
    )
    parser.add_argument("path", help="Path to the PDF or other supported document")
    parser.add_argument(
        "--pages", default="all", help="1-indexed pages: 'all', '1-5', '1,3,7', or '3'"
    )
    parser.add_argument(
        "--format",
        choices=("markdown", "text", "json"),
        default="markdown",
        help="Output format (default: markdown)",
    )
    parser.add_argument("--output", help="Write output to this file instead of stdout")
    ocr = parser.add_mutually_exclusive_group()
    ocr.add_argument("--force-ocr", action="store_true", help="Force OCR on selected pages")
    ocr.add_argument("--no-ocr", action="store_true", help="Disable OCR")
    parser.add_argument("--ocr-dpi", type=int, default=300, help="OCR resolution (default: 300)")
    parser.add_argument(
        "--ocr-language", default="eng", help="Tesseract language(s), e.g. eng+fra"
    )
    args = parser.parse_args()

    try:
        with pymupdf4llm.pymupdf.open(args.path) as document:
            pages = parse_pages(args.pages, len(document))
        content = extract(args.path, pages, args.format, extraction_options(args))
    except (OSError, RuntimeError, ValueError) as error:
        parser.error(str(error))

    if args.output:
        Path(args.output).write_text(content, encoding="utf-8")
        print(args.output)
    else:
        print(content, end="")


if __name__ == "__main__":
    main()
