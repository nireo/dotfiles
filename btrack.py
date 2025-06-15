#!/usr/bin/env python3
"""
PDF Book Progress Tracker
A command-line tool to track reading progress in PDF books using content hashing.
"""

import argparse
import hashlib
import json
import os
import sys
from datetime import datetime
from pathlib import Path


class BookTracker:
    def __init__(self, data_file="book_progress.json"):
        self.data_file = Path.home() / ".config" / "book_tracker" / data_file
        self.data_file.parent.mkdir(parents=True, exist_ok=True)
        self.books = self.load_data()

    def load_data(self):
        """Load book data from JSON file."""
        if self.data_file.exists():
            try:
                with open(self.data_file, "r") as f:
                    return json.load(f)
            except (json.JSONDecodeError, IOError):
                print(f"Warning: Could not read {self.data_file}. Starting fresh.")
        return {}

    def save_data(self):
        """Save book data to JSON file."""
        try:
            with open(self.data_file, "w") as f:
                json.dump(self.books, f, indent=2)
        except IOError as e:
            print(f"Error saving data: {e}")
            sys.exit(1)

    def hash_pdf(self, file_path):
        """Generate SHA-256 hash of PDF file content."""
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File not found: {file_path}")

        if not file_path.lower().endswith(".pdf"):
            raise ValueError("File must be a PDF")

        hasher = hashlib.sha256()
        try:
            with open(file_path, "rb") as f:
                # Read in chunks to handle large files
                for chunk in iter(lambda: f.read(4096), b""):
                    hasher.update(chunk)
        except IOError as e:
            raise IOError(f"Could not read file: {e}")

        return hasher.hexdigest()

    def add_book(self, file_path, title=None):
        """Add a new book to the tracker."""
        try:
            file_hash = self.hash_pdf(file_path)

            if file_hash in self.books:
                print(f"Book already exists: {self.books[file_hash]['title']}")
                return False

            # Use filename as title if not provided
            if not title:
                title = Path(file_path).stem

            self.books[file_hash] = {
                "title": title,
                "current_page": 1,
                "total_pages": None,
                "added_date": datetime.now().isoformat(),
                "last_updated": datetime.now().isoformat(),
                "original_path": str(Path(file_path).absolute()),
            }

            self.save_data()
            print(f"Added book: {title}")
            return True

        except (FileNotFoundError, ValueError, IOError) as e:
            print(f"Error adding book: {e}")
            return False

    def set_page(self, file_path, page):
        """Set current page for a book."""
        try:
            file_hash = self.hash_pdf(file_path)

            if file_hash not in self.books:
                print("Book not found. Add it first with 'add' command.")
                return False

            if page < 1:
                print("Page number must be positive.")
                return False

            self.books[file_hash]["current_page"] = page
            self.books[file_hash]["last_updated"] = datetime.now().isoformat()

            self.save_data()
            print(f"Set page {page} for '{self.books[file_hash]['title']}'")
            return True

        except (FileNotFoundError, ValueError, IOError) as e:
            print(f"Error setting page: {e}")
            return False

    def get_progress(self, file_path):
        """Get current progress for a book."""
        try:
            file_hash = self.hash_pdf(file_path)

            if file_hash not in self.books:
                print("Book not found in tracker.")
                return None

            book = self.books[file_hash]
            print(f"\nBook: {book['title']}")
            print(f"Current page: {book['current_page']}")
            if book["total_pages"]:
                progress = (book["current_page"] / book["total_pages"]) * 100
                print(f"Total pages: {book['total_pages']}")
                print(f"Progress: {progress:.1f}%")
            print(f"Last updated: {book['last_updated'][:19].replace('T', ' ')}")
            return book

        except (FileNotFoundError, ValueError, IOError) as e:
            print(f"Error getting progress: {e}")
            return None

    def list_books(self):
        """List all tracked books."""
        if not self.books:
            print("No books in tracker.")
            return

        print("\nTracked Books:")
        print("-" * 80)

        for book_hash, book in self.books.items():
            title = (
                book["title"][:40] + "..." if len(book["title"]) > 40 else book["title"]
            )
            page_info = f"Page {book['current_page']}"
            if book["total_pages"]:
                progress = (book["current_page"] / book["total_pages"]) * 100
                page_info += f"/{book['total_pages']} ({progress:.1f}%)"

            last_read = book["last_updated"][:10]  # Just the date
            print(f"{title:<45} {page_info:<20} {last_read}")

    def delete_book(self, file_path):
        """Delete a book from the tracker."""
        try:
            file_hash = self.hash_pdf(file_path)

            if file_hash not in self.books:
                print("Book not found in tracker.")
                return False

            title = self.books[file_hash]["title"]
            del self.books[file_hash]
            self.save_data()
            print(f"Deleted book: {title}")
            return True

        except (FileNotFoundError, ValueError, IOError) as e:
            print(f"Error deleting book: {e}")
            return False

    def set_total_pages(self, file_path, total_pages):
        """Set total pages for a book."""
        try:
            file_hash = self.hash_pdf(file_path)

            if file_hash not in self.books:
                print("Book not found. Add it first with 'add' command.")
                return False

            if total_pages < 1:
                print("Total pages must be positive.")
                return False

            self.books[file_hash]["total_pages"] = total_pages
            self.books[file_hash]["last_updated"] = datetime.now().isoformat()

            self.save_data()
            print(
                f"Set total pages to {total_pages} for '{self.books[file_hash]['title']}'"
            )
            return True

        except (FileNotFoundError, ValueError, IOError) as e:
            print(f"Error setting total pages: {e}")
            return False


def main():
    parser = argparse.ArgumentParser(description="Track reading progress in PDF books")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    add_parser = subparsers.add_parser("add", help="Add a book to tracker")
    add_parser.add_argument("file", help="Path to PDF file")
    add_parser.add_argument("-t", "--title", help="Custom title for the book")

    page_parser = subparsers.add_parser("page", help="Set current page")
    page_parser.add_argument("file", help="Path to PDF file")
    page_parser.add_argument("page", type=int, help="Current page number")

    progress_parser = subparsers.add_parser("progress", help="Get reading progress")
    progress_parser.add_argument("file", help="Path to PDF file")

    subparsers.add_parser("list", help="List all tracked books")

    delete_parser = subparsers.add_parser("delete", help="Delete a book from tracker")
    delete_parser.add_argument("file", help="Path to PDF file")

    total_parser = subparsers.add_parser("total", help="Set total pages for a book")
    total_parser.add_argument("file", help="Path to PDF file")
    total_parser.add_argument("pages", type=int, help="Total number of pages")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    tracker = BookTracker()

    if args.command == "add":
        tracker.add_book(args.file, args.title)
    elif args.command == "page":
        tracker.set_page(args.file, args.page)
    elif args.command == "progress":
        tracker.get_progress(args.file)
    elif args.command == "list":
        tracker.list_books()
    elif args.command == "delete":
        tracker.delete_book(args.file)
    elif args.command == "total":
        tracker.set_total_pages(args.file, args.pages)


if __name__ == "__main__":
    main()
