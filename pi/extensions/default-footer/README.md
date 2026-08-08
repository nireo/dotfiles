# default-footer

Replaces Pi's built-in footer with a local replica of the regular footer from
Pi 0.84.0. It keeps the usual directory/branch/session line, usage and
context statistics, model/thinking information, experimental marker,
and extension status line. The first line also shows the active OpenAI account
name (when an OpenAI Codex account is selected) alongside the working
directory, branch, Git markers (`!` conflicts, `+` staged, `~` unstaged,
`?` untracked, `↑`/`↓` ahead/behind), and optional PR number.

The implementation is intentionally local and explicit so new footer segments
can be added without modifying Pi itself. It also watches Pi's settings files
to keep the `(auto)` context-compaction marker in sync with `/settings`.

After editing, run `/reload` in Pi.
