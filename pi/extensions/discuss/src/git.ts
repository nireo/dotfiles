import { lstat, readFile } from "node:fs/promises";
import { resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { buildDiffRows, type DiffRow } from "./diff.js";

const MAX_REVIEW_FILE_BYTES = 750_000;

export type ChangeStatus = "A" | "D" | "M" | "R";

export interface ReviewFile {
  path: string;
  oldPath: string | null;
  status: ChangeStatus;
  rows: DiffRow[];
}

export interface ReviewData {
  repoRoot: string;
  files: ReviewFile[];
  skippedFiles: number;
}

interface ChangedPath {
  status: ChangeStatus;
  oldPath: string | null;
  newPath: string | null;
}

async function runGit(pi: ExtensionAPI, cwd: string, args: string[]): Promise<string> {
  const result = await pi.exec("git", args, { cwd });
  if (result.code !== 0) {
    throw new Error(result.stderr.trim() || result.stdout.trim() || `git ${args.join(" ")} failed`);
  }
  return result.stdout;
}

async function runGitOrEmpty(pi: ExtensionAPI, cwd: string, args: string[]): Promise<string> {
  const result = await pi.exec("git", args, { cwd });
  return result.code === 0 ? result.stdout : "";
}

function parseChangedPaths(output: string): ChangedPath[] {
  const fields = output.split("\0").filter(Boolean);
  const changes: ChangedPath[] = [];

  for (let index = 0; index < fields.length;) {
    const rawStatus = fields[index++] ?? "";
    const code = rawStatus[0];
    if (code === "R") {
      const oldPath = fields[index++] ?? null;
      const newPath = fields[index++] ?? null;
      if (oldPath && newPath) changes.push({ status: "R", oldPath, newPath });
      continue;
    }

    const path = fields[index++] ?? null;
    if (path == null) continue;
    if (code === "A") changes.push({ status: "A", oldPath: null, newPath: path });
    else if (code === "D") changes.push({ status: "D", oldPath: path, newPath: null });
    else if (code === "M" || code === "T") changes.push({ status: "M", oldPath: path, newPath: path });
  }

  return changes;
}

function mergeUntracked(changes: ChangedPath[], output: string): ChangedPath[] {
  const seen = new Set(changes.map((change) => change.newPath ?? change.oldPath));
  for (const path of output.split("\0").filter(Boolean)) {
    if (!seen.has(path)) changes.push({ status: "A", oldPath: null, newPath: path });
  }
  return changes;
}

async function readWorkingTreeFile(repoRoot: string, path: string): Promise<string | null> {
  const absolutePath = resolve(repoRoot, path);
  if (!absolutePath.startsWith(`${repoRoot}/`) && absolutePath !== repoRoot) return null;

  try {
    const fileStat = await lstat(absolutePath);
    if (!fileStat.isFile() || fileStat.isSymbolicLink() || fileStat.size > MAX_REVIEW_FILE_BYTES) return null;
    const contents = await readFile(absolutePath);
    return contents.includes(0) ? null : contents.toString("utf8");
  } catch {
    return null;
  }
}

async function readRevisionFile(pi: ExtensionAPI, repoRoot: string, revision: string, path: string): Promise<string | null> {
  const size = await runGitOrEmpty(pi, repoRoot, ["cat-file", "-s", `${revision}:${path}`]);
  if (Number(size.trim()) > MAX_REVIEW_FILE_BYTES) return null;

  const contents = await runGitOrEmpty(pi, repoRoot, ["show", "--no-textconv", `${revision}:${path}`]);
  return contents.includes("\0") ? null : contents;
}

function displayPath(change: ChangedPath): string {
  return change.status === "R" ? `${change.oldPath} → ${change.newPath}` : change.newPath ?? change.oldPath ?? "(unknown)";
}

export async function loadReviewData(pi: ExtensionAPI, cwd: string): Promise<ReviewData> {
  const repoRoot = (await runGit(pi, cwd, ["rev-parse", "--show-toplevel"])).trim();
  const hasHead = (await runGitOrEmpty(pi, repoRoot, ["rev-parse", "--verify", "HEAD"])).trim().length > 0;

  const changed = hasHead
    ? parseChangedPaths(await runGit(pi, repoRoot, ["diff", "--name-status", "-z", "--find-renames", "HEAD", "--"]))
    : parseChangedPaths(await runGitOrEmpty(pi, repoRoot, ["diff", "--name-status", "-z", "--find-renames", "--cached", "--"]));
  const untracked = await runGitOrEmpty(pi, repoRoot, ["ls-files", "--others", "--exclude-standard", "-z"]);
  const paths = mergeUntracked(changed, untracked);

  if (!hasHead) {
    for (const path of (await runGitOrEmpty(pi, repoRoot, ["ls-files", "--cached", "-z"])).split("\0").filter(Boolean)) {
      if (!paths.some((change) => change.newPath === path)) paths.push({ status: "A", oldPath: null, newPath: path });
    }
  }

  const files: ReviewFile[] = [];
  let skippedFiles = 0;
  for (const change of paths) {
    const original = change.oldPath == null || !hasHead
      ? ""
      : await readRevisionFile(pi, repoRoot, "HEAD", change.oldPath);
    const modified = change.newPath == null ? "" : await readWorkingTreeFile(repoRoot, change.newPath);

    if (original == null || modified == null) {
      skippedFiles += 1;
      continue;
    }

    files.push({
      path: displayPath(change),
      oldPath: change.oldPath,
      status: change.status,
      rows: buildDiffRows(original, modified),
    });
  }

  return { repoRoot, files: files.sort((a, b) => a.path.localeCompare(b.path)), skippedFiles };
}
