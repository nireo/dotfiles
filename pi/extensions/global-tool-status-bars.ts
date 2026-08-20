import { existsSync, realpathSync } from "node:fs";
import { dirname, join } from "node:path";
import { pathToFileURL } from "node:url";
import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

const BAR = "▌";
const GAP = " ";
const PREFIX_WIDTH = 2;
const PATCH_KEY = Symbol.for("eemil.pi.global-tool-status-bars");

type ToolResultState = { isError?: boolean };
type ToolExecutionInstance = {
	executionStarted?: boolean;
	isPartial?: boolean;
	result?: ToolResultState;
};
type ToolExecutionPrototype = {
	render(this: ToolExecutionInstance, width: number): string[];
	[PATCH_KEY]?: boolean;
};

function stripAnsi(text: string): string {
	return text
		.replace(/\x1b\][^\x07]*(?:\x07|\x1b\\)/g, "")
		.replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, "");
}

function alreadyHasBar(line: string): boolean {
	return stripAnsi(line).startsWith(`${BAR}${GAP}`);
}

function isImageProtocolLine(line: string): boolean {
	return line.includes("\x1b_G") || line.includes("\x1b]1337;File=") || line.includes("\x1bPq");
}

function statusColor(instance: ToolExecutionInstance): "dim" | "warning" | "success" | "error" {
	if (!instance.executionStarted) return "dim";
	if (instance.isPartial) return "warning";
	if (instance.result?.isError) return "error";
	return "success";
}

export function addStatusBars(
	prototype: ToolExecutionPrototype,
	theme: Pick<Theme, "fg">,
): void {
	if (prototype[PATCH_KEY]) return;

	const originalRender = prototype.render;
	prototype.render = function (width: number): string[] {
		if (width <= PREFIX_WIDTH) return originalRender.call(this, width);

		const lines = originalRender.call(this, width);
		const prefix = theme.fg(statusColor(this), BAR) + GAP;
		let skippedOuterSpacer = false;

		return lines.map((line) => {
			// ToolExecutionComponent adds one blank row before every card. Keep it
			// as spacing rather than turning it into part of the status bar.
			if (!skippedOuterSpacer && line === "") {
				skippedOuterSpacer = true;
				return line;
			}
			if (alreadyHasBar(line) || isImageProtocolLine(line)) return line;
			return prefix + truncateToWidth(line, width - PREFIX_WIDTH, "");
		});
	};

	Object.defineProperty(prototype, PATCH_KEY, { value: true });
}

async function patchPiToolRenderer(): Promise<void> {
	const entry = process.argv[1];
	if (!entry) return;

	const distDir = dirname(realpathSync(entry));
	const componentPath = join(distDir, "modes", "interactive", "components", "tool-execution.js");
	const themePath = join(distDir, "modes", "interactive", "theme", "theme.js");
	if (!existsSync(componentPath) || !existsSync(themePath)) return;

	const [{ ToolExecutionComponent }, { theme }] = await Promise.all([
		import(pathToFileURL(componentPath).href) as Promise<{
			ToolExecutionComponent: { prototype: ToolExecutionPrototype };
		}>,
		import(pathToFileURL(themePath).href) as Promise<{ theme: Theme }>,
	]);
	addStatusBars(ToolExecutionComponent.prototype, theme);
}

export default async function (_pi: ExtensionAPI) {
	await patchPiToolRenderer();
}
