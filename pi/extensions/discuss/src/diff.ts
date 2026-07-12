import { parseDiffFromFile } from "@pierre/diffs";

export type DiffRowKind = "context" | "added" | "deleted";

export interface DiffRow {
  kind: DiffRowKind;
  oldLine: number | null;
  newLine: number | null;
  text: string;
}

function displayLine(line: string | undefined): string {
  return (line ?? "").replace(/\r?\n$/, "").replace(/\t/g, "    ");
}

/**
 * Builds a line-addressable, unified diff from @pierre/diffs metadata. Keeping
 * this model small makes annotations stable without reimplementing diffing.
 */
export function buildDiffRows(original: string, modified: string): DiffRow[] {
  const parsed = parseDiffFromFile(
    { name: "before", contents: original },
    { name: "after", contents: modified },
    undefined,
    true,
  );
  const rows: DiffRow[] = [];
  let oldLine = 1;
  let newLine = 1;

  const addContextUntil = (targetOld: number, targetNew: number) => {
    while (oldLine < targetOld && newLine < targetNew) {
      rows.push({
        kind: "context",
        oldLine,
        newLine,
        text: displayLine(parsed.additionLines[newLine - 1]),
      });
      oldLine += 1;
      newLine += 1;
    }
  };

  for (const hunk of parsed.hunks) {
    addContextUntil(hunk.deletionStart, hunk.additionStart);

    for (const block of hunk.hunkContent) {
      if (block.type === "context") {
        for (let index = 0; index < block.lines; index += 1) {
          rows.push({
            kind: "context",
            oldLine,
            newLine,
            text: displayLine(parsed.additionLines[block.additionLineIndex + index]),
          });
          oldLine += 1;
          newLine += 1;
        }
        continue;
      }

      for (let index = 0; index < block.deletions; index += 1) {
        rows.push({
          kind: "deleted",
          oldLine,
          newLine: null,
          text: displayLine(parsed.deletionLines[block.deletionLineIndex + index]),
        });
        oldLine += 1;
      }
      for (let index = 0; index < block.additions; index += 1) {
        rows.push({
          kind: "added",
          oldLine: null,
          newLine,
          text: displayLine(parsed.additionLines[block.additionLineIndex + index]),
        });
        newLine += 1;
      }
    }
  }

  while (oldLine <= parsed.deletionLines.length && newLine <= parsed.additionLines.length) {
    rows.push({
      kind: "context",
      oldLine,
      newLine,
      text: displayLine(parsed.additionLines[newLine - 1]),
    });
    oldLine += 1;
    newLine += 1;
  }
  while (oldLine <= parsed.deletionLines.length) {
    rows.push({ kind: "deleted", oldLine, newLine: null, text: displayLine(parsed.deletionLines[oldLine - 1]) });
    oldLine += 1;
  }
  while (newLine <= parsed.additionLines.length) {
    rows.push({ kind: "added", oldLine: null, newLine, text: displayLine(parsed.additionLines[newLine - 1]) });
    newLine += 1;
  }

  return rows;
}
