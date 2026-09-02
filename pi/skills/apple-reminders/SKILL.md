---
name: apple-reminders
description: Create, inspect, and safely update Apple Reminders on macOS, including bulk schedules, due dates and times, lists, and sections. Use whenever a user asks to add, organize, find, or modify reminders in Apple Reminders.
compatibility: macOS with the Reminders app, Automation permission for Reminders, Accessibility permission for pi/Terminal when targeting a section, and Python 3 for the bundled helper.
---

# Apple Reminders

Use this skill for changes to the user's macOS/iCloud Reminders collection. Mutations require explicit user intent; do not alter unrelated reminders.

## Preferred workflow

1. **Normalize the request before writing.** Produce one record per reminder:
   ```json
   {
     "title": "Submit assignment",
     "due": "2026-09-08T14:15",
     "notes": "Optional details",
     "priority": 0,
     "flagged": false
   }
   ```
   `due` is local time. Use `YYYY-MM-DD` for an all-day deadline and `YYYY-MM-DDTHH:MM` (or seconds) for a timed deadline. A date without a year is only safe to infer when the intended year is unambiguous; otherwise ask.

2. **Resolve the destination.** Apple Reminders has lists and, inside lists, sections. A section is not a list. If the user names a section but not its list, inspect the open Reminders UI and use it only when the parent list is unambiguous; otherwise ask. Never silently fall back to another list or to the default list.

3. **Resolve wording that affects dates.** Keep requested titles exactly, including numbering and capitalization. If the user says a task is due “before 14:15,” normally encode the deadline as `14:15` on that date; ask if “before” means an earlier reminder time rather than the deadline time. Do not turn a release date into a separate reminder unless requested.

4. **Preview and create batches with the helper.** From this skill directory, prepare a JSON file and run:
   ```sh
   python3 scripts/add_reminders.py \
     --list "List name" \
     --section "Section name" \
     --input /path/to/reminders.json \
     --dry-run
   python3 scripts/add_reminders.py \
     --list "List name" \
     --section "Section name" \
     --input /path/to/reminders.json
   ```
   Omit `--section` for a normal list. `--account` selects an account; otherwise the account's default is used. The helper defaults to `--duplicate skip`, so rerunning an identical batch does not create exact-title duplicates. Use `--duplicate error` when a duplicate should stop the batch, `create` only when duplicate titles are intentional, or `update` when the user explicitly wants existing reminders changed.

5. **Verify the result.** Treat a nonzero helper exit as failure. Inspect the JSON summary, then query AppleScript or the Reminders UI to confirm every requested title has the intended list, section (if applicable), due date/time, and count. Report skipped duplicates rather than claiming they were newly created.

## Why the helper has two paths

Apple's Reminders scripting dictionary exposes lists and reminder metadata but not sections. Therefore:

- without `--section`, the helper creates and configures reminders through the Reminders AppleScript interface;
- with `--section`, it first creates a unique temporary title through Reminders' Accessibility UI in the exact section, then assigns the final title and metadata through AppleScript. It refuses to fall back to the list root if the section cannot be found.

The first section operation may trigger macOS permission prompts. Grant Automation access to Reminders and Accessibility access to the program running pi (often Terminal, kitty, or the pi executable). Section UI automation also needs a visible Reminders window on an awake display. If access is denied or no window is available, stop and tell the user what is missing; do not add the reminders somewhere else.

## Structured input

The input may be an array or `{ "reminders": [...] }`. Each record requires a nonempty `title`; supported optional fields are:

- `due`: local ISO date or datetime;
- `all_day`: boolean override (date-only values default to true);
- `notes`: text for the notes/body field;
- `priority`: integer `0`–`9` (Apple's scale: `1`–`4` high, `5` medium, `6`–`9` low);
- `flagged`: boolean.

Example:

```json
[
  {"title": "Pay rent", "due": "2026-10-01"},
  {"title": "Call dentist", "due": "2026-10-02T09:30", "priority": 1},
  {"title": "Read paper", "notes": "Start with section 3", "flagged": true}
]
```

For destructive actions such as deleting reminders, do not improvise a deletion script: identify exact reminder IDs/titles, show the user the target, and obtain confirmation immediately before deleting. For edits, preserve omitted fields and verify that a title identifies exactly one reminder.
