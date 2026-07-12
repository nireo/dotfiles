import { describe, expect, it } from "vitest";
import { getHunkStarts, renderCenteredOverlay } from "./review-app.js";

describe("getHunkStarts", () => {
  it("finds distinct changed chunks while keeping adjacent additions and deletions together", () => {
    expect(getHunkStarts([
      { kind: "context", oldLine: 1, newLine: 1, text: "one" },
      { kind: "deleted", oldLine: 2, newLine: null, text: "old" },
      { kind: "added", oldLine: null, newLine: 2, text: "new" },
      { kind: "context", oldLine: 3, newLine: 3, text: "three" },
      { kind: "added", oldLine: null, newLine: 4, text: "four" },
    ])).toEqual([1, 4]);
  });
});

describe("renderCenteredOverlay", () => {
  it("keeps the surrounding diff visible while centering the editor form", () => {
    expect(renderCenteredOverlay([
      "0123456789",
      "abcdefghij",
      "ABCDEFGHIJ",
    ], [
      "┌────┐",
      "│form│",
      "└────┘",
    ], 10)).toEqual([
      "01┌────┐89",
      "ab│form│ij",
      "AB└────┘IJ", 
    ]);
  });
});
