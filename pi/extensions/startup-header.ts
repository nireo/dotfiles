/**
 * Custom startup header
 *
 * Replaces pi's built-in startup screen (logo + long keybinding hint list +
 * plain [Skills] / [Extensions] listings) with a compact styled header:
 *
 *   pi v0.83.0
 *
 *   Skills - 4
 *     pdf-reader            profile-performance  review-systems-code
 *
 *   Extensions - 9
 *     ask_user_question     context              discuss
 *     exit                  minimal-footer      notification-sound
 *     permission-gate       quiet-tools         startup-header
 *
 * Press ctrl+o (app.tools.expand) to expand the full built-in keybinding
 * hints; press ctrl+o again to collapse back.
 *
 * Requires `quietStartup: true` in ~/.pi/agent/settings.json so the built-in
 * plain resource listing is hidden (this header replaces it).
 */

import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { VERSION, getAgentDir, keyHint, keyText, rawKeyHint } from "@earendil-works/pi-coding-agent";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

// --- Resource discovery ----------------------------------------------------

/** Skill display name from SKILL.md frontmatter, falling back to dir name. */
function skillName(skillDir: string, fallback: string): string {
	try {
		const line = readFileSync(join(skillDir, "SKILL.md"), "utf8")
			.split("\n")
			.find((l) => l.startsWith("name:"));
		if (line) {
			const name = line.slice(5).trim().replace(/^["']|["']$/g, "");
			if (name) return name;
		}
	} catch {
		// fall through to dir name
	}
	return fallback;
}

function listSkills(root: string): string[] {
	try {
		return readdirSync(root, { withFileTypes: true })
			// Symlink-aware: pi itself follows symlinks to skill dirs
			.filter(
				(e) =>
					(e.isDirectory() || e.isSymbolicLink()) &&
					existsSync(join(root, e.name, "SKILL.md")),
			)
			.map((e) => skillName(join(root, e.name), e.name))
			.sort((a, b) => a.localeCompare(b));
	} catch {
		return [];
	}
}

function hasEntryPoint(dir: string): boolean {
	if (existsSync(join(dir, "index.ts")) || existsSync(join(dir, "index.js"))) {
		return true;
	}
	try {
		const pkg = JSON.parse(readFileSync(join(dir, "package.json"), "utf8")) as {
			pi?: { extensions?: string[] };
		};
		return Array.isArray(pkg.pi?.extensions) && pkg.pi.extensions.length > 0;
	} catch {
		return false;
	}
}

function listExtensions(root: string): string[] {
	try {
		return readdirSync(root, { withFileTypes: true })
			.flatMap((e) =>
				// Same rules as pi: *.ts/*.js files, or dirs with index/package.json manifest
				(e.isFile() || e.isSymbolicLink()) && (e.name.endsWith(".ts") || e.name.endsWith(".js"))
					? [e.name.replace(/\.(ts|js)$/, "")]
					: (e.isDirectory() || e.isSymbolicLink()) && hasEntryPoint(join(root, e.name))
						? [e.name]
						: [],
			)
			.sort((a, b) => a.localeCompare(b));
	} catch {
		return [];
	}
}

// --- Rendering --------------------------------------------------------------

/** Three-column grid, aligned on the first column. Names must be plain (no ANSI). */
function grid3(names: string[]): string[] {
	const width = Math.max(...names.map((n) => n.length));
	const lines: string[] = [];
	for (let i = 0; i < names.length; i += 3) {
		lines.push(names.slice(i, i + 3).map((n) => n.padEnd(width)).join("  ").trimEnd());
	}
	return lines.map((l) => `  ${l}`);
}

function section(title: string, count: number, names: string[], theme: Theme): string[] {
	const header = theme.bold(theme.fg("accent", title)) + theme.fg("dim", ` - ${count}`);
	return [header, ...grid3(names)];
}

const OPENING_ART = [
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣶⠿⠿⠿⣶⣦⣀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠛⠉⠀⠀⠀⠀⠀⠀⠉⠻⣧⡀⠀",
	"⢠⣄⣀⣀⣀⣀⣀⣀⣀⣴⠋⠀⠀⠀⠀⠀⣴⣆⠀⠀⠀⠀⠘⣿⡀",
	"⠀⠙⠻⣿⣟⠛⠛⠛⠋⠁⠀⠀⠀⠀⠀⠘⠿⠋⠀⠀⠀⠀⠀⣿⡇",
	"⠀⠀⠀⠀⠙⢷⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⡇",
	"⠀⠀⠀⠀⠀⠀⠘⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣽⠃",
	"⠀⠀⠀⠀⠀⠀⢰⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀",
	"⠀⠀⠀⠀⠀⠀⣾⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡿⠀",
	"⠀⠀⠀⠀⠀⢸⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠃⠀",
	"⠀⠀⠀⠀⢀⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡟⠀⠀",
	"⠀⠀⠀⠀⣾⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠇⠀⠀",
] as const;

function openingArt(theme: Theme): string[] {
	return OPENING_ART.map((line) => theme.fg("accent", line));
}

function logo(theme: Theme): string {
	return theme.bold(theme.fg("accent", "pi")) + theme.fg("dim", ` v${VERSION}`);
}

// Full built-in keybinding hint list, shown when expanded
function expandedHints(theme: Theme): string {
	const hint = (keybinding: string, description: string) => keyHint(keybinding, description);
	return [
		hint("app.interrupt", "to interrupt"),
		hint("app.clear", "to clear"),
		rawKeyHint(`${keyText("app.clear")} twice`, "to exit"),
		hint("app.exit", "to exit (empty)"),
		hint("app.suspend", "to suspend"),
		keyHint("tui.editor.deleteToLineEnd", "to delete to end"),
		hint("app.thinking.cycle", "to cycle thinking level"),
		rawKeyHint(`${keyText("app.model.cycleForward")}/${keyText("app.model.cycleBackward")}`, "to cycle models"),
		hint("app.model.select", "to select model"),
		hint("app.tools.expand", "to expand tools"),
		hint("app.thinking.toggle", "to expand thinking"),
		hint("app.editor.external", "for external editor"),
		rawKeyHint("/", "for commands"),
		rawKeyHint("!", "to run bash"),
		rawKeyHint("!!", "to run bash (no context)"),
		hint("app.message.followUp", "to queue follow-up"),
		hint("app.message.dequeue", "to edit all queued messages"),
		hint("app.clipboard.pasteImage", "to paste image (with text fallback)"),
		rawKeyHint("drop files", "to attach"),
	].join("\n");
}

// Blank lines between the startup header and the input box below it, so the
// text box isn't flush against the skills/extensions listing on launch.
const HEADER_BOTTOM_PADDING = 3;

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		// Collect resources once at startup (global + project scope), like the
		// built-in listing does.
		const agentDir = getAgentDir();
		const projectDir = join(ctx.cwd, ".pi");
		const skills = [
			...new Set([
				...listSkills(join(agentDir, "skills")),
				...listSkills(join(projectDir, "skills")),
			]),
		].sort((a, b) => a.localeCompare(b));
		const extensions = [
			...new Set([
				...listExtensions(join(agentDir, "extensions")),
				...listExtensions(join(projectDir, "extensions")),
			]),
		].sort((a, b) => a.localeCompare(b));

		ctx.ui.setHeader((tui, theme) => {
			let expanded = false;
			const collapsed: string[] = [...openingArt(theme), "", logo(theme)];
			if (skills.length > 0) {
				collapsed.push("", ...section("Skills", skills.length, skills, theme));
			}
			if (extensions.length > 0) {
				collapsed.push("", ...section("Extensions", extensions.length, extensions, theme));
			}
			// Padding between the header and the input box below it
			const padding: string[] = Array.from({ length: HEADER_BOTTOM_PADDING }, () => "");
			return {
				render(): string[] {
					return expanded
						? [...collapsed, "", expandedHints(theme), ...padding]
						: [...collapsed, ...padding];
				},
				invalidate() {},
				setExpanded(value: boolean) {
					expanded = value;
					tui.requestRender();
				},
			};
		});
	});
}
