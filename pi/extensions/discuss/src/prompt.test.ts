import { describe, expect, it } from "vitest";
import { composeDiscussionPrompt } from "./prompt.js";

describe("composeDiscussionPrompt", () => {
  it("keeps fixes and questions separate with precise locations", () => {
    const prompt = composeDiscussionPrompt([
      {
        id: "one",
        filePath: "src/index.ts",
        side: "added",
        line: 12,
        intent: "fix",
        body: "Handle the error case.",
      },
      {
        id: "two",
        filePath: "src/config.ts",
        side: "file",
        line: null,
        intent: "question",
        body: "Why is this configuration global?",
      },
    ]);

    expect(prompt).toContain("FIX");
    expect(prompt).toContain("src/index.ts:12 (added)");
    expect(prompt).toContain("QUESTIONS");
    expect(prompt).toContain("src/config.ts");
    expect(prompt).toContain("Do not change code merely to answer a question.");
  });
});
