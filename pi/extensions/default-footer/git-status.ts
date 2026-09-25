import { spawn } from "node:child_process";

export type GitStatusSnapshot = {
	branch?: string;
	staged: number;
	unstaged: number;
	untracked: number;
	conflict: number;
	ahead: number;
	behind: number;
	/** Lines added/deleted in the working tree compared with HEAD. */
	additions?: number;
	deletions?: number;
};

export type GitDiffSnapshot = {
	additions: number;
	deletions: number;
};

export type PullRequestSnapshot = {
	number?: number | string;
	state?: string;
	isDraft?: boolean;
	url?: string;
	title?: string;
};

type CommandResult = {
	stdout: string;
	stderr: string;
	exitCode: number | null;
};

type CommandRunner = (
	command: string,
	args: readonly string[],
	options: { cwd: string; signal: AbortSignal },
) => Promise<CommandResult>;

type RunCommandSafelyResult =
	| { kind: "ok"; result: CommandResult }
	| { kind: "transient" }
	| { kind: "unavailable" };

type TimerHandle = unknown;

type Clock = {
	setInterval(callback: () => void, ms: number): TimerHandle;
	clearInterval(handle: TimerHandle): void;
};

export type GitFooterCacheOptions = {
	cwd: () => string;
	runner?: CommandRunner;
	clock?: Clock;
	refreshIntervalMs?: number;
	gitTimeoutMs?: number;
	ghTimeoutMs?: number;
	onChange?: () => void;
};

const BRANCH_HEAD_PREFIX = "# branch.head ";
const BRANCH_AB_PREFIX = "# branch.ab ";
const STATUS_SEPARATOR = " • ";
const DEFAULT_REFRESH_INTERVAL_MS = 8_000;
const DEFAULT_GIT_TIMEOUT_MS = 1_500;
const DEFAULT_GH_TIMEOUT_MS = 3_000;
export const GIT_STATUS_ARGS = ["--no-optional-locks", "status", "--porcelain=v2", "--branch"] as const;
export const GIT_DIFF_ARGS = ["--no-optional-locks", "diff", "--no-ext-diff", "--numstat", "HEAD"] as const;
export const GH_PR_VIEW_ARGS = ["pr", "view", "--json", "number,state,isDraft,url,title"] as const;

function createEmptyGitStatus(): GitStatusSnapshot {
	return {
		branch: undefined,
		staged: 0,
		unstaged: 0,
		untracked: 0,
		conflict: 0,
		ahead: 0,
		behind: 0,
	};
}

function positiveCount(value: number): number {
	return Number.isFinite(value) && value > 0 ? Math.trunc(value) : 0;
}

function addTrackedStatusCounts(status: GitStatusSnapshot, xy: string): void {
	if (xy.length !== 2) return;
	if (xy[0] !== ".") status.staged += 1;
	if (xy[1] !== ".") status.unstaged += 1;
}

function parseBranchAheadBehind(line: string, status: GitStatusSnapshot): void {
	const match = /^# branch\.ab \+(\d+) -(\d+)$/.exec(line);
	if (!match) return;
	status.ahead = Number.parseInt(match[1]!, 10);
	status.behind = Number.parseInt(match[2]!, 10);
}

function normalizeBranchHead(value: string): string {
	const branch = value.trim();
	return branch === "(detached)" ? "detached" : branch;
}

export function parseGitStatusPorcelainV2(output: string): GitStatusSnapshot {
	const status = createEmptyGitStatus();

	for (const rawLine of output.split("\n")) {
		const line = rawLine.endsWith("\r") ? rawLine.slice(0, -1) : rawLine;
		if (!line) continue;

		if (line.startsWith(BRANCH_HEAD_PREFIX)) {
			status.branch = normalizeBranchHead(line.slice(BRANCH_HEAD_PREFIX.length)) || undefined;
			continue;
		}

		if (line.startsWith(BRANCH_AB_PREFIX)) {
			parseBranchAheadBehind(line, status);
			continue;
		}

		if (line.startsWith("1 ") || line.startsWith("2 ")) {
			addTrackedStatusCounts(status, line.slice(2, 4));
			continue;
		}

		if (line.startsWith("u ")) {
			status.conflict += 1;
			continue;
		}

		if (line.startsWith("? ")) status.untracked += 1;
	}

	return status;
}

function parseDiffCount(value: string): number {
	return value === "-" ? 0 : positiveCount(Number.parseInt(value, 10));
}

/** Parse the stable numeric columns emitted by `git diff --numstat`. */
export function parseGitDiffNumstat(output: string): GitDiffSnapshot {
	let additions = 0;
	let deletions = 0;

	for (const rawLine of output.split("\n")) {
		const line = rawLine.endsWith("\r") ? rawLine.slice(0, -1) : rawLine;
		const match = /^(\d+|-)\s+(\d+|-)(?:\s|$)/.exec(line);
		if (!match) continue;

		additions += parseDiffCount(match[1]!);
		deletions += parseDiffCount(match[2]!);
	}

	return { additions, deletions };
}

type GitFooterTheme = {
	fg(color: "success" | "error" | "dim", text: string): string;
};

export function formatGitStatusFooterSegment(
	status: GitStatusSnapshot | undefined,
	theme?: GitFooterTheme,
): string | undefined {
	if (!status) return undefined;

	const parts: Array<[string, "success" | "error" | "dim"]> = [];
	const hasDiffCounts = status.additions !== undefined || status.deletions !== undefined;
	const additions = positiveCount(status.additions ?? 0);
	const deletions = positiveCount(status.deletions ?? 0);
	if (hasDiffCounts && (additions > 0 || deletions > 0)) {
		parts.push([`+${additions}`, "success"], [`-${deletions}`, "error"]);
	}

	if (parts.length === 0) return undefined;
	return parts
		.map(([text, color]) => (theme ? theme.fg(color, text) : text))
		.join(" ");
}

export function formatPullRequestFooterSegment(
	pullRequest: PullRequestSnapshot | undefined,
): string | undefined {
	const value = pullRequest?.number;
	if (Number.isSafeInteger(value) && Number(value) > 0) return `PR #${value}`;
	if (typeof value === "string") {
		const trimmed = value.trim();
		if (/^[1-9]\d*$/.test(trimmed)) return `PR #${trimmed}`;
	}
	return undefined;
}

export function formatGitFooterStatus(
	status: GitStatusSnapshot | undefined,
	pullRequest: PullRequestSnapshot | undefined,
	theme?: GitFooterTheme,
): string | undefined {
	const pullRequestSegment = formatPullRequestFooterSegment(pullRequest);
	const parts = [
		formatGitStatusFooterSegment(status, theme),
		theme && pullRequestSegment ? theme.fg("dim", pullRequestSegment) : pullRequestSegment,
	].filter((part): part is string => !!part);
	return parts.length > 0
		? parts.join(theme ? theme.fg("dim", STATUS_SEPARATOR) : STATUS_SEPARATOR)
		: undefined;
}

export function parsePullRequestJson(stdout: string): PullRequestSnapshot | undefined {
	const trimmed = stdout.trim();
	if (!trimmed) return undefined;

	let parsed: unknown;
	try {
		parsed = JSON.parse(trimmed);
	} catch {
		return undefined;
	}
	if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) return undefined;

	const record = parsed as Record<string, unknown>;
	const snapshot: PullRequestSnapshot = {};
	if (typeof record.number === "number" || typeof record.number === "string") {
		snapshot.number = record.number;
	}
	if (typeof record.state === "string") snapshot.state = record.state;
	if (typeof record.isDraft === "boolean") snapshot.isDraft = record.isDraft;
	if (typeof record.url === "string") snapshot.url = record.url;
	if (typeof record.title === "string") snapshot.title = record.title;
	return snapshot;
}

function gitStatusSnapshotsEqual(
	left: GitStatusSnapshot | undefined,
	right: GitStatusSnapshot | undefined,
): boolean {
	return (
		left?.branch === right?.branch
		&& left?.staged === right?.staged
		&& left?.unstaged === right?.unstaged
		&& left?.untracked === right?.untracked
		&& left?.conflict === right?.conflict
		&& left?.ahead === right?.ahead
		&& left?.behind === right?.behind
		&& (left?.additions ?? 0) === (right?.additions ?? 0)
		&& (left?.deletions ?? 0) === (right?.deletions ?? 0)
	);
}

function pullRequestSnapshotsEqual(
	left: PullRequestSnapshot | undefined,
	right: PullRequestSnapshot | undefined,
): boolean {
	return (
		left?.number === right?.number
		&& left?.state === right?.state
		&& left?.isDraft === right?.isDraft
		&& left?.url === right?.url
		&& left?.title === right?.title
	);
}

function defaultRunner(
	command: string,
	args: readonly string[],
	options: { cwd: string; signal: AbortSignal },
): Promise<CommandResult> {
	return new Promise((resolve, reject) => {
		let child;
		try {
			child = spawn(command, [...args], {
				cwd: options.cwd,
				stdio: ["ignore", "pipe", "pipe"],
				windowsHide: true,
			});
		} catch (error) {
			reject(error);
			return;
		}

		let stdout = "";
		let stderr = "";
		let settled = false;

		const finish = (result: CommandResult | Error) => {
			if (settled) return;
			settled = true;
			options.signal.removeEventListener("abort", onAbort);
			if (result instanceof Error) reject(result);
			else resolve(result);
		};

		const onAbort = () => {
			try {
				child.kill("SIGTERM");
			} catch {
				// Ignore: process may already be gone.
			}
			finish(new Error("aborted"));
		};

		child.stdout?.on("data", (chunk: Buffer | string) => {
			stdout += typeof chunk === "string" ? chunk : chunk.toString("utf8");
		});
		child.stderr?.on("data", (chunk: Buffer | string) => {
			stderr += typeof chunk === "string" ? chunk : chunk.toString("utf8");
		});
		child.on("error", finish);
		child.on("close", (code) => finish({ stdout, stderr, exitCode: code }));

		if (options.signal.aborted) {
			onAbort();
			return;
		}
		options.signal.addEventListener("abort", onAbort, { once: true });
	});
}

function defaultClock(): Clock {
	return {
		setInterval(callback, ms) {
			const handle = setInterval(callback, ms);
			(handle as { unref?: () => void }).unref?.();
			return handle;
		},
		clearInterval(handle) {
			clearInterval(handle as ReturnType<typeof setInterval>);
		},
	};
}

function isCommandUnavailableError(error: unknown): boolean {
	return !!error && typeof error === "object" && (error as { code?: unknown }).code === "ENOENT";
}

export class GitFooterCache {
	private readonly cwd: () => string;
	private readonly runner: CommandRunner;
	private readonly clock: Clock;
	private readonly refreshIntervalMs: number;
	private readonly gitTimeoutMs: number;
	private readonly ghTimeoutMs: number;
	private readonly onChange: (() => void) | undefined;

	private intervalHandle: TimerHandle | undefined;
	private readonly inflightControllers = new Set<AbortController>();
	private disposed = false;
	private refreshInFlight: Promise<void> | undefined;
	private statusSnapshot: GitStatusSnapshot | undefined;
	private pullRequestSnapshot: PullRequestSnapshot | undefined;
	private lastSeenBranch: string | undefined;

	constructor(options: GitFooterCacheOptions) {
		this.cwd = options.cwd;
		this.runner = options.runner ?? defaultRunner;
		this.clock = options.clock ?? defaultClock();
		this.refreshIntervalMs = options.refreshIntervalMs ?? DEFAULT_REFRESH_INTERVAL_MS;
		this.gitTimeoutMs = options.gitTimeoutMs ?? DEFAULT_GIT_TIMEOUT_MS;
		this.ghTimeoutMs = options.ghTimeoutMs ?? DEFAULT_GH_TIMEOUT_MS;
		this.onChange = options.onChange;

		this.intervalHandle = this.clock.setInterval(() => {
			void this.refresh();
		}, this.refreshIntervalMs);
		void this.refresh();
	}

	getStatusSnapshot(): GitStatusSnapshot | undefined {
		return this.statusSnapshot;
	}

	getPullRequestSnapshot(): PullRequestSnapshot | undefined {
		return this.pullRequestSnapshot;
	}

	refresh(): Promise<void> {
		if (this.disposed) return Promise.resolve();
		if (this.refreshInFlight) return this.refreshInFlight;

		const run = this.runRefresh()
			.finally(() => {
				this.refreshInFlight = undefined;
			})
			.catch(() => undefined);
		this.refreshInFlight = run;
		return run;
	}

	private async runRefresh(): Promise<void> {
		const previousStatusSnapshot = this.statusSnapshot;
		const previousPullRequestSnapshot = this.pullRequestSnapshot;

		const result = await this.fetchGitStatus();
		if (this.disposed) return;
		if (result.kind === "transient") return;
		if (result.kind === "not-a-repo" || result.kind === "unavailable") {
			this.statusSnapshot = undefined;
			this.pullRequestSnapshot = undefined;
			this.lastSeenBranch = undefined;
			this.emitChangeIfSnapshotsChanged(previousStatusSnapshot, previousPullRequestSnapshot);
			return;
		}

		const status = result.status;
		this.statusSnapshot = status;

		const branch = typeof status.branch === "string" ? status.branch : undefined;
		const isValidBranch = !!branch && branch !== "detached";
		const branchChanged = branch !== this.lastSeenBranch;

		if (branchChanged) this.pullRequestSnapshot = undefined;
		this.lastSeenBranch = branch;

		if (!isValidBranch) {
			this.pullRequestSnapshot = undefined;
			this.emitChangeIfSnapshotsChanged(previousStatusSnapshot, previousPullRequestSnapshot);
			return;
		}

		const pr = await this.fetchPullRequest();
		if (this.disposed) return;
		if (pr.kind === "ok") this.pullRequestSnapshot = pr.pullRequest;
		else if (pr.kind === "not-found" || pr.kind === "unavailable") this.pullRequestSnapshot = undefined;

		this.emitChangeIfSnapshotsChanged(previousStatusSnapshot, previousPullRequestSnapshot);
	}

	private emitChangeIfSnapshotsChanged(
		previousStatusSnapshot: GitStatusSnapshot | undefined,
		previousPullRequestSnapshot: PullRequestSnapshot | undefined,
	): void {
		if (this.disposed) return;
		if (
			gitStatusSnapshotsEqual(previousStatusSnapshot, this.statusSnapshot)
			&& pullRequestSnapshotsEqual(previousPullRequestSnapshot, this.pullRequestSnapshot)
		) {
			return;
		}
		try {
			this.onChange?.();
		} catch {
			// Rendering hooks should not break refreshes.
		}
	}

	private async fetchGitStatus(): Promise<
		| { kind: "ok"; status: GitStatusSnapshot }
		| { kind: "not-a-repo" }
		| { kind: "transient" }
		| { kind: "unavailable" }
	> {
		const result = await this.runCommandSafely("git", GIT_STATUS_ARGS, this.gitTimeoutMs);
		if (result.kind !== "ok") return result;
		if (result.result.exitCode !== 0) return { kind: "not-a-repo" };

		const status = parseGitStatusPorcelainV2(result.result.stdout);
		const diff = await this.runCommandSafely("git", GIT_DIFF_ARGS, this.gitTimeoutMs);
		if (diff.kind === "transient") return diff;
		if (diff.kind !== "ok" || diff.result.exitCode !== 0) return { kind: "ok", status };

		return {
			kind: "ok",
			status: { ...status, ...parseGitDiffNumstat(diff.result.stdout) },
		};
	}

	private async fetchPullRequest(): Promise<
		| { kind: "ok"; pullRequest: PullRequestSnapshot | undefined }
		| { kind: "not-found" }
		| { kind: "transient" }
		| { kind: "unavailable" }
	> {
		const result = await this.runCommandSafely("gh", GH_PR_VIEW_ARGS, this.ghTimeoutMs);
		if (result.kind !== "ok") return result;
		if (result.result.exitCode !== 0) return { kind: "not-found" };
		return { kind: "ok", pullRequest: parsePullRequestJson(result.result.stdout) };
	}

	private async runCommandSafely(
		command: string,
		args: readonly string[],
		timeoutMs: number,
	): Promise<RunCommandSafelyResult> {
		if (this.disposed) return { kind: "transient" };

		const controller = new AbortController();
		this.inflightControllers.add(controller);
		const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
		try {
			const result = await this.runner(command, args, { cwd: this.cwd(), signal: controller.signal });
			return { kind: "ok", result };
		} catch (error) {
			return isCommandUnavailableError(error) ? { kind: "unavailable" } : { kind: "transient" };
		} finally {
			clearTimeout(timeoutId);
			this.inflightControllers.delete(controller);
		}
	}

	dispose(): void {
		if (this.disposed) return;
		this.disposed = true;
		if (this.intervalHandle !== undefined) {
			this.clock.clearInterval(this.intervalHandle);
			this.intervalHandle = undefined;
		}
		for (const controller of this.inflightControllers) controller.abort();
		this.inflightControllers.clear();
	}
}
