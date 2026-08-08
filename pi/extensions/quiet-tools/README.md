# quiet-tools

A pi extension that makes collapsed built-in tool rows much quieter in the TUI.

When enabled, each covered collapsed tool row renders a compact invocation wrapped to the terminal width plus a separate `(Ctrl+O to expand)` hint line. A small status marker shows `·` pending, `…` running, `✓` success, or `✗` failure. Tool output is hidden until expanded. Expanding with `Ctrl+O` still shows pi's full rendered output and the normal Pi tool background. The `edit` tool is intentionally left on Pi's normal renderer so its diff and status remain visible.

`quiet-tools` only changes the visual renderer. It does not truncate, summarize, or rewrite the actual tool results sent to the model.

## Covered tools

- `bash`
- `read`
- `grep`
- `find`
- `ls`
- `write`

For every covered tool, the collapsed invocation wraps to the terminal width so long paths and commands remain visible without showing their result output. Expanding restores pi's normal renderer; `edit` is normal by default.

## Commands

```text
/quiet-tools status
/quiet-tools off
/quiet-tools on
/quiet-tools toggle
```

The extension starts enabled by default. Disabling is temporary for the current extension runtime/session; after `/reload`, `/new`, `/resume`, or `/fork`, it starts enabled again.

## Install

### Standalone npm package

```bash
pi install npm:@diegopetrucci/pi-quiet-tools
```

### Collection package

```bash
pi install npm:@diegopetrucci/pi-extensions
```

### GitHub package

```bash
pi install git:github.com/diegopetrucci/pi-extensions
```

Then reload pi:

```text
/reload
```

## Notes

- This extension overrides pi's built-in tool definitions so it can customize only their TUI renderers.
- It reuses pi's built-in implementations and preserves `shellPath`, `shellCommandPrefix`, and image autoresize settings when they are available from settings files.
- If another extension also overrides built-in tool execution, pi's extension load order determines which override wins.
- It affects assistant-invoked tool rows. User `!`/`!!` bash commands are rendered by a separate pi component and keep pi's default preview behavior.
- Pi renders image attachments outside tool result renderers, so inline image display for image reads is still controlled by pi's image settings.
