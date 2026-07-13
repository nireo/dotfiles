# discuss

A small keyboard-first diff discussion extension for Pi. It uses `@pierre/diffs` to build the diff model, lets you attach precise `FIX` or `DISCUSS` annotations, and sends the resulting feedback straight to the active agent.

## Use

Run `/reload` in Pi, then use `/discuss`.

`discuss` reviews the current working tree against `HEAD`, including staged and unstaged changes and untracked text files. Binary files and files larger than 750 KB are skipped.

## Keys

- `Tab`, `←`, `→` — switch between files and diff panes
- `j`/`k` or `↑`/`↓` — move through files or diff lines
- `]`/`[` — next/previous file
- `n`/`p` — next/previous changed hunk
- `f` / `d` — annotate the selected line as a **FIX** / **DISCUSS** item
- `F` / `D` — add a file-level FIX / DISCUSS item
- `e` / `x` — edit / delete the selected line annotation
- `E` / `X` — edit / delete the current file annotation
- `s` — send all annotations to the agent
- `Esc` — cancel (or cancel the annotation editor)

While editing an annotation, `Tab` switches its intent, `Enter` saves it, and `Shift+Enter` adds a line.

`FIX` items ask the agent to make the requested change. `DISCUSS` items request a prose answer and explicitly tell the agent not to change code merely to answer the discussion point.
