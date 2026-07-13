#!/usr/bin/env python3
"""Report document metadata and per-page layout analysis via PyMuPDF4LLM."""

import argparse
import json

import pymupdf4llm


MATH_RANGES = (
    ("\u2200", "\u22ff"),  # Mathematical Operators
    ("\u2100", "\u214f"),  # Letterlike Symbols
    ("\u2190", "\u21ff"),  # Arrows
    ("\u27c0", "\u27ef"),  # Miscellaneous Mathematical Symbols-A
    ("\u2980", "\u29ff"),  # Miscellaneous Mathematical Symbols-B
    ("\u2a00", "\u2aff"),  # Supplemental Mathematical Operators
    ("\u0370", "\u03ff"),  # Greek and Coptic
    ("\U0001d400", "\U0001d7ff"),  # Mathematical Alphanumeric Symbols
)
MATH_CHARACTERS = set("∫∑∏√∂∇∞≈≠≤≥±×÷∈∉⊂⊃∪∩∧∨¬∀∃∅")


def box_text(box: dict) -> str:
    """Collect text spans from one PyMuPDF4LLM layout box."""
    return "\n".join(
        span.get("text", "")
        for line in box.get("textlines", [])
        for span in line.get("spans", [])
    )


def math_density(text: str) -> float:
    count = sum(
        character in MATH_CHARACTERS
        or any(start <= character <= end for start, end in MATH_RANGES)
        for character in text
    )
    return round(count / max(len(text), 1), 4)


def analyze(path: str, options: dict) -> dict:
    """Analyze a document from PyMuPDF4LLM's structured JSON output."""
    data = json.loads(pymupdf4llm.to_json(path, **options))
    metadata = data.get("metadata", {})
    pages = []

    for page in data.get("pages", []):
        boxes = page.get("boxes", [])
        text = "\n".join(filter(None, (box_text(box) for box in boxes)))
        pages.append(
            {
                "page": page.get("page_number"),
                "text_length": len(text),
                "image_count": sum(box.get("image") is not None for box in boxes),
                "table_count": sum(box.get("table") is not None for box in boxes),
                "math_density": math_density(text),
                "full_page_ocr": bool(page.get("full_ocred", False)),
            }
        )

    toc = []
    for entry in data.get("toc", []):
        if len(entry) >= 3:
            toc.append({"level": entry[0], "title": entry[1], "page": entry[2]})

    return {
        "file": path,
        "page_count": data.get("page_count", len(pages)),
        "title": metadata.get("title", ""),
        "author": metadata.get("author", ""),
        "subject": metadata.get("subject", ""),
        "toc": toc,
        "pages": pages,
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Show metadata and per-page layout analysis with PyMuPDF4LLM"
    )
    parser.add_argument("path", help="Path to the PDF or other supported document")
    ocr = parser.add_mutually_exclusive_group()
    ocr.add_argument("--force-ocr", action="store_true", help="Force OCR on every page")
    ocr.add_argument("--no-ocr", action="store_true", help="Disable OCR")
    parser.add_argument("--ocr-dpi", type=int, default=300, help="OCR resolution (default: 300)")
    parser.add_argument(
        "--ocr-language", default="eng", help="Tesseract language(s), e.g. eng+fra"
    )
    args = parser.parse_args()

    options = {
        "use_ocr": not args.no_ocr,
        "force_ocr": args.force_ocr,
        "ocr_dpi": args.ocr_dpi,
        "ocr_language": args.ocr_language,
    }
    try:
        result = analyze(args.path, options)
    except (OSError, RuntimeError, ValueError, json.JSONDecodeError) as error:
        parser.error(str(error))
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
