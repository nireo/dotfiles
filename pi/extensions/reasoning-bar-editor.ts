import { CustomEditor, type ExtensionAPI, type ThemeColor } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const SGR_RESET = "\x1b[0m";

type LayoutEntry = {
	component?: LayoutNode;
	minSize?: number;
};

type LayoutNode = {
	entries?: LayoutEntry[];
};

type Rgb = { r: number; g: number; b: number };

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

/**
 * How strongly the editor background picks up the level's accent hue. Kept
 * small so the default foreground text stays fully legible; the value grows
 * gently with reasoning effort while staying dim enough that bright accents
 * (xhigh/max) never wash out the text.
 */
const LEVEL_TINT_ALPHA: Record<keyof typeof THINKING_COLORS, number> = {
	off: 0.045,
	minimal: 0.06,
	low: 0.07,
	medium: 0.085,
	high: 0.1,
	xhigh: 0.115,
	max: 0.13,
};

function stripAnsi(text: string): string {
	return text.replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, "");
}

function isEditorBorder(line: string): boolean {
	const plain = stripAnsi(line);
	return /^─+$/.test(plain) || /^─── [↑↓] \d+ more (?:─+)?$/.test(plain);
}

// ---------------------------------------------------------------------------
// Background tint computation
// ---------------------------------------------------------------------------

/** xterm palette entries 0-15 (same baseline mapping pi uses internally). */
const BASIC_16: Rgb[] = [
	"#000000", "#800000", "#008000", "#808000",
	"#000080", "#800080", "#008080", "#c0c0c0",
	"#808080", "#ff0000", "#00ff00", "#ffff00",
	"#0000ff", "#ff00ff", "#00ffff", "#ffffff",
].map((hex) => hexToRgb(hex));

const CUBE_VALUES = [0, 95, 135, 175, 215, 255];

function hexToRgb(hex: string): Rgb {
	const cleaned = hex.replace("#", "");
	return {
		r: Number.parseInt(cleaned.substring(0, 2), 16),
		g: Number.parseInt(cleaned.substring(2, 4), 16),
		b: Number.parseInt(cleaned.substring(4, 6), 16),
	};
}

function ansi256ToRgb(index: number): Rgb {
	if (index < 16) return BASIC_16[index] ?? { r: 0, g: 0, b: 0 };
	if (index < 232) {
		const cubeIndex = index - 16;
		return {
			r: CUBE_VALUES[Math.floor(cubeIndex / 36)] ?? 0,
			g: CUBE_VALUES[Math.floor((cubeIndex % 36) / 6)] ?? 0,
			b: CUBE_VALUES[cubeIndex % 6] ?? 0,
		};
	}
	const gray = 8 + (index - 232) * 10;
	return { r: gray, g: gray, b: gray };
}

function rgbTo256({ r, g, b }: Rgb): number {
	let bestIndex = 0;
	let bestDistance = Number.POSITIVE_INFINITY;
	for (let ri = 0; ri < 6; ri++) {
		for (let gi = 0; gi < 6; gi++) {
			for (let bi = 0; bi < 6; bi++) {
				const distance =
					(r - CUBE_VALUES[ri]!) ** 2 +
					(g - CUBE_VALUES[gi]!) ** 2 +
					(b - CUBE_VALUES[bi]!) ** 2;
				if (distance < bestDistance) {
					bestDistance = distance;
					bestIndex = 16 + 36 * ri + 6 * gi + bi;
				}
			}
		}
	}
	const grays = Array.from({ length: 24 }, (_, i) => 8 + i * 10);
	const average = Math.round((r + g + b) / 3);
	const isNeutral = Math.abs(r - g) < 10 && Math.abs(g - b) < 10 && Math.abs(r - b) < 10;
	if (isNeutral) {
		for (let i = 0; i < grays.length; i++) {
			const distance = Math.abs(average - grays[i]!);
			if (distance < bestDistance) {
				bestDistance = distance;
				bestIndex = 232 + i;
			}
		}
	}
	return bestIndex;
}

/**
 * Recover RGB values from a raw SGR sequence produced by theme.getFgAnsi /
 * theme.getBgAnsi, so the tint derives from the live theme instance.
 */
function parseSgrColor(ansi: string | undefined): Rgb | undefined {
	if (!ansi) return undefined;
	const truecolor = /^\x1b\[(?:38|48);2;(\d+);(\d+);(\d+)m$/.exec(ansi);
	if (truecolor) {
		return { r: Number(truecolor[1]), g: Number(truecolor[2]), b: Number(truecolor[3]) };
	}
	const indexed = /^\x1b\[(?:38|48);5;(\d+)m$/.exec(ansi);
	if (indexed) return ansi256ToRgb(Number(indexed[1]));
	return undefined;
}

function mixChannels(base: Rgb, tint: Rgb, alpha: number): Rgb {
	const clamp = (value: number) => Math.max(0, Math.min(255, Math.round(value)));
	return {
		r: clamp(base.r + (tint.r - base.r) * alpha),
		g: clamp(base.g + (tint.g - base.g) * alpha),
		b: clamp(base.b + (tint.b - base.b) * alpha),
	};
}

type ThemeLike = {
	getFgAnsi(color: ThemeColor): string;
	getBgAnsi(color: "userMessageBg"): string;
	getColorMode(): "truecolor" | "256color";
	fg(color: ThemeColor, text: string): string;
};

const bgCache = new WeakMap<ThemeLike, Map<string, string>>();

/**
 * Build the SGR sequence for the editor row background: the theme's own base
 * background mixed toward the current thinking level's accent color. Cached
 * per theme instance so runtime /theme switches pick up automatically.
 */
function editorRowBackground(theme: ThemeLike, level: keyof typeof THINKING_COLORS): string {
	let perTheme = bgCache.get(theme);
	if (!perTheme) {
		perTheme = new Map();
		bgCache.set(theme, perTheme);
	}
	const cached = perTheme.get(level);
	if (cached !== undefined) return cached;

	let sequence = "";
	try {
		const base =
			parseSgrColor(theme.getBgAnsi("userMessageBg")) ??
			parseSgrColor(theme.getFgAnsi("text")) ?? { r: 24, g: 24, b: 24 };
		const accent = parseSgrColor(theme.getFgAnsi(THINKING_COLORS[level])) ?? base;
		const tinted = mixChannels(base, accent, LEVEL_TINT_ALPHA[level]);
		sequence =
			theme.getColorMode() === "truecolor"
				? `\x1b[48;2;${tinted.r};${tinted.g};${tinted.b}m`
				: `\x1b[48;5;${rgbTo256(tinted)}m`;
	} catch {
		sequence = "";
	}
	perTheme.set(level, sequence);
	return sequence;
}

/**
 * Apply the background to one rendered row. Embedded SGR resets (the inverse
 * cursor, selection styles) would otherwise drop the background mid-row, so
 * re-assert it after every reset / explicit bg clear.
 */
function paintRow(line: string, background: string): string {
	if (!background) return line;
	const reasserted = line
		.replaceAll(SGR_RESET, SGR_RESET + background)
		.replaceAll("\x1b[49m", "\x1b[49m" + background);
	return background + reasserted;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setEditorComponent((tui, theme, keybindings) => {
			compactEditorDock(tui);

			class TintedEditor extends CustomEditor {
				render(width: number): string[] {
					const rendered = super.render(width);
					if (rendered.length < 3) return rendered;

					// CustomEditor renders: top border, input rows, bottom border,
					// then (optionally) autocomplete rows.
					const afterTop = rendered.slice(1);
					const bottomBorderIndex = afterTop.findIndex(
						(line, index) => index > 0 && isEditorBorder(line),
					);
					if (bottomBorderIndex < 0) return rendered;

					const level = pi.getThinkingLevel();
					const background = editorRowBackground(ctx.ui.theme, level);

					const padToWidth = (line: string): string => {
						const clipped = truncateToWidth(line, width, "");
						const pad = " ".repeat(Math.max(0, width - visibleWidth(clipped)));
						return clipped + pad;
					};

					const inputRows = afterTop.slice(0, bottomBorderIndex).map(
						(line) => paintRow(padToWidth(line), background),
					);
					const autocompleteRows = afterTop.slice(bottomBorderIndex + 1).map(
						(line) => paintRow(padToWidth(line), background),
					);

					return [...inputRows, ...autocompleteRows];
				}
			}

			return new TintedEditor(tui, theme, keybindings);
		});
	});
}
