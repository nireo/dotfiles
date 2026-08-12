# Prompt clarifier

Conservatively rewrites the text currently in Pi's editor for clearer grammar and formatting. It does not submit the prompt: the result stays in the editor for review.

## Usage

- Press `Ctrl+Shift+E` while Pi is idle and the draft is in the editor.
- Press `Esc` while the clarifier is running to cancel it.

The extension asks the rewrite model to preserve intent, scope, constraints, ambiguity, technical identifiers, and tone; make the smallest useful edit; and never answer the prompt.

## Configuration

Edit `~/.pi/agent/prompt-clarifier.json`:

```json
{
  "model": "opencode-go/deepseek-v4-flash",
  "thinkingLevel": "max",
  "shortcut": "ctrl+shift+e",
  "maxTokens": 8192
}
```

`model` uses `provider/model-id` syntax. The model must appear in `pi --list-models` and have authentication configured. Valid thinking levels are `off`, `minimal`, `low`, `medium`, `high`, `xhigh`, and `max`.

Run `/reload` after changing the extension or its configuration. Because the shortcut is registered by the extension, configure it here rather than in `keybindings.json`.
