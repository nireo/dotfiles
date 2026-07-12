import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { loadReviewData } from "./git.js";
import { composeDiscussionPrompt } from "./prompt.js";
import { runDiscussionReview } from "./review-app.js";

export default function discussExtension(pi: ExtensionAPI): void {
  let reviewOpen = false;

  const openDiscussion = async (ctx: ExtensionContext): Promise<void> => {
    if (ctx.mode !== "tui") {
      ctx.ui.notify("/discuss needs Pi's interactive TUI.", "warning");
      return;
    }
    if (!ctx.isIdle()) {
      ctx.ui.notify("Wait for the current agent turn to finish before opening /discuss.", "warning");
      return;
    }
    if (reviewOpen) {
      ctx.ui.notify("A discussion review is already open.", "warning");
      return;
    }

    reviewOpen = true;
    try {
      const data = await loadReviewData(pi, ctx.cwd);
      if (data.files.length === 0) {
        const skipped = data.skippedFiles > 0 ? ` (${data.skippedFiles} binary or oversized file${data.skippedFiles === 1 ? "" : "s"} skipped)` : "";
        ctx.ui.notify(`No text changes to discuss${skipped}.`, "info");
        return;
      }
      if (data.skippedFiles > 0) {
        ctx.ui.notify(`${data.skippedFiles} binary or oversized file${data.skippedFiles === 1 ? " was" : "s were"} skipped.`, "warning");
      }

      const annotations = await runDiscussionReview(ctx, data);
      if (annotations == null || annotations.length === 0) return;

      pi.sendUserMessage(composeDiscussionPrompt(annotations));
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      ctx.ui.notify(`Could not open discussion review: ${message}`, "error");
    } finally {
      reviewOpen = false;
    }
  };

  pi.registerCommand("discuss", {
    description: "Review the current git diff and send annotated feedback to the agent",
    handler: async (_args, ctx) => openDiscussion(ctx),
  });


  pi.on("session_shutdown", () => {
    reviewOpen = false;
  });
}
