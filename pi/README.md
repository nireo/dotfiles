# Pi extensions

This directory is the global Pi configuration directory (`~/.pi/agent` is a symlink to it). Files under `extensions/` are loaded automatically for every Pi session. Run `/reload` after changing an extension.

## Extensions

### `extensions/ask_user_question.ts`

Adds the `ask_user_question` tool. It lets Pi pause and ask one question through the interactive UI, using either free-form text, single-select options, or multi-select options. Users can cancel or provide a custom “Other” answer. The tool reports structured answers back to the agent and is unavailable in non-interactive modes.

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

### `extensions/notification-sound.ts`

Plays the macOS Glass notification sound when an interactive Pi agent run has fully settled and is ready for another prompt. It uses `/System/Library/Sounds/Glass.aiff` and `afplay`.

- Disable it with `PI_NOTIFICATION_SOUND=off`.
- Use a custom sound with `PI_NOTIFICATION_SOUND=/path/to/sound.aiff`.
- It only plays in Pi’s interactive TUI and is ignored on non-macOS systems.

## Notes

Extensions run with Pi’s process permissions, so review changes before enabling them. Global extensions apply to all projects; project-local extensions can be placed in a project’s `.pi/extensions/` directory.
