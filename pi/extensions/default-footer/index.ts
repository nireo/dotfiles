/**
 * Local replica of Pi's regular footer.
 *
 * This intentionally mirrors the built-in FooterComponent from Pi 0.84.0 so
 * the default layout remains familiar while giving us a single, editable
 * place to add or remove footer components later.
 *
 * Keep the rendering code below aligned with Pi's built-in footer when Pi is
 * upgraded. The extension API exposes everything needed for the visible
 * footer except the live auto-compaction flag, so this extension watches the
 * settings files that Pi updates when that setting changes.
 */

import type {
	ExtensionAPI,
	ExtensionContext,
	ReadonlyFooterDataProvider,
	Theme,
} from "@earendil-works/pi-coding-agent";
import { CONFIG_DIR_NAME, getAgentDir } from "@earendil-works/pi-coding-agent";
import type { Model, Usage } from "@earendil-works/pi-ai";
import { truncateToWidth, visibleWidth, type Component, type TUI } from "@earendil-works/pi-tui";
import { GitFooterCache, formatGitFooterStatus } from "./git-status.ts";
import { OPENAI_ACCOUNT_CHANGED_EVENT, getOpenAIAccountName } from "../openai-accounts.ts";
import { readFileSync, unwatchFile, watchFile } from "node:fs";
import { isAbsolute, join, relative, resolve, sep } from "node:path";

type SessionEntries = ReturnType<ExtensionContext["sessionManager"]["getEntries"]>;

type UsageTotals = {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: number;
};

type FooterState = {
	ctx: ExtensionContext;
	model: Model<any> | undefined;
	thinkingLevel: string | undefined;
	autoCompactionEnabled: boolean;
	gitCache?: GitFooterCache;
	requestRender?: () => void;
};

type FooterTheme = Pick<Theme, "fg" | "bold">;

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

function formatCwdForFooter(cwd: string, home: string | undefined): string {
	if (!home) return cwd;

	const resolvedCwd = resolve(cwd);
	const resolvedHome = resolve(home);
	const relativeToHome = relative(resolvedHome, resolvedCwd);
	const isInsideHome =
		relativeToHome === "" ||
		(relativeToHome !== ".." && !relativeToHome.startsWith(`..${sep}`) && !isAbsolute(relativeToHome));

	if (!isInsideHome) return cwd;
	return relativeToHome === "" ? "~" : `~${sep}${relativeToHome}`;
}

/** Match Pi's single-line status sanitization. ANSI styling is preserved. */
function sanitizeStatusText(text: string): string {
	return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

function createUsageTotals(): UsageTotals {
	return { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
}

function addUsageToTotals(totals: UsageTotals, usage: Usage): void {
	totals.input += usage.input;
	totals.output += usage.output;
	totals.cacheRead += usage.cacheRead;
	totals.cacheWrite += usage.cacheWrite;
	totals.cost += usage.cost.total;
}

function collectUsage(entries: SessionEntries): {
	totals: UsageTotals;
	latestCacheHitRate: number | undefined;
} {
	const totals = createUsageTotals();
	let latestCacheHitRate: number | undefined;

	for (const entry of entries) {
		if (entry.type === "message" && entry.message.role === "assistant") {
			addUsageToTotals(totals, entry.message.usage);
			const latestPromptTokens =
				entry.message.usage.input +
				entry.message.usage.cacheRead +
				entry.message.usage.cacheWrite;
			latestCacheHitRate =
				latestPromptTokens > 0
					? (entry.message.usage.cacheRead / latestPromptTokens) * 100
					: undefined;
		} else if (entry.type === "message" && entry.message.role === "toolResult" && entry.message.usage) {
			addUsageToTotals(totals, entry.message.usage);
		} else if ((entry.type === "branch_summary" || entry.type === "compaction") && entry.usage) {
			addUsageToTotals(totals, entry.usage);
		}
	}

	return { totals, latestCacheHitRate };
}

type SettingsFile = {
	compaction?: {
		enabled?: unknown;
	};
};

function readSettingsFile(path: string): SettingsFile | undefined {
	try {
		const value: unknown = JSON.parse(readFileSync(path, "utf8"));
		return value && typeof value === "object" ? (value as SettingsFile) : undefined;
	} catch {
		return undefined;
	}
}

function readAutoCompactionEnabled(ctx: ExtensionContext): boolean {
	let enabled = readSettingsFile(join(getAgentDir(), "settings.json"))?.compaction?.enabled;

	// Pi only applies project settings after trust has been granted. Mirror that
	// behavior instead of reading project-local configuration from an untrusted
	// directory.
	if (ctx.isProjectTrusted()) {
		const projectEnabled = readSettingsFile(
			join(ctx.cwd, CONFIG_DIR_NAME, "settings.json"),
		)?.compaction?.enabled;
		if (typeof projectEnabled === "boolean") enabled = projectEnabled;
	}

	return typeof enabled === "boolean" ? enabled : true;
}

/**
 * Pi's settings manager writes this setting synchronously. Watching the same
 * files keeps the `(auto)` marker correct after /settings changes it.
 */
function watchAutoCompactionSetting(ctx: ExtensionContext, onChange: () => void): () => void {
	const paths = new Set<string>([join(getAgentDir(), "settings.json")]);
	if (ctx.isProjectTrusted()) paths.add(join(ctx.cwd, CONFIG_DIR_NAME, "settings.json"));

	const listeners = [...paths].map((path) => {
		const listener = (current: { mtimeMs: number; ctimeMs: number; size: number }, previous: { mtimeMs: number; ctimeMs: number; size: number }) => {
			if (
				current.mtimeMs !== previous.mtimeMs ||
				current.ctimeMs !== previous.ctimeMs ||
				current.size !== previous.size
			) {
				onChange();
			}
		};
		watchFile(path, { interval: 1000 }, listener);
		return { path, listener };
	});

	return () => {
		for (const { path, listener } of listeners) unwatchFile(path, listener);
	};
}

function renderFooter(options: {
	width: number;
	state: FooterState;
	theme: FooterTheme;
	footerData: ReadonlyFooterDataProvider;
}): string[] {
	const { width, state, theme, footerData } = options;
	const { ctx, model } = state;
	const { totals, latestCacheHitRate } = collectUsage(ctx.sessionManager.getEntries());

	const contextUsage = ctx.getContextUsage();
	const contextWindow = contextUsage?.contextWindow ?? model?.contextWindow ?? 0;
	const contextPercentValue = contextUsage?.percent ?? 0;
	const contextPercent = contextUsage?.percent !== null ? contextPercentValue.toFixed(1) : "?";

	let pwd = formatCwdForFooter(
		ctx.sessionManager.getCwd(),
		process.env.HOME || process.env.USERPROFILE,
	);

	const accountName = getOpenAIAccountName(model?.provider);
	if (accountName) pwd = `${accountName} • ${pwd}`;

	const branch = footerData.getGitBranch();
	const gitStatus = formatGitFooterStatus(
		state.gitCache?.getStatusSnapshot(),
		state.gitCache?.getPullRequestSnapshot(),
	);
	if (branch) {
		pwd = `${pwd} (${branch})`;
		if (gitStatus) pwd += ` ${gitStatus}`;
	}

	const sessionName = ctx.sessionManager.getSessionName();
	if (sessionName) pwd = `${pwd} • ${sessionName}`;

	const statsParts: string[] = [];
	if (totals.input) statsParts.push(`↑${formatTokens(totals.input)}`);
	if (totals.output) statsParts.push(`↓${formatTokens(totals.output)}`);
	if (totals.cacheRead) statsParts.push(`R${formatTokens(totals.cacheRead)}`);
	if (totals.cacheWrite) statsParts.push(`W${formatTokens(totals.cacheWrite)}`);
	if ((totals.cacheRead > 0 || totals.cacheWrite > 0) && latestCacheHitRate !== undefined) {
		statsParts.push(`CH${latestCacheHitRate.toFixed(1)}%`);
	}

	if (totals.cost) statsParts.push(`$${totals.cost.toFixed(3)}`);

	const contextPercentDisplay =
		contextPercent === "?"
			? `?/${formatTokens(contextWindow)}`
			: `${contextPercent}%/${formatTokens(contextWindow)}`;
	const autoIndicator = state.autoCompactionEnabled ? " (auto)" : "";
	const contextDisplay = `${contextPercentDisplay}${autoIndicator}`;

	let contextPercentStr: string;
	if (contextPercentValue > 90) {
		contextPercentStr = theme.fg("error", contextDisplay);
	} else if (contextPercentValue > 70) {
		contextPercentStr = theme.fg("warning", contextDisplay);
	} else {
		contextPercentStr = contextDisplay;
	}
	statsParts.push(contextPercentStr);

	if (process.env.PI_EXPERIMENTAL === "1") {
		statsParts.push(`${theme.fg("dim", "•")} ${theme.bold(theme.fg("warning", "xp"))}`);
	}

	let statsLeft = statsParts.join(" ");
	let statsLeftWidth = visibleWidth(statsLeft);
	if (statsLeftWidth > width) {
		statsLeft = truncateToWidth(statsLeft, width, "...");
		statsLeftWidth = visibleWidth(statsLeft);
	}

	const modelName = model?.id || "no-model";
	let rightSide = modelName;
	if (model?.reasoning) {
		const thinkingLevel = state.thinkingLevel || "off";
		rightSide =
			thinkingLevel === "off" ? `${modelName} (thinking off)` : `${modelName} (${thinkingLevel})`;
	}

	const rightSideWidth = visibleWidth(rightSide);
	const totalNeeded = statsLeftWidth + 2 + rightSideWidth;
	let statsLine: string;
	if (totalNeeded <= width) {
		const padding = " ".repeat(width - statsLeftWidth - rightSideWidth);
		statsLine = statsLeft + padding + rightSide;
	} else {
		const availableForRight = width - statsLeftWidth - 2;
		if (availableForRight > 0) {
			const truncatedRight = truncateToWidth(rightSide, availableForRight, "");
			const truncatedRightWidth = visibleWidth(truncatedRight);
			const padding = " ".repeat(Math.max(0, width - statsLeftWidth - truncatedRightWidth));
			statsLine = statsLeft + padding + truncatedRight;
		} else {
			statsLine = statsLeft;
		}
	}

	// Color each portion independently because contextPercentStr may contain
	// its own ANSI color reset.
	const dimStatsLeft = theme.fg("dim", statsLeft);
	const remainder = statsLine.slice(statsLeft.length);
	const dimRemainder = theme.fg("dim", remainder);
	const pwdLine = truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "..."));
	const lines = [pwdLine, dimStatsLeft + dimRemainder];

	const extensionStatuses = footerData.getExtensionStatuses();
	if (extensionStatuses.size > 0) {
		const sortedStatuses = Array.from(extensionStatuses.entries())
			.sort(([a], [b]) => a.localeCompare(b))
			.map(([, text]) => sanitizeStatusText(text));
		const statusLine = sortedStatuses.join(" ");
		lines.push(truncateToWidth(statusLine, width, theme.fg("dim", "...")));
	}

	return lines;
}

class DefaultFooterComponent implements Component {
	private disposed = false;

	constructor(
		private readonly state: FooterState,
		private readonly theme: FooterTheme,
		private readonly footerData: ReadonlyFooterDataProvider,
		private readonly unsubscribeBranch: () => void,
		private readonly unsubscribeAccountChanged: () => void,
		private readonly stopSettingsWatcher: () => void,
	) {}

	render(width: number): string[] {
		return renderFooter({ width, state: this.state, theme: this.theme, footerData: this.footerData });
	}

	invalidate(): void {
		// Rendering is intentionally derived from live session/footer state.
	}

	dispose(): void {
		if (this.disposed) return;
		this.disposed = true;
		this.unsubscribeBranch();
		this.unsubscribeAccountChanged();
		this.stopSettingsWatcher();
		this.state.gitCache?.dispose();
		this.state.gitCache = undefined;
		this.state.requestRender = undefined;
	}
}

export default function (pi: ExtensionAPI) {
	let state: FooterState | undefined;

	const requestRender = () => state?.requestRender?.();

	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		const nextState: FooterState = {
			ctx,
			model: ctx.model,
			thinkingLevel: ctx.thinkingLevel ?? "off",
			autoCompactionEnabled: readAutoCompactionEnabled(ctx),
		};
		state = nextState;

		ctx.ui.setFooter((tui: TUI, theme: Theme, footerData: ReadonlyFooterDataProvider) => {
			nextState.requestRender = () => tui.requestRender();

			if (ctx.isProjectTrusted()) {
				nextState.gitCache = new GitFooterCache({
					cwd: () => ctx.cwd,
					onChange: () => tui.requestRender(),
				});
			}

			const unsubscribeBranch = footerData.onBranchChange(() => tui.requestRender());
			const unsubscribeAccountChanged = pi.events.on(OPENAI_ACCOUNT_CHANGED_EVENT, () => tui.requestRender());
			const stopSettingsWatcher = watchAutoCompactionSetting(ctx, () => {
				if (!nextState.requestRender) return;
				const enabled = readAutoCompactionEnabled(ctx);
				if (enabled === nextState.autoCompactionEnabled) return;
				nextState.autoCompactionEnabled = enabled;
				tui.requestRender();
			});

			return new DefaultFooterComponent(
				nextState,
				theme,
				footerData,
				unsubscribeBranch,
				unsubscribeAccountChanged,
				stopSettingsWatcher,
			);
		});
	});

	pi.on("model_select", (event, ctx) => {
		if (!state || ctx.mode !== "tui") return;
		state.model = event.model;
		state.thinkingLevel = ctx.thinkingLevel ?? state.thinkingLevel;
		requestRender();
	});

	pi.on("thinking_level_select", (event, ctx) => {
		if (!state || ctx.mode !== "tui") return;
		state.thinkingLevel = event.level;
		requestRender();
	});

	pi.on("turn_end", (_event, ctx) => {
		if (ctx.mode === "tui") void state?.gitCache?.refresh();
	});

	pi.on("session_info_changed", (_event, ctx) => {
		if (ctx.mode === "tui") requestRender();
	});

	pi.on("session_compact", (_event, ctx) => {
		if (ctx.mode === "tui") requestRender();
	});

	pi.on("session_tree", (_event, ctx) => {
		if (ctx.mode === "tui") requestRender();
	});

	pi.on("agent_settled", (_event, ctx) => {
		if (ctx.mode === "tui") requestRender();
	});

	pi.on("session_shutdown", (_event, ctx) => {
		if (state) {
			state.gitCache?.dispose();
			state.gitCache = undefined;
			state.requestRender = undefined;
			state = undefined;
		}
		if (ctx.mode === "tui") ctx.ui.setFooter(undefined);
	});
}

export const __testing = {
	collectUsage,
	formatCwdForFooter,
	formatTokens,
	renderFooter,
	sanitizeStatusText,
};
