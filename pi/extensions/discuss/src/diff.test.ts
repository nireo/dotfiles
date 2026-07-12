import { describe, expect, it } from "vitest";
import { buildDiffRows } from "./diff.js";

describe("buildDiffRows", () => {
  it("preserves line numbers for deleted and added content", () => {
    expect(buildDiffRows("alpha\nold\nomega\n", "alpha\nnew\nomega\n")).toEqual([
      { kind: "context", oldLine: 1, newLine: 1, text: "alpha" },
      { kind: "deleted", oldLine: 2, newLine: null, text: "old" },
      { kind: "added", oldLine: null, newLine: 2, text: "new" },
      { kind: "context", oldLine: 3, newLine: 3, text: "omega" },
    ]);
  });

  it("retains context before and after distant changes", () => {
    const rows = buildDiffRows("a\nb\nc\nd\ne\n", "a\nB\nc\nd\nE\n");

    expect(rows).toMatchObject([
      { kind: "context", oldLine: 1, newLine: 1, text: "a" },
      { kind: "deleted", oldLine: 2, text: "b" },
      { kind: "added", newLine: 2, text: "B" },
      { kind: "context", oldLine: 3, newLine: 3, text: "c" },
      { kind: "context", oldLine: 4, newLine: 4, text: "d" },
      { kind: "deleted", oldLine: 5, text: "e" },
      { kind: "added", newLine: 5, text: "E" },
    ]);
  });
});
