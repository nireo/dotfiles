# Pi extensions

This directory is the global Pi configuration directory (`~/.pi/agent` is a symlink to it). Files under `extensions/` are loaded automatically for every Pi session. Run `/reload` after changing an extension.

## Theme

`themes/gray-tools-light.json` and `themes/gray-tools-dark.json` keep every tool execution background neutral gray for both built-in and default-shell custom tools. `settings.json` selects the matching theme automatically for light or dark terminals.

## Extensions

### `extensions/ask_user_question.ts`

Adds the `ask_user_question` tool. It lets Pi pause and ask one question through the interactive UI, using either free-form text, single-select options, or multi-select options. Users can cancel or provide a custom “Other” answer. The tool reports structured answers back to the agent and is unavailable in non-interactive modes.

### `extensions/context.ts`

Adds `/context`, an interactive overlay showing estimated context-window usage as a colored grid. It breaks usage down by prompts, messages, thinking, tool results, images, compaction, and free space, and includes cache/cost statistics plus compaction suggestions.

### `extensions/default-footer/`

Replaces Pi's built-in footer with a local replica of the regular statusline, including cached Git markers beside the branch and account-aware ChatGPT 5-hour/7-day limits for OpenAI Codex models. Its directory/branch/session, usage/context, model/thinking, experimental, and extension-status components are easy to customize. See `extensions/default-footer/README.md`.

### `extensions/discuss/`

Adds the `/discuss` command, a keyboard-first review UI for the current Git diff against `HEAD`.

- Reviews staged and unstaged changes plus untracked text files.
- Skips binary files and files larger than 750 KB.
- Annotates lines or whole files as `FIX` or `DISCUSS`.
- Sends all saved annotations back to Pi as a prompt.
- Requires the interactive TUI; use the key reference in `extensions/discuss/README.md`.

`index.ts` is the Pi entry point. The implementation and tests live under `src/`; its local package declares the `@pierre/diffs` dependency.

### `extensions/exit.ts`

Adds `/exit` as a slash-command alias for Pi’s graceful shutdown. It stops immediately when Pi is idle, or waits for an active run to finish.

### `extensions/minimal-footer/`

Keeps the minimal-footer OpenAI/git statusline implementation available but disabled; Pi’s regular footer is unchanged. See `extensions/minimal-footer/README.md` for details.

### `extensions/openai-accounts.ts`

Adds `/account` (or `/openai-account`) to switch between two OpenAI Codex accounts without duplicating OpenAI’s models. Both accounts share the canonical `openai-codex` model catalog; `/account login 1` and `/account login 2` store separate credentials, while `/account 1` and `/account 2` switch credentials without changing the selected model. Rename accounts with `/account rename 1 Personal`; the selected name appears on the footer row above the model, alongside the working directory and Git status.

Account names and credentials are stored as private files under `openai-accounts/`, which is ignored by Git. Existing credentials from the previous two-provider version are imported automatically.

### `extensions/notification-sound.ts`

Plays the macOS Glass notification sound when an interactive Pi agent run has fully settled and is ready for another prompt. It uses `/System/Library/Sounds/Glass.aiff` and `afplay`.

- Disable it with `PI_NOTIFICATION_SOUND=off`.
- Use a custom sound with `PI_NOTIFICATION_SOUND=/path/to/sound.aiff`.
- It only plays in Pi’s interactive TUI and is ignored on non-macOS systems.

### `extensions/permission-gate/`

Prompts before potentially dangerous Bash commands (`rm -rf`, `sudo`, and unsafe `chmod`/`chown`) or writes/edits to protected paths such as `.git`, `node_modules`, and secret-bearing `.env` files. Matching operations are blocked by default without an interactive UI.

### `extensions/prompt-clarifier/`

Adds `Alt+E` / `Cmd+E` to conservatively improve the current editor prompt with a separately configured model, then leaves the result in the editor for review. The default is `opencode-go/deepseek-v4-flash` at max thinking. Configure the model, thinking level, shortcut, and output limit in `prompt-clarifier.json`; see `extensions/prompt-clarifier/README.md`.

### `extensions/quiet-tools/`

Compacts collapsed built-in tool rows (except `edit`) to wrapped invocations plus an expand hint, with small pending/running/success/failure markers. The `edit` tool keeps Pi’s normal diff, status, and background rendering. Use `/quiet-tools on|off|toggle|status` to control it for the current session.

### `extensions/startup-header.ts`

Replaces Pi’s default startup resource listing with a compact, styled header showing the Pi version plus discovered skills and extensions. With `quietStartup: true`, `Ctrl+O` expands the header to show the full keybinding hints.

## Skills

### `skills/teach/`

Provides adaptive teaching with prerequisite probing, verified Mermaid learning plans, one-step explanations, active assessment, cross-session progress, and source-grounded Anki handoff after demonstrated understanding. Its dependency-free helper stores validated private learner state under `~/.pi/agent/learner-state/`; that directory is ignored by Git. Run the helper tests with `python3 -m unittest discover -s skills/teach/tests -v`.

## Notes

Extensions run with Pi’s process permissions, so review changes before enabling them. Global extensions apply to all projects; project-local extensions can be placed in a project’s `.pi/extensions/` directory.
