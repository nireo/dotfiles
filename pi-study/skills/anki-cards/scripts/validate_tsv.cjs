#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

function fail(message) {
  console.error(`error: ${message}`);
  process.exitCode = 1;
}

function balancedMathJax(field, row, side) {
  const tokens = field.match(/\\\(|\\\)|\\\[|\\\]/g) ?? [];
  const stack = [];
  for (const token of tokens) {
    if (token === "\\(" || token === "\\[") {
      stack.push(token);
      continue;
    }
    const expected = token === "\\)" ? "\\(" : "\\[";
    if (stack.pop() !== expected) {
      fail(`row ${row} ${side}: unbalanced MathJax delimiter ${token}`);
      return;
    }
  }
  if (stack.length > 0) {
    fail(`row ${row} ${side}: unclosed MathJax delimiter ${stack.at(-1)}`);
  }
}

const file = process.argv[2];
if (!file || process.argv.length !== 3) {
  console.error(`Usage: node ${path.basename(process.argv[1])} <cards.tsv>`);
  process.exit(2);
}

let text;
try {
  text = fs.readFileSync(file, "utf8");
} catch (error) {
  console.error(`error: cannot read ${file}: ${error.message}`);
  process.exit(1);
}

if (text.startsWith("\uFEFF")) {
  fail("UTF-8 BOM is not allowed before the first card");
}
if (text.includes("\r")) {
  fail("use LF line endings; carriage returns are not allowed");
}

const lines = text.endsWith("\n") ? text.slice(0, -1).split("\n") : text.split("\n");
if (lines.length === 1 && lines[0].length === 0) {
  fail("TSV must contain at least one card");
  process.exit(1);
}

let cardCount = 0;
for (let index = 0; index < lines.length; index += 1) {
  const row = index + 1;
  const line = lines[index];
  if (line.length === 0) {
    fail(`row ${row}: blank rows are not allowed`);
    continue;
  }
  cardCount += 1;
  const tabs = [...line].filter((character) => character === "\t").length;
  if (tabs !== 1) {
    fail(`row ${row}: expected exactly one tab separator, found ${tabs}`);
    continue;
  }
  const [front, back] = line.split("\t");
  for (const [side, field] of [["Front", front], ["Back", back]]) {
    if (field.trim().length === 0) {
      fail(`row ${row} ${side}: field must not be empty`);
    }
    if (/^".*"$/.test(field)) {
      fail(`row ${row} ${side}: do not wrap fields in quotes`);
    }
    if (/```|(?:^|\s)#{1,6}\s|\*\*|__|\[[^\]]+\]\([^)]+\)/.test(field)) {
      fail(`row ${row} ${side}: Markdown syntax is not allowed inside card fields`);
    }
    balancedMathJax(field, row, side);
  }
}

if (!process.exitCode) {
  console.log(`OK: ${cardCount} card(s), two TSV fields per row, balanced MathJax delimiters`);
}
