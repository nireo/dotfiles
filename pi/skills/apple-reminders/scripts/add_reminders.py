#!/usr/bin/env python3
"""Safely add a batch of reminders to Apple Reminders on macOS.

The section path uses Accessibility UI automation because the Reminders
AppleScript dictionary does not expose sections.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import subprocess
import sys
import time
import uuid
from pathlib import Path
from typing import Any


DIRECT_SCRIPT = r'''
 on monthConstant(monthNumber)
   if monthNumber is 1 then return January
   if monthNumber is 2 then return February
   if monthNumber is 3 then return March
   if monthNumber is 4 then return April
   if monthNumber is 5 then return May
   if monthNumber is 6 then return June
   if monthNumber is 7 then return July
   if monthNumber is 8 then return August
   if monthNumber is 9 then return September
   if monthNumber is 10 then return October
   if monthNumber is 11 then return November
   if monthNumber is 12 then return December
   error "Invalid month"
 end monthConstant

 on accountForName(accountName)
   tell application "Reminders"
     if accountName is "" then return default account
     set accountMatches to every account whose name is accountName
     if (count of accountMatches) is 0 then error "No Reminders account named: " & accountName
     if (count of accountMatches) is greater than 1 then error "Multiple Reminders accounts named: " & accountName
     return item 1 of accountMatches
   end tell
 end accountForName

 on listForName(accountObject, listName)
   tell application "Reminders"
     set listMatches to every list of accountObject whose name is listName
     if (count of listMatches) is 0 then error "No Reminders list named: " & listName
     if (count of listMatches) is greater than 1 then error "Multiple Reminders lists named: " & listName
     return item 1 of listMatches
   end tell
 end listForName

 on setFields(theReminder, dueFlag, yearText, monthText, dayText, hourText, minuteText, secondText, allDayText, notesFlag, notesText, priorityFlag, priorityText, flaggedFlag, flaggedText)
   tell application "Reminders"
     if dueFlag is "1" then
       set dueDate to current date
       set year of dueDate to (yearText as integer)
       set month of dueDate to my monthConstant(monthText as integer)
       set day of dueDate to (dayText as integer)
       set time of dueDate to ((hourText as integer) * hours + (minuteText as integer) * minutes + (secondText as integer))
       if allDayText is "1" then
         set allday due date of theReminder to dueDate
       else
         set due date of theReminder to dueDate
       end if
     end if
     if notesFlag is "1" then set body of theReminder to notesText
     if priorityFlag is "1" then set priority of theReminder to (priorityText as integer)
     if flaggedFlag is "1" then set flagged of theReminder to (flaggedText is "1")
   end tell
 end setFields

 on run argv
   if (count of argv) is less than 19 then error "Internal error: incomplete reminder arguments"
   set operation to item 1 of argv
   set accountName to item 2 of argv
   set listName to item 3 of argv
   set lookupTitle to item 4 of argv
   set finalTitle to item 5 of argv
   set dueFlag to item 6 of argv
   set yearText to item 7 of argv
   set monthText to item 8 of argv
   set dayText to item 9 of argv
   set hourText to item 10 of argv
   set minuteText to item 11 of argv
   set secondText to item 12 of argv
   set allDayText to item 13 of argv
   set notesFlag to item 14 of argv
   set notesText to item 15 of argv
   set priorityFlag to item 16 of argv
   set priorityText to item 17 of argv
   set flaggedFlag to item 18 of argv
   set flaggedText to item 19 of argv

   tell application "Reminders"
     set accountObject to my accountForName(accountName)
     set listObject to my listForName(accountObject, listName)
     set matches to every reminder of listObject whose name is lookupTitle
     if operation is "update" then
       if (count of matches) is 0 then error "Cannot update missing reminder: " & lookupTitle
       if (count of matches) is greater than 1 then error "Cannot update ambiguous reminder: " & lookupTitle
       set theReminder to item 1 of matches
       set resultCode to "UPDATED"
     else if operation is "skip" and (count of matches) is greater than 0 then
       return "SKIPPED" & tab & (id of item 1 of matches)
     else if operation is "error" and (count of matches) is greater than 0 then
       error "Reminder already exists: " & lookupTitle
     else
       set theReminder to make new reminder at end of listObject with properties {name:finalTitle}
       set resultCode to "CREATED"
     end if
     if operation is "update" then set name of theReminder to finalTitle
   end tell

   my setFields(theReminder, dueFlag, yearText, monthText, dayText, hourText, minuteText, secondText, allDayText, notesFlag, notesText, priorityFlag, priorityText, flaggedFlag, flaggedText)

   tell application "Reminders" to return resultCode & tab & (id of theReminder)
 end run
'''

COUNT_SCRIPT = r'''
 on accountForName(accountName)
   tell application "Reminders"
     if accountName is "" then return default account
     set accountMatches to every account whose name is accountName
     if (count of accountMatches) is 0 then error "No Reminders account named: " & accountName
     if (count of accountMatches) is greater than 1 then error "Multiple Reminders accounts named: " & accountName
     return item 1 of accountMatches
   end tell
 end accountForName

 on listForName(accountObject, listName)
   tell application "Reminders"
     set listMatches to every list of accountObject whose name is listName
     if (count of listMatches) is 0 then error "No Reminders list named: " & listName
     if (count of listMatches) is greater than 1 then error "Multiple Reminders lists named: " & listName
     return item 1 of listMatches
   end tell
 end listForName

 on run argv
   if (count of argv) is less than 3 then error "Internal error: incomplete lookup arguments"
   set accountName to item 1 of argv
   set listName to item 2 of argv
   set reminderName to item 3 of argv
   tell application "Reminders"
     set accountObject to my accountForName(accountName)
     set listObject to my listForName(accountObject, listName)
     set matches to every reminder of listObject whose name is reminderName
     return (count of matches) as text
   end tell
 end run
'''

DESTINATION_SCRIPT = r'''
 on run argv
   if (count of argv) is less than 2 then error "Internal error: incomplete destination arguments"
   set accountName to item 1 of argv
   set listName to item 2 of argv
   tell application "Reminders"
     if accountName is "" then
       set accountObject to default account
     else
       set accountMatches to every account whose name is accountName
       if (count of accountMatches) is 0 then error "No Reminders account named: " & accountName
       if (count of accountMatches) is greater than 1 then error "Multiple Reminders accounts named: " & accountName
       set accountObject to item 1 of accountMatches
     end if
     set listMatches to every list of accountObject whose name is listName
     if (count of listMatches) is 0 then error "No Reminders list named: " & listName
     if (count of listMatches) is greater than 1 then error "Multiple Reminders lists named: " & listName
     return id of item 1 of listMatches
   end tell
 end run
'''

SECTION_CREATE_SCRIPT = r'''
 on sectionOutline(theWindow)
   tell application "System Events"
     tell process "Reminders"
       set splitObject to first UI element of theWindow
       set layoutObject to missing value
       repeat with i from 1 to count of UI elements of splitObject
         set candidate to UI element i of splitObject
         if (role of candidate as text) is "AXLayoutArea" then
           set layoutObject to candidate
           exit repeat
         end if
       end repeat
       if layoutObject is missing value then error "Reminders list area not found"
       set scrollObject to first UI element of layoutObject
       set outlineObject to first UI element of scrollObject
       if (role of outlineObject as text) is not "AXOutline" then error "Reminders outline not found"
       return outlineObject
     end tell
   end tell
 end sectionOutline

 on run argv
   if (count of argv) is less than 4 then error "Internal error: incomplete section arguments"
   set accountName to item 1 of argv
   set listName to item 2 of argv
   set sectionName to item 3 of argv
   set temporaryTitle to item 4 of argv

   tell application "Reminders"
     if accountName is "" then
       set accountObject to default account
     else
       set accountMatches to every account whose name is accountName
       if (count of accountMatches) is 0 then error "No Reminders account named: " & accountName
       if (count of accountMatches) is greater than 1 then error "Multiple Reminders accounts named: " & accountName
       set accountObject to item 1 of accountMatches
     end if
     set listMatches to every list of accountObject whose name is listName
     if (count of listMatches) is 0 then error "No Reminders list named: " & listName
     if (count of listMatches) is greater than 1 then error "Multiple Reminders lists named: " & listName
     set listObject to item 1 of listMatches
     activate
     show listObject
   end tell

   tell application "System Events"
     tell process "Reminders"
       set frontmost to true
     end tell
   end tell
   delay 0.5

   set targetRow to missing value
   repeat with attemptNumber from 1 to 100
     try
       tell application "System Events"
         tell process "Reminders"
           if (count of windows) is 0 then error "Reminders has no accessible window; open or unminimize Reminders and keep the display awake"
           set theWindow to front window
           set outlineObject to my sectionOutline(theWindow)
           repeat with rowNumber from 1 to count of rows of outlineObject
             set theRow to row rowNumber of outlineObject
             set theCell to first UI element of theRow
             set cellDescription to description of theCell as text
             if cellDescription is ("New reminder in " & sectionName) then
               set targetRow to theRow
               exit repeat
             end if
             if cellDescription is "cell" then
               try
                 repeat with childNumber from 1 to count of UI elements of theCell
                   set childElement to UI element childNumber of theCell
                   if (role of childElement as text) is "AXTextField" then
                     if (value of childElement as text) is sectionName then
                       repeat with buttonNumber from 1 to count of UI elements of theCell
                         set possibleButton to UI element buttonNumber of theCell
                         if (role of possibleButton as text) is "AXButton" then
                           try
                             if (description of possibleButton as text) contains "Show" then perform action "AXPress" of possibleButton
                           end try
                         end if
                       end repeat
                     end if
                   end if
                 end repeat
               end try
             end if
             if targetRow is not missing value then exit repeat
           end repeat
         end tell
       end tell
       if targetRow is not missing value then exit repeat
     on error errorMessage number errorNumber
       if attemptNumber is 100 then error errorMessage number errorNumber
     end try
     delay 0.2
   end repeat

   if targetRow is missing value then error "Section not found or not visible: " & sectionName

   tell application "System Events"
     tell process "Reminders"
       set targetButton to first UI element of first UI element of targetRow
       set titleField to UI element 2 of targetButton
       set value of titleField to temporaryTitle
       set focused of titleField to true
       delay 0.15
       try
         perform action "AXConfirm" of titleField
       on error
         key code 36
       end try
     end tell
   end tell
   delay 0.8
   return "CREATED"
 end run
'''

DELETE_EXACT_SCRIPT = r'''
 on accountForName(accountName)
   tell application "Reminders"
     if accountName is "" then return default account
     set accountMatches to every account whose name is accountName
     if (count of accountMatches) is 0 then error "No Reminders account named: " & accountName
     return item 1 of accountMatches
   end tell
 end accountForName

 on listForName(accountObject, listName)
   tell application "Reminders"
     set listMatches to every list of accountObject whose name is listName
     if (count of listMatches) is 0 then error "No Reminders list named: " & listName
     return item 1 of listMatches
   end tell
 end listForName

 on run argv
   if (count of argv) is less than 3 then error "Internal error: incomplete cleanup arguments"
   tell application "Reminders"
     set listObject to my listForName(my accountForName(item 1 of argv), item 2 of argv)
     set matches to every reminder of listObject whose name is (item 3 of argv)
     repeat with theReminder in matches
       delete theReminder
     end repeat
     return (count of matches) as text
   end tell
 end run
'''

FINALIZE_SECTION_SCRIPT = r'''
 on monthConstant(monthNumber)
   if monthNumber is 1 then return January
   if monthNumber is 2 then return February
   if monthNumber is 3 then return March
   if monthNumber is 4 then return April
   if monthNumber is 5 then return May
   if monthNumber is 6 then return June
   if monthNumber is 7 then return July
   if monthNumber is 8 then return August
   if monthNumber is 9 then return September
   if monthNumber is 10 then return October
   if monthNumber is 11 then return November
   if monthNumber is 12 then return December
   error "Invalid month"
 end monthConstant

 on accountForName(accountName)
   tell application "Reminders"
     if accountName is "" then return default account
     set accountMatches to every account whose name is accountName
     if (count of accountMatches) is 0 then error "No Reminders account named: " & accountName
     if (count of accountMatches) is greater than 1 then error "Multiple Reminders accounts named: " & accountName
     return item 1 of accountMatches
   end tell
 end accountForName

 on listForName(accountObject, listName)
   tell application "Reminders"
     set listMatches to every list of accountObject whose name is listName
     if (count of listMatches) is 0 then error "No Reminders list named: " & listName
     if (count of listMatches) is greater than 1 then error "Multiple Reminders lists named: " & listName
     return item 1 of listMatches
   end tell
 end listForName

 on run argv
   if (count of argv) is less than 18 then error "Internal error: incomplete finalization arguments"
   set accountName to item 1 of argv
   set listName to item 2 of argv
   set temporaryTitle to item 3 of argv
   set finalTitle to item 4 of argv
   set dueFlag to item 5 of argv
   set yearText to item 6 of argv
   set monthText to item 7 of argv
   set dayText to item 8 of argv
   set hourText to item 9 of argv
   set minuteText to item 10 of argv
   set secondText to item 11 of argv
   set allDayText to item 12 of argv
   set notesFlag to item 13 of argv
   set notesText to item 14 of argv
   set priorityFlag to item 15 of argv
   set priorityText to item 16 of argv
   set flaggedFlag to item 17 of argv
   set flaggedText to item 18 of argv

   tell application "Reminders"
     set accountObject to my accountForName(accountName)
     set listObject to my listForName(accountObject, listName)
     set matches to every reminder of listObject whose name is temporaryTitle
     if (count of matches) is 0 then error "Temporary reminder was not created: " & temporaryTitle
     if (count of matches) is greater than 1 then error "Temporary reminder is ambiguous: " & temporaryTitle
     set theReminder to item 1 of matches
     if dueFlag is "1" then
       set dueDate to current date
       set year of dueDate to (yearText as integer)
       set month of dueDate to my monthConstant(monthText as integer)
       set day of dueDate to (dayText as integer)
       set time of dueDate to ((hourText as integer) * hours + (minuteText as integer) * minutes + (secondText as integer))
       if allDayText is "1" then
         set allday due date of theReminder to dueDate
       else
         set due date of theReminder to dueDate
       end if
     end if
     if notesFlag is "1" then set body of theReminder to notesText
     if priorityFlag is "1" then set priority of theReminder to (priorityText as integer)
     if flaggedFlag is "1" then set flagged of theReminder to (flaggedText is "1")
     set name of theReminder to finalTitle
     return "CREATED" & tab & (id of theReminder)
   end tell
 end run
'''


class UserInputError(ValueError):
    pass


def run_osascript(script: str, *args: str) -> str:
    """Run AppleScript through stdin, preserving Unicode arguments."""
    try:
        completed = subprocess.run(
            ["osascript", "-", *[str(arg) for arg in args]],
            input=script,
            text=True,
            capture_output=True,
            check=False,
        )
    except OSError as exc:
        raise RuntimeError(f"Could not run osascript: {exc}") from exc
    if completed.returncode != 0:
        detail = (completed.stderr or completed.stdout).strip()
        raise RuntimeError(detail or f"osascript exited with {completed.returncode}")
    return completed.stdout.strip()


def read_input(path: str) -> Any:
    if path == "-":
        raw = sys.stdin.read()
    else:
        raw = Path(path).read_text(encoding="utf-8")
    try:
        return json.loads(raw)
    except json.JSONDecodeError as exc:
        raise UserInputError(f"Input is not valid JSON: {exc}") from exc


def parse_due(value: Any, all_day_override: Any) -> tuple[bool, tuple[int, int, int, int, int, int] | None]:
    if value is None:
        if all_day_override is not None:
            raise UserInputError("all_day requires a due value")
        return False, None
    if not isinstance(value, str) or not value.strip():
        raise UserInputError("due must be a nonempty ISO date or datetime string")
    raw = value.strip()
    date_only = bool(re.fullmatch(r"\d{4}-\d{2}-\d{2}", raw))
    try:
        if date_only:
            parsed = dt.datetime.strptime(raw, "%Y-%m-%d")
        else:
            normalized = raw.replace("Z", "+00:00")
            parsed = dt.datetime.fromisoformat(normalized)
    except ValueError as exc:
        raise UserInputError(
            f"Unsupported due value {value!r}; use YYYY-MM-DD or YYYY-MM-DDTHH:MM[:SS]"
        ) from exc

    if parsed.tzinfo is not None:
        parsed = parsed.astimezone().replace(tzinfo=None)
    all_day = date_only if all_day_override is None else all_day_override
    if not isinstance(all_day, bool):
        raise UserInputError("all_day must be boolean")
    return all_day, (parsed.year, parsed.month, parsed.day, parsed.hour, parsed.minute, parsed.second)


def normalize_records(data: Any) -> list[dict[str, Any]]:
    if isinstance(data, dict):
        data = data.get("reminders")
    if not isinstance(data, list):
        raise UserInputError("Input must be an array or an object with a 'reminders' array")

    normalized: list[dict[str, Any]] = []
    seen: set[str] = set()
    for index, raw in enumerate(data, start=1):
        if not isinstance(raw, dict):
            raise UserInputError(f"Reminder {index} must be an object")
        title = raw.get("title")
        if not isinstance(title, str) or not title.strip():
            raise UserInputError(f"Reminder {index} needs a nonempty title")
        if "\n" in title or "\r" in title:
            raise UserInputError(f"Reminder {index} title cannot contain a newline")
        if title in seen:
            raise UserInputError(f"Duplicate title in input batch: {title!r}")
        seen.add(title)

        all_day, due_parts = parse_due(raw.get("due"), raw.get("all_day"))
        notes = raw.get("notes")
        if notes is not None and not isinstance(notes, str):
            raise UserInputError(f"Reminder {index} notes must be text")
        priority = raw.get("priority")
        if priority is not None:
            if isinstance(priority, bool) or not isinstance(priority, int) or not 0 <= priority <= 9:
                raise UserInputError(f"Reminder {index} priority must be an integer from 0 to 9")
        flagged = raw.get("flagged")
        if flagged is not None and not isinstance(flagged, bool):
            raise UserInputError(f"Reminder {index} flagged must be boolean")

        normalized.append(
            {
                "title": title,
                "due": raw.get("due"),
                "all_day": all_day,
                "due_parts": due_parts,
                "notes": notes,
                "priority": priority,
                "flagged": flagged,
            }
        )
    return normalized


def apple_args(record: dict[str, Any], lookup_title: str, final_title: str) -> list[str]:
    due_parts = record["due_parts"]
    if due_parts is None:
        due_values = ("0", "0", "0", "0", "0", "0", "0")
    else:
        year, month, day, hour, minute, second = due_parts
        due_values = ("1", str(year), str(month), str(day), str(hour), str(minute), str(second))
    all_day_value = "1" if record["all_day"] else "0"
    notes = record["notes"]
    priority = record["priority"]
    flagged = record["flagged"]
    return [
        lookup_title,
        final_title,
        *due_values,
        all_day_value,
        "1" if notes is not None else "0",
        notes or "",
        "1" if priority is not None else "0",
        str(priority if priority is not None else 0),
        "1" if flagged is not None else "0",
        "1" if flagged else "0",
    ]


def count_existing(account: str, list_name: str, title: str) -> int:
    result = run_osascript(COUNT_SCRIPT, account, list_name, title)
    try:
        return int(result)
    except ValueError as exc:
        raise RuntimeError(f"Unexpected lookup response for {title!r}: {result!r}") from exc


def parse_result(result: str, fallback_status: str) -> dict[str, str]:
    parts = result.split("\t", 1)
    return {"status": parts[0] if parts and parts[0] else fallback_status, "id": parts[1] if len(parts) == 2 else ""}


def finalize_section(
    record: dict[str, Any],
    *,
    account: str,
    list_name: str,
    temporary_title: str,
    final_title: str,
) -> dict[str, str]:
    args = [
        account,
        list_name,
        temporary_title,
        final_title,
        *apple_args(record, temporary_title, final_title)[2:],
    ]
    last_error: RuntimeError | None = None
    for _ in range(12):
        try:
            return parse_result(run_osascript(FINALIZE_SECTION_SCRIPT, *args), "CREATED")
        except RuntimeError as exc:
            # UI edits can reach the Reminders scripting interface slightly later.
            if "Temporary reminder was not created" not in str(exc):
                raise
            last_error = exc
            time.sleep(0.5)
    assert last_error is not None
    raise last_error


def add_one(
    record: dict[str, Any],
    *,
    account: str,
    list_name: str,
    section: str | None,
    duplicate_mode: str,
) -> dict[str, Any]:
    title = record["title"]
    existing_count = count_existing(account, list_name, title)
    if duplicate_mode == "skip" and existing_count:
        return {"title": title, "status": "skipped", "reason": "already exists", "count": existing_count}
    if duplicate_mode == "error" and existing_count:
        raise RuntimeError(f"Reminder already exists: {title}")
    if duplicate_mode == "update":
        if existing_count == 0:
            raise RuntimeError(f"Cannot update missing reminder: {title}")
        if existing_count > 1:
            raise RuntimeError(f"Cannot update ambiguous reminder ({existing_count} matches): {title}")
        args = ["update", account, list_name, *apple_args(record, title, title)]
        parsed = parse_result(run_osascript(DIRECT_SCRIPT, *args), "UPDATED")
        return {"title": title, "status": parsed["status"].lower(), "id": parsed["id"]}

    if section is None:
        args = ["create", account, list_name, *apple_args(record, title, title)]
        parsed = parse_result(run_osascript(DIRECT_SCRIPT, *args), "CREATED")
        return {"title": title, "status": parsed["status"].lower(), "id": parsed["id"]}

    temporary_title = f"__pi_reminder_{uuid.uuid4().hex}__"
    try:
        run_osascript(SECTION_CREATE_SCRIPT, account, list_name, section, temporary_title)
        parsed = finalize_section(
            record,
            account=account,
            list_name=list_name,
            temporary_title=temporary_title,
            final_title=title,
        )
        return {"title": title, "status": parsed["status"].lower(), "id": parsed["id"], "section": section}
    except Exception:
        # Best-effort cleanup of our own temporary item. Do not mask the original error.
        try:
            run_osascript(DELETE_EXACT_SCRIPT, account, list_name, temporary_title)
        except Exception:
            pass
        raise


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Add a JSON batch to Apple Reminders")
    parser.add_argument("--list", required=True, dest="list_name", help="Target Reminders list")
    parser.add_argument("--account", default="", help="Reminders account; default account when omitted")
    parser.add_argument("--section", help="Target section inside the list (uses Accessibility UI)")
    parser.add_argument("--input", default="-", help="JSON file, or - for stdin")
    parser.add_argument(
        "--duplicate",
        choices=("skip", "error", "create", "update"),
        default="skip",
        help="How to handle an existing exact-title reminder (default: skip)",
    )
    parser.add_argument("--dry-run", action="store_true", help="Validate and print the plan without changing Reminders")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        records = normalize_records(read_input(args.input))
        # This also validates that the destination list/account exists before any write.
        if records:
            run_osascript(DESTINATION_SCRIPT, args.account, args.list_name)
        if args.dry_run:
            plan = []
            for record in records:
                existing_count = count_existing(args.account, args.list_name, record["title"])
                if args.duplicate == "skip":
                    action = "skip" if existing_count else "create"
                elif args.duplicate == "error":
                    action = "error" if existing_count else "create"
                elif args.duplicate == "update":
                    action = "update" if existing_count == 1 else "error"
                else:
                    action = "create"
                plan.append(
                    {
                        "title": record["title"],
                        "due": record["due"],
                        "all_day": record["all_day"] if record["due"] is not None else None,
                        "list": args.list_name,
                        "account": args.account or "default account",
                        "section": args.section,
                        "existing_count": existing_count,
                        "action": action,
                    }
                )
            print(json.dumps({"dry_run": True, "planned": plan}, ensure_ascii=False, indent=2))
            return 0

        # Preflight all duplicates for error/update modes so a batch fails before partial writes.
        if args.duplicate in ("error", "update"):
            for record in records:
                count = count_existing(args.account, args.list_name, record["title"])
                if args.duplicate == "error" and count:
                    raise RuntimeError(f"Reminder already exists: {record['title']}")
                if args.duplicate == "update" and count != 1:
                    state = "missing" if count == 0 else f"ambiguous ({count} matches)"
                    raise RuntimeError(f"Cannot update {state} reminder: {record['title']}")

        results = []
        for record in records:
            results.append(
                add_one(
                    record,
                    account=args.account,
                    list_name=args.list_name,
                    section=args.section,
                    duplicate_mode=args.duplicate,
                )
            )
        print(json.dumps({"created": sum(r["status"] == "created" for r in results), "results": results}, ensure_ascii=False, indent=2))
        return 0
    except (UserInputError, RuntimeError, OSError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
