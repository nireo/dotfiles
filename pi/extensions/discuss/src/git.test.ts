import { execFile as execFileCallback } from "node:child_process";
import { mkdtemp, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";
import { afterEach, describe, expect, it } from "vitest";
import { loadReviewData } from "./git.js";

const execFile = promisify(execFileCallback);
const temporaryDirectories: string[] = [];

async function git(cwd: string, args: string[]): Promise<string> {
  const { stdout } = await execFile("git", args, { cwd, encoding: "utf8" });
  return stdout;
}

afterEach(async () => {
  await Promise.all(temporaryDirectories.splice(0).map((directory) => rm(directory, { recursive: true, force: true })));
});

describe("loadReviewData", () => {
  it("loads tracked and untracked text changes from the working tree", async () => {
    const cwd = await mkdtemp(join(tmpdir(), "pi-discuss-"));
    temporaryDirectories.push(cwd);
    await git(cwd, ["init", "--quiet"]);
    await git(cwd, ["config", "user.email", "test@example.com"]);
    await git(cwd, ["config", "user.name", "Test User"]);
    await writeFile(join(cwd, "tracked.ts"), "export const state = 'old';\n");
    await git(cwd, ["add", "tracked.ts"]);
    await git(cwd, ["commit", "--quiet", "-m", "initial"]);
    await writeFile(join(cwd, "tracked.ts"), "export const state = 'new';\n");
    await writeFile(join(cwd, "new.ts"), "export const created = true;\n");

    const pi = {
      exec: async (command: string, args: string[], options?: { cwd?: string }) => {
        try {
          const { stdout, stderr } = await execFile(command, args, { cwd: options?.cwd, encoding: "utf8" });
          return { code: 0, stdout, stderr, killed: false };
        } catch (error) {
          const failure = error as { code?: number; stdout?: string; stderr?: string; killed?: boolean };
          return { code: failure.code ?? 1, stdout: failure.stdout ?? "", stderr: failure.stderr ?? "", killed: failure.killed ?? false };
        }
      },
    } as never;

    const review = await loadReviewData(pi, cwd);

    expect(review.skippedFiles).toBe(0);
    expect(review.files.map((file) => file.path)).toEqual(["new.ts", "tracked.ts"]);
    expect(review.files.find((file) => file.path === "new.ts")?.rows).toContainEqual({
      kind: "added",
      oldLine: null,
      newLine: 1,
      text: "export const created = true;",
    });
    expect(review.files.find((file) => file.path === "tracked.ts")?.rows).toContainEqual({
      kind: "deleted",
      oldLine: 1,
      newLine: null,
      text: "export const state = 'old';",
    });
  });

  it("skips an untracked symlink instead of reading its target", async () => {
    const cwd = await mkdtemp(join(tmpdir(), "pi-discuss-"));
    const outside = await mkdtemp(join(tmpdir(), "pi-discuss-outside-"));
    temporaryDirectories.push(cwd, outside);
    await git(cwd, ["init", "--quiet"]);
    const target = join(outside, "secret.ts");
    await writeFile(target, "export const secret = 'do not read';\n");
    await symlink(target, join(cwd, "linked.ts"));

    const pi = {
      exec: async (command: string, args: string[], options?: { cwd?: string }) => {
        try {
          const { stdout, stderr } = await execFile(command, args, { cwd: options?.cwd, encoding: "utf8" });
          return { code: 0, stdout, stderr, killed: false };
        } catch (error) {
          const failure = error as { code?: number; stdout?: string; stderr?: string; killed?: boolean };
          return { code: failure.code ?? 1, stdout: failure.stdout ?? "", stderr: failure.stderr ?? "", killed: failure.killed ?? false };
        }
      },
    } as never;

    const review = await loadReviewData(pi, cwd);

    expect(review.files).toEqual([]);
    expect(review.skippedFiles).toBe(1);
  });
});
