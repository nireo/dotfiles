# Prompt clarifier

Rewrites the text currently in Pi's editor into a clear, precise technical prompt. Like pi-clarify, it compresses verbose descriptions into standard domain terms (e.g. "FLIP animation", "debounce", "optimistic update") while preserving intent, concrete details, and language. It does not submit the prompt: the result stays in the editor for review.

## Usage

- Press `Alt+E` (or `Cmd+E` on macOS) while Pi is idle and the draft is in the editor.
- Press `Esc` while the clarifier is running to cancel it.

The extension asks the rewrite model to compress verbose descriptions into precise technical terms without inventing anything, preserve intent and concrete details, and never answer the prompt.

## Configuration

Edit `~/.pi/agent/prompt-clarifier.json`:

```json
{
  "model": "opencode-go/deepseek-v4-flash",
  "thinkingLevel": "max",
  "shortcuts": ["alt+e", "super+e"]
}
```

`model` uses `provider/model-id` syntax. The model must appear in `pi --list-models` and have authentication configured. Valid thinking levels are `off`, `minimal`, `low`, `medium`, `high`, `xhigh`, and `max`.

`shortcuts` lists the keys that trigger clarification. `super` is the Command key on macOS and requires a terminal with the Kitty keyboard protocol (Pi enables it automatically in kitty). A single legacy `shortcut` string is still accepted as shorthand for a one-entry list.

## Troubleshooting

If a shortcut does nothing at all, the key is not reaching Pi. On macOS, kitty uses the Option key for unicode input unless `macos_option_as_alt` is enabled:

```conf
macos_option_as_alt left
```

in `kitty.conf` (followed by a **full kitty restart** — this option is not applied by config reload) makes `Alt+E` work with the **left** Option key. `Cmd+E` does not need this: kitty passes it through to Pi directly.

You should see a status line and spinner while the rewrite runs, plus a notification when it finishes. If it fails, the notification includes the error; the extension also logs details with a `[prompt-clarifier]` prefix in Pi's debug log.

Run `/reload` after changing the extension or its configuration. Because shortcuts are registered by the extension, configure them here rather than in `keybindings.json`.
