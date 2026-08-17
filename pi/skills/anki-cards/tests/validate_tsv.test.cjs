const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawnSync } = require("node:child_process");
const test = require("node:test");

const validator = path.resolve(__dirname, "../scripts/validate_tsv.cjs");

function validate(content) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "anki-tsv-"));
  const file = path.join(directory, "cards.tsv");
  fs.writeFileSync(file, content, "utf8");
  const result = spawnSync(process.execPath, [validator, file], { encoding: "utf8" });
  fs.rmSync(directory, { recursive: true, force: true });
  return result;
}

test("accepts a two-field TSV with balanced MathJax", () => {
  const result = validate(
    "Write the vector sum \\(v+w\\).\tAdd corresponding components: \\((v_1+w_1, v_2+w_2)\\).\n",
  );
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /OK: 1 card/);
});

test("rejects extra TSV columns", () => {
  const result = validate("Question\tAnswer\tUnexpected\n");
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /exactly one tab/);
});

test("rejects unbalanced MathJax", () => {
  const result = validate("What is \\(x?\tA variable\n");
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /unclosed MathJax/);
});

test("rejects Markdown inside card fields", () => {
  const result = validate("What is **bold**?\tMarkdown syntax\n");
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Markdown syntax/);
});

test("treats a literal Front<TAB>Back first line as a card, not a header", () => {
  const result = validate("Front\tBack\nWhat is x?\tAnswer\n");
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /OK: 2 card/);
});
