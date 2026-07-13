import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DEFAULT_SOUND = "/System/Library/Sounds/Glass.aiff";

function playNotificationSound(): void {
	if (process.platform !== "darwin") return;

	const sound = process.env.PI_NOTIFICATION_SOUND ?? DEFAULT_SOUND;
	if (sound === "off" || sound === "0" || !existsSync(sound)) return;

	const player = spawn("afplay", [sound], {
		detached: true,
		stdio: "ignore",
	});
	player.on("error", () => {
		// Notifications should never affect the agent session.
	});
	player.unref();
}

export default function (pi: ExtensionAPI) {
	pi.on("agent_settled", (_event, ctx) => {
		// Only notify when the interactive editor is ready for another prompt.
		if (ctx.mode !== "tui") return;
		playNotificationSound();
	});
}
