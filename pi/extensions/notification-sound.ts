import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import { basename } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DEFAULT_SOUND = "/System/Library/Sounds/Purr.aiff";

function spawnDetached(command: string, args: string[]): void {
	const child = spawn(command, args, {
		detached: true,
		stdio: "ignore",
	});
	child.on("error", () => {
		// Notifications should never affect the agent session.
	});
	child.unref();
}

function playNotificationSound(): void {
	if (process.platform !== "darwin") return;

	const sound = process.env.PI_NOTIFICATION_SOUND ?? DEFAULT_SOUND;
	if (sound === "off" || sound === "0" || !existsSync(sound)) return;

	spawnDetached("afplay", [sound]);
}

function notifyTmux(cwd: string): void {
	const pane = process.env.TMUX_PANE;
	if (!process.env.TMUX || !pane) return;

	// Show a transient message in the active status bar. The bell marks a
	// background window with tmux's configured window-status-bell-style.
	const directory = basename(cwd) || cwd;
	spawnDetached("tmux", ["display-message", "-t", pane, `Pi done - ${directory}`]);
	process.stdout.write("\u0007");
}

export default function (pi: ExtensionAPI) {
	pi.on("agent_settled", (_event, ctx) => {
		// Only notify when the interactive editor is ready for another prompt.
		if (ctx.mode !== "tui") return;
		playNotificationSound();
		notifyTmux(ctx.cwd);
	});
}
