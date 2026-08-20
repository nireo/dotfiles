import { CustomEditor, type ExtensionAPI, type ThemeColor } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

const BAR = "▌";
const GAP = " ";
const PREFIX_WIDTH = 2;

type LayoutEntry = {
	component?: LayoutNode;
	minSize?: number;
};

type LayoutNode = {
	entries?: LayoutEntry[];
};

/**
 * Pi's fullscreen dock reserves three rows for its bordered editor. This
 * borderless editor needs only one; lowering that private layout entry removes
 * the otherwise unavoidable two blank rows above the prompt.
 */
function compactEditorDock(tui: unknown): void {
	const root = (tui as { layoutRoot?: LayoutNode }).layoutRoot;
	if (!root) return;

	const visit = (node: LayoutNode): boolean => {
		for (const entry of node.entries ?? []) {
			if (entry.minSize === 3) {
				entry.minSize = 1;
				return true;
			}
			if (entry.component && visit(entry.component)) return true;
		}
		return false;
	};

	visit(root);
}

const THINKING_COLORS = {
	off: "thinkingOff",
	minimal: "thinkingMinimal",
	low: "thinkingLow",
	medium: "thinkingMedium",
	high: "thinkingHigh",
	xhigh: "thinkingXhigh",
	max: "thinkingMax",
} as const satisfies Record<string, ThemeColor>;

function stripAnsi(text: string): string {
	return text.replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, "");
}

function isEditorBorder(line: string): boolean {
	const plain = stripAnsi(line);
	return /^─+$/.test(plain) || /^─── [↑↓] \d+ more (?:─+)?$/.test(plain);
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setEditorComponent((tui, theme, keybindings) => {
			compactEditorDock(tui);

			class ReasoningBarEditor extends CustomEditor {
				render(width: number): string[] {
					if (width <= PREFIX_WIDTH) return super.render(width);

					const innerWidth = width - PREFIX_WIDTH;
					const rendered = super.render(innerWidth);
					if (rendered.length < 3) return rendered;

					// CustomEditor renders: top border, input rows, bottom border,
					// then (optionally) autocomplete rows.
					const afterTop = rendered.slice(1);
					const bottomBorderIndex = afterTop.findIndex(
						(line, index) => index > 0 && isEditorBorder(line),
					);
					if (bottomBorderIndex < 0) return rendered;

					const color = THINKING_COLORS[pi.getThinkingLevel()];
					const prefix = ctx.ui.theme.fg(color, BAR) + GAP;
					const inputRows = afterTop.slice(0, bottomBorderIndex).map(
						(line) => prefix + truncateToWidth(line, innerWidth, ""),
					);
					const autocompleteRows = afterTop.slice(bottomBorderIndex + 1).map(
						(line) => " ".repeat(PREFIX_WIDTH) + truncateToWidth(line, innerWidth, ""),
					);

					return [...inputRows, ...autocompleteRows];
				}
			}

			return new ReasoningBarEditor(tui, theme, keybindings);
		});
	});
}
