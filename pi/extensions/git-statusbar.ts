import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const STATUS_KEY = "git-status";

type GitSummary = {
	branch: string;
	staged: number;
	unstaged: number;
	untracked: number;
	conflicts: number;
	ahead: number;
	behind: number;
};

function parseStatus(output: string): GitSummary | null {
	const lines = output.split("\n").filter(Boolean);
	if (lines.length === 0) return null;

	let branch = "git";
	let ahead = 0;
	let behind = 0;
	let staged = 0;
	let unstaged = 0;
	let untracked = 0;
	let conflicts = 0;

	for (const line of lines) {
		if (line.startsWith("## ")) {
			const header = line.slice(3);
			branch = header.split("...")[0]?.trim() || "git";
			const aheadMatch = header.match(/ahead (\d+)/);
			const behindMatch = header.match(/behind (\d+)/);
			ahead = aheadMatch ? Number(aheadMatch[1]) : 0;
			behind = behindMatch ? Number(behindMatch[1]) : 0;
			continue;
		}

		const x = line[0];
		const y = line[1];
		if (x === "?" && y === "?") {
			untracked++;
			continue;
		}

		if (x === "U" || y === "U" || (x === "A" && y === "A") || (x === "D" && y === "D")) conflicts++;
		if (x && x !== " " && x !== "?") staged++;
		if (y && y !== " " && y !== "?") unstaged++;
	}

	return { branch, staged, unstaged, untracked, conflicts, ahead, behind };
}

function formatStatus(summary: GitSummary, theme: ExtensionContext["ui"]["theme"]): string {
	const parts: string[] = [theme.fg("accent", `${summary.branch}`)];

	if (summary.ahead > 0) parts.push(theme.fg("success", `↑${summary.ahead}`));
	if (summary.behind > 0) parts.push(theme.fg("warning", `↓${summary.behind}`));
	if (summary.staged > 0) parts.push(theme.fg("success", `+${summary.staged}`));
	if (summary.unstaged > 0) parts.push(theme.fg("warning", `~${summary.unstaged}`));
	if (summary.untracked > 0) parts.push(theme.fg("muted", `?${summary.untracked}`));
	if (summary.conflicts > 0) parts.push(theme.fg("error", `!${summary.conflicts}`));
	if (parts.length === 1) parts.push(theme.fg("dim", "clean"));

	return parts.join(" ");
}

async function refresh(ctx: ExtensionContext) {
	if (!ctx.hasUI) return;

	try {
		const { stdout } = await execFileAsync("git", ["status", "--porcelain=v1", "--branch"], {
			cwd: ctx.cwd,
			timeout: 2000,
			maxBuffer: 128 * 1024,
		});
		const summary = parseStatus(stdout);
		if (!summary) {
			ctx.ui.setStatus(STATUS_KEY, undefined);
			return;
		}
		ctx.ui.setStatus(STATUS_KEY, formatStatus(summary, ctx.ui.theme));
	} catch {
		ctx.ui.setStatus(STATUS_KEY, undefined);
	}
}

export default function gitStatusbar(pi: ExtensionAPI) {
	let interval: NodeJS.Timeout | undefined;

	pi.on("session_start", async (_event, ctx) => {
		if (interval) clearInterval(interval);
		await refresh(ctx);
		interval = setInterval(() => void refresh(ctx), 5000);
		interval.unref?.();
	});

	pi.on("tool_execution_end", async (_event, ctx) => {
		await refresh(ctx);
	});

	pi.on("user_bash", async (_event, ctx) => {
		setTimeout(() => void refresh(ctx), 100);
	});

	pi.on("resources_discover", async (_event, ctx) => {
		await refresh(ctx);
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		if (interval) clearInterval(interval);
		interval = undefined;
		ctx.ui.setStatus(STATUS_KEY, undefined);
	});
}
