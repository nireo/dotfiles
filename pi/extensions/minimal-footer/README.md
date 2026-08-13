# minimal-footer

This checked-in copy retains the upstream minimal-footer OpenAI usage and git
status code, but its statusline registration is currently disabled. Pi's
regular footer is therefore unchanged. The registration call is left commented
in `index.ts` for easy re-enablement later.

## Retained statusline implementation

If re-enabled, the statusline will include the following. When using
`openai-codex`, it includes the available subscription windows:

```text
5h 12% · 7d 38%
```

For trusted Git projects it also includes cached dirty/ahead/behind counts and
an optional pull-request number:

```text
5h 12% · 7d 38% · +1 ~2 ?3 ↑1 • PR #42
```

The markers are `!` conflicts, `+` staged, `~` unstaged, `?` untracked, `↑`
ahead, and `↓` behind. Git polling is skipped until Pi reports that the
project is trusted, and `git status` runs with fsmonitor disabled.

The regular Pi footer continues to provide the branch, repository, context,
model, and thinking-level information.

## Install

### Standalone npm package

```bash
pi install npm:@diegopetrucci/pi-minimal-footer
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

## Configuration

The upstream config format is retained. When this add-on is enabled,
`codexUsage` and `gitStatus` control the displayed statusline segments; the
other upstream fields are retained for compatibility. Config files are merged,
with project config overriding global config:

- `~/<pi-config-dir>/agent/extensions/minimal-footer.json`
- `<project>/<pi-config-dir>/minimal-footer.json`

Here `<pi-config-dir>` is Pi's runtime config directory name (`CONFIG_DIR_NAME`; `.pi` by default). Project config is only read after Pi reports that the project is trusted.

A ready-to-copy sample file is included at [`minimal-footer.example.json`](./minimal-footer.example.json).

Example:

```json
{
  "context": {
    "showPercent": true,
    "dumbZone": {
      "enabled": true,
      "thresholdTokens": 200000,
      "label": "DUMB ZONE",
      "color": "error"
    }
  },
  "codexUsage": {
    "enabled": true,
    "cacheTtlMs": 300000,
    "requestTimeoutMs": 10000,
    "windows": {
      "primary": {
        "enabled": true,
        "label": "5h"
      },
      "secondary": {
        "enabled": true,
        "label": "7d"
      }
    }
  },
  "experimentalMarker": {
    "enabled": true,
    "label": "xp",
    "color": "warning"
  },
  "gitStatus": {
    "enabled": true,
    "refreshIntervalMs": 8000,
    "gitTimeoutMs": 1500,
    "ghTimeoutMs": 3000
  }
}
```

Disable `DUMB ZONE`:

```json
{
  "context": {
    "dumbZone": {
      "enabled": false
    }
  }
}
```

Disable OpenAI Codex session-limit usage entirely:

```json
{
  "codexUsage": {
    "enabled": false
  }
}
```

Disable one session-limit window:

```json
{
  "codexUsage": {
    "windows": {
      "secondary": {
        "enabled": false
      }
    }
  }
}
```

Disable the experimental-features marker:

```json
{
  "experimentalMarker": {
    "enabled": false
  }
}
```

Disable git dirty/ahead/PR status:

```json
{
  "gitStatus": {
    "enabled": false
  }
}
```

### Config fields

- `context.showPercent`: show the context percentage
- `context.dumbZone.enabled`: show `DUMB ZONE` when context tokens exceed the threshold
- `context.dumbZone.thresholdTokens`: token threshold for `DUMB ZONE`
- `context.dumbZone.label`: warning text
- `context.dumbZone.color`: theme color for the warning (`error`, `warning`, `accent`, `text`, or `dim`)
- `codexUsage.enabled`: show OpenAI Codex session-limit usage when using `openai-codex`
- `codexUsage.cacheTtlMs`: in-memory usage cache duration
- `codexUsage.requestTimeoutMs`: usage request timeout
- `codexUsage.windows.primary.enabled`: show the primary usage window
- `codexUsage.windows.primary.label`: label for the primary usage window
- `codexUsage.windows.secondary.enabled`: show the secondary usage window
- `codexUsage.windows.secondary.label`: label for the secondary usage window
- `experimentalMarker.enabled`: show the marker when `PI_EXPERIMENTAL=1`
- `experimentalMarker.label`: marker text
- `experimentalMarker.color`: theme color for the marker (`error`, `warning`, `accent`, `text`, or `dim`)
- `gitStatus.enabled`: show cached git dirty counts, ahead/behind counts, and optional PR number for trusted projects
- `gitStatus.refreshIntervalMs`: background git status refresh interval
- `gitStatus.gitTimeoutMs`: timeout for `git status --porcelain=v2 --branch`
- `gitStatus.ghTimeoutMs`: timeout for best-effort `gh pr view`

## What it retains

- OpenAI Codex 5-hour/7-day usage formatting and fetching
- Cached git dirty/ahead/behind counts and optional PR number
- Pi's regular footer remains active because registration is disabled

## Publishing notes

This extension also lives inside the broader [`pi-extensions`](../../README.md) collection, but it is set up to be publishable as its own npm package too.

## Notes

- The statusline registration is disabled in `index.ts`.
- When enabled, it uses background cached git/gh checks after project trust is granted.
- For `openai-codex`, the shared usage helper resolves Pi's active provider auth, derives the ChatGPT account id from that selected account's OAuth token, and fetches usage from ChatGPT's backend usage endpoint. The active default footer uses this helper even though this package's separate statusline registration remains disabled.
- Usage is cached briefly in memory and refreshed after turns.
