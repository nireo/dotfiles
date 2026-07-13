import type { Theme } from "@earendil-works/pi-coding-agent";
import type { TUI } from "@earendil-works/pi-tui";
import { describe, expect, it } from "vitest";
import { getHunkStarts, renderCenteredOverlay, runDiscussionReview } from "./review-app.js";

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

describe("diff navigation", () => {
  it("moves down onto context lines instead of skipping to the next change", async () => {
    type ReviewHarness = {
      handleInput(data: string): void;
      render(width: number): string[];
    };

    let app: ReviewHarness | undefined;
    const tui = {
      terminal: { rows: 24 },
      requestRender() {},
    } as unknown as TUI;
    const theme = {
      fg: (_color: string, text: string) => text,
      bg: (_color: string, text: string) => text,
      bold: (text: string) => text,
    } as unknown as Theme;
    const context = {
      ui: {
        custom(factory: (tui: TUI, theme: Theme, keybindings: unknown, done: (value: null) => void) => ReviewHarness) {
          app = factory(tui, theme, {}, () => {});
          return Promise.resolve(undefined);
        },
      },
    } as unknown as Parameters<typeof runDiscussionReview>[0];

    await runDiscussionReview(context, {
      repoRoot: "/repo",
      skippedFiles: 0,
      files: [{
        path: "example.ts",
        oldPath: null,
        status: "M",
        rows: [
          { kind: "context", oldLine: 1, newLine: 1, text: "before" },
          { kind: "added", oldLine: null, newLine: 2, text: "changed" },
          { kind: "context", oldLine: 2, newLine: 3, text: "after" },
          { kind: "added", oldLine: null, newLine: 4, text: "later change" },
        ],
      }],
    });

    expect(app).toBeDefined();
    app!.handleInput("\x1b[C");
    app!.handleInput("\x1b[B");
    app!.handleInput("f");
    expect(app!.render(100).some((line) => line.includes("Select an added or deleted line first."))).toBe(true);
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
