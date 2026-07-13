#!/usr/bin/env python3
"""Render document pages to PNG using PyMuPDF4LLM's bundled MuPDF backend."""

import argparse
import hashlib
import os

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


def render(path: str, page_spec: str = "all", dpi: int = 150) -> list[str]:
    """Render selected pages with the backend version managed by PyMuPDF4LLM."""
    if dpi <= 0:
        raise ValueError("DPI must be positive")

    backend = pymupdf4llm.pymupdf
    with backend.open(path) as document:
        pages = parse_pages(page_spec, len(document))
        stat = os.stat(path)
        cache_key = f"{os.path.abspath(path)}:{stat.st_size}:{stat.st_mtime_ns}:{dpi}"
        file_hash = hashlib.sha256(cache_key.encode()).hexdigest()[:10]
        output_dir = os.path.join("/tmp", f"pi-pdf-{file_hash}")
        os.makedirs(output_dir, exist_ok=True)

        matrix = backend.Matrix(dpi / 72.0, dpi / 72.0)
        output_paths = []
        for page_index in pages:
            pixmap = document[page_index].get_pixmap(matrix=matrix, alpha=False)
            output_path = os.path.join(output_dir, f"page_{page_index + 1:04d}.png")
            pixmap.save(output_path)
            output_paths.append(output_path)
            print(f"Page {page_index + 1} -> {output_path}")

    return output_paths


def main() -> None:
    parser = argparse.ArgumentParser(description="Render document pages to PNG")
    parser.add_argument("path", help="Path to the PDF or other supported document")
    parser.add_argument(
        "--pages", default="all", help="1-indexed pages: 'all', '1-5', '1,3,7', or '3'"
    )
    parser.add_argument("--dpi", type=int, default=150, help="Render resolution (default: 150)")
    args = parser.parse_args()

    try:
        render(args.path, args.pages, args.dpi)
    except (OSError, RuntimeError, ValueError) as error:
        parser.error(str(error))


if __name__ == "__main__":
    main()
