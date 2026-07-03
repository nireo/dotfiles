/**
 * Edit review mode for pi.
 *
 * Usage:
 *   /edit-review        -> toggle
 *   /edit-review on     -> enable review before edit/write tools mutate files
 *   /edit-review off    -> disable
 *   /edit-review status -> show current state
 *
 * When enabled, every built-in edit/write tool call is paused for user review.
 * Approving lets the tool run. Unapproving blocks the tool and sends your
 * required comment back to the model as the block reason.
 */
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { generateDiffString, getAgentDir } from "@earendil-works/pi-coding-agent";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, isAbsolute, join, resolve } from "node:path";
import { homedir } from "node:os";

const COMMAND_NAME = "edit-review";
const STATUS_KEY = "edit-review-mode";
const WIDGET_KEY = "edit-review-mode";
// Persist the toggle outside any one session so reloads/restarts keep the user's preference.
const STATE_PATH = join(getAgentDir(), "edit-review-mode.json");

// Only tools that mutate file contents need the approval gate.
const REVIEWED_TOOLS = new Set(["edit", "write"]);

// Keep modal previews readable; the real tool call still receives the full payload.
const MAX_PREVIEW_CHARS = 18_000;

type ModeState = { enabled: boolean };
type Replacement = { oldText: string; newText: string };

type EditInput = {
	path?: unknown;
	edits?: unknown;
	oldText?: unknown;
	newText?: unknown;
};

type WriteInput = {
	path?: unknown;
	content?: unknown;
};

// Mirror Pi's common path conveniences for preview reads: @file references,
// ~/ expansion, and relative paths based on the active session cwd.
function normalizePathForCwd(path: string, cwd: string): string {
	const withoutAt = path.startsWith("@") ? path.slice(1) : path;
	const expanded = withoutAt === "~" ? homedir() : withoutAt.startsWith("~/") ? join(homedir(), withoutAt.slice(2)) : withoutAt;
	return isAbsolute(expanded) ? expanded : resolve(cwd, expanded);
}

async function loadState(): Promise<ModeState> {
	try {
		const raw = await readFile(STATE_PATH, "utf8");
		const parsed = JSON.parse(raw) as Partial<ModeState>;
		return { enabled: parsed.enabled === true };
	} catch {
		return { enabled: false };
	}
}

async function saveState(state: ModeState): Promise<void> {
	await mkdir(dirname(STATE_PATH), { recursive: true });
	await writeFile(STATE_PATH, `${JSON.stringify(state, null, 2)}\n`, "utf8");
}

function truncatePreview(text: string): string {
	if (text.length <= MAX_PREVIEW_CHARS) return text;
	const keep = Math.floor((MAX_PREVIEW_CHARS - 120) / 2);
	return `${text.slice(0, keep)}\n\n... [preview truncated: ${text.length - keep * 2} chars omitted] ...\n\n${text.slice(-keep)}`;
}

// Normalize the shapes Pi's edit tool accepts so the preview can be shown even
// before the built-in tool validates and executes the call.
function normalizeEditInput(input: EditInput): { path?: string; edits: Replacement[] } {
	const path = typeof input.path === "string" ? input.path : undefined;
	let rawEdits = input.edits;

	if (typeof rawEdits === "string") {
		try {
			rawEdits = JSON.parse(rawEdits);
		} catch {
			// Leave invalid JSON alone; validation below will turn this into a raw preview.
		}
	}

	const edits: Replacement[] = [];
	if (Array.isArray(rawEdits)) {
		for (const edit of rawEdits) {
			if (!edit || typeof edit !== "object") continue;
			const candidate = edit as { oldText?: unknown; newText?: unknown };
			if (typeof candidate.oldText === "string" && typeof candidate.newText === "string") {
				edits.push({ oldText: candidate.oldText, newText: candidate.newText });
			}
		}
	}

	// Backward-compatible shape occasionally produced by older model/tool calls.
	if (typeof input.oldText === "string" && typeof input.newText === "string") {
		edits.push({ oldText: input.oldText, newText: input.newText });
	}

	return { path, edits };
}

// Build a best-effort preview using exact matching. The built-in edit tool is
// still the source of truth when approved, including its richer fuzzy matching.
function applyExactEdits(baseContent: string, edits: Replacement[], path: string): string {
	const matches = edits.map((edit, index) => {
		if (edit.oldText.length === 0) throw new Error(`edits[${index}].oldText is empty.`);
		const first = baseContent.indexOf(edit.oldText);
		if (first === -1) throw new Error(`edits[${index}].oldText was not found in ${path}.`);
		const second = baseContent.indexOf(edit.oldText, first + edit.oldText.length);
		if (second !== -1) throw new Error(`edits[${index}].oldText appears more than once in ${path}.`);
		return { index, start: first, end: first + edit.oldText.length, newText: edit.newText };
	});

	matches.sort((a, b) => a.start - b.start);
	for (let i = 1; i < matches.length; i++) {
		if (matches[i - 1].end > matches[i].start) {
			throw new Error(`edits[${matches[i - 1].index}] and edits[${matches[i].index}] overlap.`);
		}
	}

	let next = baseContent;
	for (const match of [...matches].reverse()) {
		next = `${next.slice(0, match.start)}${match.newText}${next.slice(match.end)}`;
	}
	return next;
}

function rawEditSummary(path: string | undefined, edits: Replacement[]): string {
	const lines = [`Tool: edit`, `Path: ${path ?? "[missing path]"}`, `Replacements: ${edits.length}`];
	for (let i = 0; i < edits.length; i++) {
		lines.push(``, `--- edits[${i}].oldText ---`, edits[i].oldText, `--- edits[${i}].newText ---`, edits[i].newText);
	}
	return truncatePreview(lines.join("\n"));
}

// For edit calls, show the same kind of diff the user will care about. If the
// preview cannot be computed, fall back to raw replacement text instead of failing closed.
async function buildEditPreview(input: EditInput, cwd: string): Promise<string> {
	const { path, edits } = normalizeEditInput(input);
	if (!path || edits.length === 0) return rawEditSummary(path, edits);

	try {
		const absolutePath = normalizePathForCwd(path, cwd);
		const baseContent = await readFile(absolutePath, "utf8");
		const nextContent = applyExactEdits(baseContent, edits, path);
		const diff = generateDiffString(baseContent, nextContent).diff || "[no visible diff]";
		return truncatePreview([`Tool: edit`, `Path: ${path}`, `Replacements: ${edits.length}`, ``, diff].join("\n"));
	} catch (error) {
		const reason = error instanceof Error ? error.message : String(error);
		return [`Tool: edit`, `Path: ${path}`, `Replacements: ${edits.length}`, ``, `Preview unavailable: ${reason}`, ``, rawEditSummary(path, edits)].join("\n");
	}
}

// For write calls, diff against the existing file when present; missing files
// are treated as an empty base so the user can review the full new content.
async function buildWritePreview(input: WriteInput, cwd: string): Promise<string> {
	const path = typeof input.path === "string" ? input.path : undefined;
	const content = typeof input.content === "string" ? input.content : undefined;
	if (!path || content === undefined) {
		return truncatePreview(`Tool: write\nPath: ${path ?? "[missing path]"}\n\n[invalid or missing content]`);
	}

	let existing = "";
	let note = "Overwrites existing file";
	try {
		existing = await readFile(normalizePathForCwd(path, cwd), "utf8");
	} catch {
		note = "Creates new file";
	}

	const diff = generateDiffString(existing, content).diff || "[no visible diff]";
	return truncatePreview([`Tool: write`, `Path: ${path}`, note, `Bytes: ${content.length}`, ``, diff].join("\n"));
}

async function buildPreview(toolName: string, input: unknown, cwd: string): Promise<string> {
	if (toolName === "edit") return buildEditPreview((input ?? {}) as EditInput, cwd);
	if (toolName === "write") return buildWritePreview((input ?? {}) as WriteInput, cwd);
	return `Tool: ${toolName}`;
}

function updateUi(ctx: ExtensionContext, enabled: boolean): void {
	if (!ctx.hasUI) return;

	if (!enabled) {
		ctx.ui.setStatus(STATUS_KEY, undefined);
		ctx.ui.setWidget(WIDGET_KEY, undefined);
		return;
	}

	// Keep the active-mode indicator in the footer only. A persistent widget above
	// the editor caused unnecessary full-screen redraws/flicker during streaming.
	ctx.ui.setStatus(STATUS_KEY, "👀 edit review");
	ctx.ui.setWidget(WIDGET_KEY, undefined);
}

// Require a human-readable reason for unapproval so the next model turn knows
// exactly what to fix before trying another edit.
async function requestUnapproveComment(ctx: ExtensionContext): Promise<string | undefined> {
	while (true) {
		const comment = await ctx.ui.editor(
			"Unapprove comment",
			"Explain what the model should fix before this file edit can be approved.",
		);
		if (comment === undefined) {
			const next = await ctx.ui.select("A comment is required to unapprove an edit.", ["Add comment", "Cancel review"]);
			if (next !== "Add comment") return undefined;
			continue;
		}

		const trimmed = comment.trim();
		if (trimmed.length > 0) return trimmed;
		ctx.ui.notify("Please enter a non-empty comment to unapprove the edit.", "warning");
	}
}

export default async function editReviewModeExtension(pi: ExtensionAPI) {
	let enabled = (await loadState()).enabled;
	let lastRenderedEnabled: boolean | undefined;

	function renderUiIfChanged(ctx: ExtensionContext, force = false): void {
		if (!force && lastRenderedEnabled === enabled) return;
		lastRenderedEnabled = enabled;
		updateUi(ctx, enabled);
	}

	async function setEnabled(ctx: ExtensionContext, next: boolean): Promise<void> {
		enabled = next;
		await saveState({ enabled });
		renderUiIfChanged(ctx, true);
		ctx.ui.notify(`Edit review mode ${enabled ? "enabled" : "disabled"}.`, "info");
	}

	pi.registerCommand(COMMAND_NAME, {
		description: "Toggle review/approval for edit and write tool calls",
		getArgumentCompletions(prefix) {
			const actions = ["toggle", "on", "off", "status"];
			const items = actions
				.filter((action) => action.startsWith(prefix.toLowerCase()))
				.map((action) => ({ value: action, label: action }));
			return items.length > 0 ? items : null;
		},
		handler: async (args, ctx) => {
			const action = args.trim().toLowerCase();
			switch (action) {
				case "":
				case "toggle":
					await setEnabled(ctx, !enabled);
					return;
				case "on":
				case "enable":
					await setEnabled(ctx, true);
					return;
				case "off":
				case "disable":
					await setEnabled(ctx, false);
					return;
				case "status":
					updateUi(ctx, enabled);
					ctx.ui.notify(`Edit review mode is ${enabled ? "ON" : "OFF"}.`, "info");
					return;
				default:
					ctx.ui.notify(`Usage: /${COMMAND_NAME} [on|off|toggle|status]`, "warning");
			}
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		renderUiIfChanged(ctx, true);
	});

	// Tell the model how to respond if an edit is rejected by the human reviewer.
	pi.on("before_agent_start", async (event, ctx) => {
		renderUiIfChanged(ctx);
		if (!enabled) return undefined;

		return {
			systemPrompt:
				event.systemPrompt +
				`\n\n[Edit review mode is active]\n` +
				`- Built-in edit and write tool calls require user approval before changing files.\n` +
				`- If a tool call is blocked as unapproved, read the user's comment in the block reason, fix the issue, and try again.`,
		};
	});

	// This is the actual approval gate: block reviewed tools until the user approves.
	pi.on("tool_call", async (event, ctx) => {
		if (!enabled || !REVIEWED_TOOLS.has(event.toolName)) return undefined;

		if (!ctx.hasUI) {
			return {
				block: true,
				reason: `Edit review mode is enabled, but this pi mode has no review UI. Tool "${event.toolName}" was blocked.`,
			};
		}

		const preview = await buildPreview(event.toolName, event.input, ctx.cwd);
		const choice = await ctx.ui.select(`Review file edit\n\n${preview}\n\nApprove this change?`, [
			"Approve",
			"Unapprove",
		]);

		if (choice === "Approve") return undefined;

		if (choice === "Unapprove") {
			const comment = await requestUnapproveComment(ctx);
			return {
				block: true,
				reason: comment
					? `User unapproved this file edit. Fix requested: ${comment}`
					: "User cancelled the edit review without approving the file change.",
			};
		}

		return { block: true, reason: "User cancelled the edit review without approving the file change." };
	});
}
