#!/usr/bin/env python3
"""Search layout-aware plain-text extraction from document pages."""

import argparse
import re

import pymupdf4llm


def search(
    path: str,
    query: str,
    context: int,
    literal: bool,
    case_sensitive: bool,
    options: dict,
) -> int:
    """Print matching lines with page-local context; return the match count."""
    pattern = re.escape(query) if literal else query
    flags = 0 if case_sensitive else re.IGNORECASE
    regex = re.compile(pattern, flags)
    chunks = pymupdf4llm.to_text(path, page_chunks=True, **options)
    match_count = 0

    for chunk in chunks:
        lines = chunk.get("text", "").splitlines()
        matching_lines = [index for index, line in enumerate(lines) if regex.search(line)]
        if not matching_lines:
            continue

        page_number = chunk.get("metadata", {}).get("page_number", "?")
        print(f"--- Page {page_number} ---")
        printed: set[int] = set()
        for match_index in matching_lines:
            match_count += 1
            start = max(0, match_index - context)
            end = min(len(lines), match_index + context + 1)
            if printed and start > max(printed) + 1:
                print("...")
            for line_index in range(start, end):
                if line_index in printed:
                    continue
                marker = ">" if line_index == match_index else " "
                print(f"{marker} {line_index + 1:4}: {lines[line_index]}")
                printed.add(line_index)
        print()

    return match_count


def main() -> None:
    parser = argparse.ArgumentParser(description="Search document text extracted by PyMuPDF4LLM")
    parser.add_argument("path", help="Path to the PDF or other supported document")
    parser.add_argument("query", help="Regular expression (or literal text with --literal)")
    parser.add_argument("--context", type=int, default=3, help="Context lines (default: 3)")
    parser.add_argument("--literal", action="store_true", help="Treat the query as literal text")
    parser.add_argument("--case-sensitive", action="store_true", help="Use case-sensitive matching")
    ocr = parser.add_mutually_exclusive_group()
    ocr.add_argument("--force-ocr", action="store_true", help="Force OCR on every page")
    ocr.add_argument("--no-ocr", action="store_true", help="Disable OCR")
    parser.add_argument("--ocr-dpi", type=int, default=300, help="OCR resolution (default: 300)")
    parser.add_argument(
        "--ocr-language", default="eng", help="Tesseract language(s), e.g. eng+fra"
    )
    args = parser.parse_args()

    if args.context < 0:
        parser.error("--context cannot be negative")
    options = {
        "use_ocr": not args.no_ocr,
        "force_ocr": args.force_ocr,
        "ocr_dpi": args.ocr_dpi,
        "ocr_language": args.ocr_language,
    }
    try:
        count = search(
            args.path,
            args.query,
            args.context,
            args.literal,
            args.case_sensitive,
            options,
        )
    except (OSError, RuntimeError, ValueError, re.error) as error:
        parser.error(str(error))

    if count == 0:
        print("No matches found.")


if __name__ == "__main__":
    main()
