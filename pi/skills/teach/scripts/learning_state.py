#!/usr/bin/env python3
"""Safe, dependency-free storage helper for the teach skill."""

from __future__ import annotations

import argparse
import contextlib
import json
import os
import re
import sys
import tempfile
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterator

try:
    import fcntl
except ImportError:  # pragma: no cover - Pi currently runs on Unix-like systems.
    fcntl = None

SCHEMA_VERSION = 1
DEFAULT_ROOT = Path(os.environ.get("PI_LEARNER_STATE_DIR", "~/.pi/agent/learner-state")).expanduser()
ID_RE = re.compile(r"^[a-z0-9][a-z0-9._:-]*$")
PROFILE_KEY_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_-]*$")
STATUSES = ("active", "paused", "completed")
PHASES = ("probe", "plan", "teach", "paused", "completed")
CONCEPT_STATUSES = ("unassessed", "familiar", "developing", "demonstrated")
KINDS = (
    "self_report",
    "recognition",
    "explanation",
    "derivation",
    "application",
    "transfer",
    "delayed_retrieval",
)
OUTCOMES = ("pass", "partial", "fail", "ungraded")
REASONING_QUALITIES = ("none", "weak", "sound", "not_applicable")
VOLATILITIES = ("stable", "changing")
GENERATIVE_KINDS = {"explanation", "derivation", "application", "transfer", "delayed_retrieval"}
STATUS_RANK = {status: rank for rank, status in enumerate(CONCEPT_STATUSES)}
MAX_TEXT = 4000
TRANSACTION_FILE = ".pending-transaction.json"


class StateError(RuntimeError):
    pass


def now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def strict_json_loads(content: str, *, source: str) -> Any:
    def reject_constant(value: str) -> None:
        raise ValueError(f"non-finite number {value!r} is not valid JSON")

    try:
        return json.loads(content, parse_constant=reject_constant)
    except (json.JSONDecodeError, ValueError) as exc:
        if isinstance(exc, json.JSONDecodeError):
            detail = f"line {exc.lineno}, column {exc.colno}: {exc.msg}"
        else:
            detail = str(exc)
        raise StateError(f"Invalid JSON in {source}: {detail}") from exc


def json_text(data: Any) -> str:
    try:
        return json.dumps(data, indent=2, ensure_ascii=False, sort_keys=True, allow_nan=False) + "\n"
    except (TypeError, ValueError) as exc:
        raise StateError(f"Cannot serialize state as strict JSON: {exc}") from exc


def emit(data: Any) -> None:
    print(json_text(data), end="")


def require_id(value: str, label: str = "ID") -> str:
    if not isinstance(value, str) or not ID_RE.fullmatch(value):
        raise StateError(
            f"Invalid {label} {value!r}; use lowercase letters, numbers, '.', '_', ':', or '-' and do not use paths"
        )
    return value


def require_text(value: str, label: str, *, allow_empty: bool = False) -> str:
    value = value.strip()
    if not allow_empty and not value:
        raise StateError(f"{label} must not be empty")
    if len(value) > MAX_TEXT:
        raise StateError(f"{label} exceeds {MAX_TEXT} characters")
    return value


def profile_path(root: Path) -> Path:
    return root / "profile.json"


def concepts_path(root: Path) -> Path:
    return root / "concepts.json"


def lesson_dir(root: Path, lesson_id: str) -> Path:
    return root / "lessons" / require_id(lesson_id, "lesson ID")


def assert_safe_lesson_dir(root: Path, lesson_id: str) -> Path:
    directory = lesson_dir(root, lesson_id)
    lessons_root = root / "lessons"
    if lessons_root.is_symlink() or directory.is_symlink():
        raise StateError(f"Refusing symlinked learner-state lesson path: {directory}")
    return directory


def lesson_path(root: Path, lesson_id: str) -> Path:
    return lesson_dir(root, lesson_id) / "state.json"


def plan_path(root: Path, lesson_id: str) -> Path:
    return lesson_dir(root, lesson_id) / "plan.md"


def card_source_json_path(root: Path, lesson_id: str) -> Path:
    return lesson_dir(root, lesson_id) / "card-source.json"


def card_source_markdown_path(root: Path, lesson_id: str) -> Path:
    return lesson_dir(root, lesson_id) / "card-source.md"


def empty_profile() -> dict[str, Any]:
    timestamp = now()
    return {
        "schemaVersion": SCHEMA_VERSION,
        "preferences": {},
        "observations": [],
        "createdAt": timestamp,
        "updatedAt": timestamp,
    }


def empty_concepts() -> dict[str, Any]:
    return {"schemaVersion": SCHEMA_VERSION, "concepts": {}, "updatedAt": now()}


def load_json(path: Path) -> dict[str, Any]:
    try:
        content = path.read_text(encoding="utf-8")
    except FileNotFoundError as exc:
        raise StateError(f"Missing state file: {path}") from exc
    except OSError as exc:
        raise StateError(f"Cannot read state file {path}: {exc}") from exc
    value = strict_json_loads(content, source=str(path))
    if not isinstance(value, dict):
        raise StateError(f"Expected a JSON object in {path}")
    return value


def fsync_directory(path: Path) -> None:
    try:
        descriptor = os.open(path, os.O_RDONLY)
    except OSError:
        return
    try:
        os.fsync(descriptor)
    finally:
        os.close(descriptor)


def atomic_write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    temporary_path = Path(temporary)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary_path, path)
        fsync_directory(path.parent)
    finally:
        temporary_path.unlink(missing_ok=True)


def atomic_write_json(path: Path, value: dict[str, Any]) -> None:
    atomic_write_text(path, json_text(value))


def transaction_path(root: Path) -> Path:
    return root / TRANSACTION_FILE


def validate_transaction_target(root: Path, relative: str) -> Path:
    relative_path = Path(relative)
    if relative_path.is_absolute() or ".." in relative_path.parts:
        raise StateError(f"Unsafe transaction target: {relative!r}")
    allowed = relative in {"profile.json", "concepts.json"}
    if len(relative_path.parts) == 3 and relative_path.parts[0] == "lessons":
        lesson_id, filename = relative_path.parts[1:]
        require_id(lesson_id, "lesson ID")
        allowed = filename in {"state.json", "plan.md", "card-source.json", "card-source.md"}
        assert_safe_lesson_dir(root, lesson_id)
    if not allowed:
        raise StateError(f"Unsupported transaction target: {relative!r}")
    return root / relative_path


def recover_transaction(root: Path) -> None:
    journal = transaction_path(root)
    if not journal.exists():
        return
    if journal.is_symlink():
        raise StateError(f"Refusing symlinked transaction journal: {journal}")
    data = load_json(journal)
    writes = data.get("writes")
    if data.get("schemaVersion") != SCHEMA_VERSION or not isinstance(writes, list) or not writes:
        raise StateError(f"Invalid pending transaction journal: {journal}")
    prepared: list[tuple[Path, str]] = []
    for item in writes:
        if not isinstance(item, dict) or not isinstance(item.get("path"), str) or not isinstance(item.get("content"), str):
            raise StateError(f"Invalid pending transaction entry in {journal}")
        prepared.append((validate_transaction_target(root, item["path"]), item["content"]))
    for path, content in prepared:
        atomic_write_text(path, content)
    journal.unlink()
    fsync_directory(root)


def transactional_write(root: Path, writes: dict[Path, str]) -> None:
    if not writes:
        return
    entries = []
    for path, content in writes.items():
        try:
            relative = path.relative_to(root).as_posix()
        except ValueError as exc:
            raise StateError(f"Transaction target escapes learner-state root: {path}") from exc
        validate_transaction_target(root, relative)
        entries.append({"path": relative, "content": content})
    atomic_write_json(transaction_path(root), {"schemaVersion": SCHEMA_VERSION, "writes": entries})
    recover_transaction(root)


@contextlib.contextmanager
def state_lock(root: Path) -> Iterator[None]:
    root.mkdir(parents=True, exist_ok=True)
    lock_path = root / ".lock"
    with lock_path.open("a+", encoding="utf-8") as handle:
        if fcntl is not None:
            fcntl.flock(handle.fileno(), fcntl.LOCK_EX)
        try:
            yield
        finally:
            if fcntl is not None:
                fcntl.flock(handle.fileno(), fcntl.LOCK_UN)


def initialize(root: Path) -> None:
    with state_lock(root):
        recover_transaction(root)
        existing_errors: list[str] = []
        if profile_path(root).exists():
            try:
                existing_errors.extend(validate_profile(load_json(profile_path(root)), profile_path(root)))
            except StateError as exc:
                existing_errors.append(str(exc))
        if concepts_path(root).exists():
            try:
                existing = load_json(concepts_path(root))
                existing_errors.extend(validate_concept_store(existing, concepts_path(root)))
            except StateError as exc:
                existing_errors.append(str(exc))
        if existing_errors:
            raise StateError("Initialization found invalid existing state:\n- " + "\n- ".join(existing_errors))
        lessons_root = root / "lessons"
        if lessons_root.is_symlink():
            raise StateError(f"Refusing symlinked learner-state lessons directory: {lessons_root}")
        core_complete = profile_path(root).exists() and concepts_path(root).exists()
        has_lesson_state = lessons_root.exists() and any(
            child.is_dir() and not child.is_symlink() and (child / "state.json").exists()
            for child in lessons_root.iterdir()
        )
        if has_lesson_state and not core_complete:
            raise StateError("Existing lesson state is present but profile.json or concepts.json is missing")
        if core_complete:
            existing_errors = validate_store(root)
            if existing_errors:
                raise StateError("Initialization found invalid existing state:\n- " + "\n- ".join(existing_errors))
        lessons_root.mkdir(exist_ok=True)
        writes: dict[Path, str] = {}
        if not profile_path(root).exists():
            writes[profile_path(root)] = json_text(empty_profile())
        if not concepts_path(root).exists():
            writes[concepts_path(root)] = json_text(empty_concepts())
        transactional_write(root, writes)
        errors = validate_store(root)
        if errors:
            raise StateError("Initialization found invalid existing state:\n- " + "\n- ".join(errors))


def require_initialized(root: Path) -> None:
    if not profile_path(root).is_file() or not concepts_path(root).is_file():
        raise StateError(f"Learner state is not initialized at {root}; run the init command first")


def valid_timestamp(value: Any) -> bool:
    if not isinstance(value, str):
        return False
    try:
        datetime.fromisoformat(value.replace("Z", "+00:00"))
        return True
    except ValueError:
        return False


def validate_profile(value: dict[str, Any], path: Path) -> list[str]:
    errors: list[str] = []
    if value.get("schemaVersion") != SCHEMA_VERSION:
        errors.append(f"{path}: unsupported schemaVersion")
    if not isinstance(value.get("preferences"), dict):
        errors.append(f"{path}: preferences must be an object")
    observations = value.get("observations")
    if not isinstance(observations, list) or not all(isinstance(item, str) for item in observations):
        errors.append(f"{path}: observations must be an array of strings")
    for field in ("createdAt", "updatedAt"):
        if not valid_timestamp(value.get(field)):
            errors.append(f"{path}: {field} must be an ISO timestamp")
    return errors


def validate_evidence(value: Any, prefix: str) -> list[str]:
    if not isinstance(value, dict):
        return [f"{prefix} must be an object"]
    errors: list[str] = []
    if not isinstance(value.get("id"), str) or not re.fullmatch(r"ev-[0-9a-f]{12}", value["id"]):
        errors.append(f"{prefix}: invalid evidence id")
    if not valid_timestamp(value.get("timestamp")):
        errors.append(f"{prefix}: timestamp must be an ISO timestamp")
    try:
        require_id(value.get("lessonId"), "lesson ID")
    except StateError as exc:
        errors.append(f"{prefix}: {exc}")
    if value.get("kind") not in KINDS:
        errors.append(f"{prefix}: invalid kind")
    if value.get("outcome") not in OUTCOMES:
        errors.append(f"{prefix}: invalid outcome")
    if value.get("reasoningQuality") not in REASONING_QUALITIES:
        errors.append(f"{prefix}: invalid reasoningQuality")
    if not isinstance(value.get("summary"), str) or not value["summary"].strip() or len(value["summary"]) > MAX_TEXT:
        errors.append(f"{prefix}: summary must be a non-empty string of at most {MAX_TEXT} characters")
    if value.get("misconception") is not None and not isinstance(value.get("misconception"), str):
        errors.append(f"{prefix}: misconception must be null or a string")
    return errors


def validate_concept_record(concept_id: str, value: Any, path: Path) -> list[str]:
    errors: list[str] = []
    prefix = f"{path}: concept {concept_id!r}"
    try:
        require_id(concept_id, "concept ID")
    except StateError as exc:
        errors.append(f"{prefix}: {exc}")
    if not isinstance(value, dict):
        return [f"{prefix} must be an object"]
    if value.get("id") != concept_id:
        errors.append(f"{prefix}: embedded id must match its key")
    for field in ("label", "scope"):
        if not isinstance(value.get(field), str) or not value[field].strip() or len(value[field]) > MAX_TEXT:
            errors.append(f"{prefix}: {field} must be a non-empty string of at most {MAX_TEXT} characters")
    if value.get("status") not in CONCEPT_STATUSES:
        errors.append(f"{prefix}: invalid status")
    prerequisites = value.get("prerequisites")
    if not isinstance(prerequisites, list):
        errors.append(f"{prefix}: prerequisites must be an array")
    else:
        for prerequisite in prerequisites:
            try:
                require_id(prerequisite, "prerequisite ID")
            except StateError as exc:
                errors.append(f"{prefix}: {exc}")
    misconceptions = value.get("misconceptions")
    if not isinstance(misconceptions, list) or not all(isinstance(item, str) for item in misconceptions):
        errors.append(f"{prefix}: misconceptions must be an array of strings")
    evidence = value.get("evidence")
    if not isinstance(evidence, list):
        errors.append(f"{prefix}: evidence must be an array")
    else:
        seen_evidence: set[str] = set()
        for index, item in enumerate(evidence):
            errors.extend(validate_evidence(item, f"{prefix}, evidence[{index}]"))
            if isinstance(item, dict) and isinstance(item.get("id"), str):
                if item["id"] in seen_evidence:
                    errors.append(f"{prefix}: duplicate evidence id {item['id']!r}")
                seen_evidence.add(item["id"])
    if not isinstance(value.get("needsRecheck"), bool):
        errors.append(f"{prefix}: needsRecheck must be boolean")
    for field in ("lastAssessed", "lastVerified"):
        if value.get(field) is not None and not valid_timestamp(value.get(field)):
            errors.append(f"{prefix}: {field} must be null or an ISO timestamp")
    for field in ("createdAt", "updatedAt"):
        if not valid_timestamp(value.get(field)):
            errors.append(f"{prefix}: {field} must be an ISO timestamp")
    return errors


def validate_concept_store(value: dict[str, Any], path: Path) -> list[str]:
    errors: list[str] = []
    if value.get("schemaVersion") != SCHEMA_VERSION:
        errors.append(f"{path}: unsupported schemaVersion")
    concepts = value.get("concepts")
    if not isinstance(concepts, dict):
        errors.append(f"{path}: concepts must be an object")
        return errors
    for concept_id, record in concepts.items():
        errors.extend(validate_concept_record(concept_id, record, path))
    if not valid_timestamp(value.get("updatedAt")):
        errors.append(f"{path}: updatedAt must be an ISO timestamp")
    return errors


def validate_lesson(value: dict[str, Any], path: Path) -> list[str]:
    errors: list[str] = []
    if value.get("schemaVersion") != SCHEMA_VERSION:
        errors.append(f"{path}: unsupported schemaVersion")
    lesson_id = value.get("id")
    try:
        require_id(lesson_id, "lesson ID")
    except StateError as exc:
        errors.append(f"{path}: {exc}")
    if lesson_id != path.parent.name:
        errors.append(f"{path}: lesson id must match directory name")
    for field in ("title", "goal"):
        if not isinstance(value.get(field), str) or not value[field].strip() or len(value[field]) > MAX_TEXT:
            errors.append(f"{path}: {field} must be a non-empty string of at most {MAX_TEXT} characters")
    status = value.get("status")
    phase = value.get("phase")
    if status not in STATUSES:
        errors.append(f"{path}: invalid status")
    if phase not in PHASES:
        errors.append(f"{path}: invalid phase")
    if status == "paused" and phase != "paused":
        errors.append(f"{path}: paused lesson must use paused phase")
    if status == "completed" and phase != "completed":
        errors.append(f"{path}: completed lesson must use completed phase")
    if status == "active" and phase in {"paused", "completed"}:
        errors.append(f"{path}: active lesson cannot use {phase!r} phase")
    for field in ("currentNode", "lastAssessedStep", "nextStep"):
        if value.get(field) is not None and not isinstance(value.get(field), str):
            errors.append(f"{path}: {field} must be null or a string")
    questions = value.get("openQuestions")
    if not isinstance(questions, list) or not all(isinstance(item, str) for item in questions):
        errors.append(f"{path}: openQuestions must be an array of strings")
    relevant = value.get("relevantConcepts")
    if not isinstance(relevant, list):
        errors.append(f"{path}: relevantConcepts must be an array")
    else:
        for concept_id in relevant:
            try:
                require_id(concept_id, "concept ID")
            except StateError as exc:
                errors.append(f"{path}: {exc}")
    for field in ("createdAt", "updatedAt"):
        if not valid_timestamp(value.get(field)):
            errors.append(f"{path}: {field} must be an ISO timestamp")
    plan_file = value.get("planFile")
    if plan_file not in (None, "plan.md"):
        errors.append(f"{path}: planFile must be null or 'plan.md'")
    if plan_file == "plan.md":
        errors.extend(validate_plan(path.parent / "plan.md"))
    card_source_file = value.get("cardSourceFile")
    if card_source_file not in (None, "card-source.json"):
        errors.append(f"{path}: cardSourceFile must be null or 'card-source.json'")
    if card_source_file == "card-source.json" and not (path.parent / "card-source.md").is_file():
        errors.append(f"{path}: card-source.md view is missing")
    return errors


def validate_plan(path: Path) -> list[str]:
    if not path.is_file():
        return [f"{path}: referenced plan does not exist"]
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        return [f"{path}: cannot read plan: {exc}"]
    match = re.search(r"```mermaid[ \t]*\n(.*?)```", text, re.DOTALL)
    if not match:
        return [f"{path}: plan must contain a complete fenced Mermaid diagram"]
    if not re.search(r"(?m)^\s*(?:graph|flowchart)\s+(?:TB|TD|BT|RL|LR)\b", match.group(1)):
        return [f"{path}: Mermaid block must declare graph/flowchart direction"]
    return []


def validate_string_list(value: Any, prefix: str, *, require_items: bool = False) -> list[str]:
    if not isinstance(value, list) or not all(isinstance(item, str) and item.strip() for item in value):
        return [f"{prefix} must be an array of non-empty strings"]
    if require_items and not value:
        return [f"{prefix} must contain at least one item"]
    return []


def validate_card_source(
    value: dict[str, Any],
    path: Path,
    lesson: dict[str, Any],
    concepts: dict[str, Any],
    *,
    require_current_demonstrated: bool = False,
) -> list[str]:
    errors: list[str] = []
    if value.get("schemaVersion") != SCHEMA_VERSION:
        errors.append(f"{path}: unsupported schemaVersion")
    if value.get("lessonId") != lesson.get("id"):
        errors.append(f"{path}: lessonId must match lesson state")
    if not valid_timestamp(value.get("generatedAt")):
        errors.append(f"{path}: generatedAt must be an ISO timestamp")
    entries = value.get("entries")
    if not isinstance(entries, list) or not entries:
        return errors + [f"{path}: entries must be a non-empty array"]
    seen_concepts: set[str] = set()
    for index, entry in enumerate(entries):
        prefix = f"{path}: entries[{index}]"
        if not isinstance(entry, dict):
            errors.append(f"{prefix} must be an object")
            continue
        concept_id = entry.get("conceptId")
        try:
            require_id(concept_id, "concept ID")
        except StateError as exc:
            errors.append(f"{prefix}: {exc}")
            continue
        if concept_id in seen_concepts:
            errors.append(f"{prefix}: duplicate concept {concept_id!r}")
        seen_concepts.add(concept_id)
        concept = concepts.get(concept_id)
        if not isinstance(concept, dict):
            errors.append(f"{prefix}: unknown concept {concept_id!r}")
            continue
        if concept_id not in lesson.get("relevantConcepts", []):
            errors.append(f"{prefix}: concept is not relevant to this lesson")
        if require_current_demonstrated and concept.get("status") != "demonstrated":
            errors.append(f"{prefix}: concept must be demonstrated before it is eligible for cards")
        errors.extend(validate_string_list(entry.get("verifiedClaims"), f"{prefix}.verifiedClaims", require_items=True))
        for field in ("notation", "assumptions", "examples"):
            errors.extend(validate_string_list(entry.get(field), f"{prefix}.{field}"))
        evidence_ids = entry.get("learnerEvidenceIds")
        errors.extend(validate_string_list(evidence_ids, f"{prefix}.learnerEvidenceIds", require_items=True))
        evidence_by_id = {
            item.get("id"): item for item in concept.get("evidence", []) if isinstance(item, dict)
        }
        qualifying_evidence = False
        if isinstance(evidence_ids, list):
            for evidence_id in evidence_ids:
                evidence = evidence_by_id.get(evidence_id)
                if not evidence:
                    errors.append(f"{prefix}: unknown learner evidence {evidence_id!r}")
                    continue
                if (
                    evidence.get("kind") in GENERATIVE_KINDS
                    and evidence.get("outcome") == "pass"
                    and evidence.get("reasoningQuality") == "sound"
                ):
                    qualifying_evidence = True
        if not qualifying_evidence:
            errors.append(f"{prefix}: at least one referenced evidence item must demonstrate generative understanding")
        if entry.get("volatility") not in VOLATILITIES:
            errors.append(f"{prefix}: volatility must be 'stable' or 'changing'")
        if not valid_timestamp(entry.get("verifiedAt")):
            errors.append(f"{prefix}: verifiedAt must be an ISO timestamp")
        sources = entry.get("sources")
        if not isinstance(sources, list) or not sources:
            errors.append(f"{prefix}.sources must be a non-empty array")
        else:
            for source_index, source in enumerate(sources):
                source_prefix = f"{prefix}.sources[{source_index}]"
                if not isinstance(source, dict):
                    errors.append(f"{source_prefix} must be an object")
                    continue
                for field in ("label", "location", "support"):
                    if not isinstance(source.get(field), str) or not source[field].strip():
                        errors.append(f"{source_prefix}.{field} must be a non-empty string")
                if source.get("locator") is not None and not isinstance(source.get("locator"), str):
                    errors.append(f"{source_prefix}.locator must be null or a string")
                if not valid_timestamp(source.get("checkedAt")):
                    errors.append(f"{source_prefix}.checkedAt must be an ISO timestamp")
    return errors


def render_card_source(value: dict[str, Any], lesson: dict[str, Any], concepts: dict[str, Any]) -> str:
    lines = [f"# Card source — {lesson['title']}", "", f"Generated: {value['generatedAt']}", ""]
    for entry in value["entries"]:
        concept = concepts[entry["conceptId"]]
        lines.extend([f"## {concept['label']}", "", f"Concept: `{entry['conceptId']}`", ""])
        lines.append("### Verified claims")
        lines.extend(f"- {claim}" for claim in entry["verifiedClaims"])
        for title, field in (("Notation", "notation"), ("Assumptions", "assumptions"), ("Examples", "examples")):
            if entry[field]:
                lines.extend(["", f"### {title}"])
                lines.extend(f"- {item}" for item in entry[field])
        lines.extend(["", "### Learner evidence"])
        lines.extend(f"- `{evidence_id}`" for evidence_id in entry["learnerEvidenceIds"])
        lines.extend(
            [
                "",
                "### Verification",
                f"- Verified: {entry['verifiedAt']}",
                f"- Volatility: {entry['volatility']}",
                "",
                "### Sources",
            ]
        )
        for source in entry["sources"]:
            locator = f" — {source['locator']}" if source.get("locator") else ""
            lines.append(f"- {source['label']}: {source['location']}{locator} (checked {source['checkedAt']})")
            lines.append(f"  - Support: {source['support']}")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def find_cycle(concepts: dict[str, dict[str, Any]]) -> list[str] | None:
    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(concept_id: str, trail: list[str]) -> list[str] | None:
        if concept_id in visiting:
            start = trail.index(concept_id)
            return trail[start:] + [concept_id]
        if concept_id in visited:
            return None
        visiting.add(concept_id)
        for prerequisite in concepts[concept_id]["prerequisites"]:
            if prerequisite in concepts:
                cycle = visit(prerequisite, trail + [concept_id])
                if cycle:
                    return cycle
        visiting.remove(concept_id)
        visited.add(concept_id)
        return None

    for concept_id in concepts:
        cycle = visit(concept_id, [])
        if cycle:
            return cycle
    return None


def validate_store(root: Path) -> list[str]:
    errors: list[str] = []
    if not root.is_dir():
        return [f"{root}: learner-state directory does not exist"]

    try:
        profile = load_json(profile_path(root))
        errors.extend(validate_profile(profile, profile_path(root)))
    except StateError as exc:
        errors.append(str(exc))

    concepts: dict[str, Any] = {}
    concepts_graph_safe = False
    try:
        concept_store = load_json(concepts_path(root))
        concept_errors = validate_concept_store(concept_store, concepts_path(root))
        errors.extend(concept_errors)
        raw_concepts = concept_store.get("concepts")
        if isinstance(raw_concepts, dict):
            concepts = raw_concepts
            concepts_graph_safe = all(
                isinstance(record, dict)
                and isinstance(record.get("prerequisites"), list)
                and all(isinstance(item, str) and ID_RE.fullmatch(item) for item in record["prerequisites"])
                for record in concepts.values()
            )
            if concepts_graph_safe:
                for concept_id, record in concepts.items():
                    for prerequisite in record["prerequisites"]:
                        if prerequisite not in concepts:
                            errors.append(
                                f"{concepts_path(root)}: concept {concept_id!r} references missing prerequisite {prerequisite!r}"
                            )
                cycle = find_cycle(concepts)
                if cycle:
                    errors.append(f"{concepts_path(root)}: prerequisite cycle: {' -> '.join(cycle)}")
    except StateError as exc:
        errors.append(str(exc))

    lessons_root = root / "lessons"
    lesson_ids: set[str] = set()
    if lessons_root.is_symlink():
        errors.append(f"{lessons_root}: lessons directory must not be a symlink")
        return errors
    if lessons_root.exists():
        try:
            children = sorted(lessons_root.iterdir())
        except OSError as exc:
            errors.append(f"{lessons_root}: cannot list lessons: {exc}")
            return errors
        for directory in children:
            if directory.is_symlink():
                errors.append(f"{directory}: lesson directory must not be a symlink")
                continue
            path = directory / "state.json"
            if not directory.is_dir() or not path.exists():
                continue
            try:
                lesson = load_json(path)
                errors.extend(validate_lesson(lesson, path))
                if isinstance(lesson.get("id"), str):
                    lesson_ids.add(lesson["id"])
                relevant = lesson.get("relevantConcepts", [])
                if isinstance(relevant, list):
                    for concept_id in relevant:
                        if concept_id not in concepts:
                            errors.append(f"{path}: references missing concept {concept_id!r}")
                if lesson.get("cardSourceFile") == "card-source.json":
                    source_path = directory / "card-source.json"
                    try:
                        source_packet = load_json(source_path)
                        errors.extend(validate_card_source(source_packet, source_path, lesson, concepts))
                    except StateError as exc:
                        errors.append(str(exc))
            except StateError as exc:
                errors.append(str(exc))
    for concept_id, record in concepts.items():
        if not isinstance(record, dict) or not isinstance(record.get("evidence"), list):
            continue
        for index, evidence in enumerate(record["evidence"]):
            if isinstance(evidence, dict) and isinstance(evidence.get("lessonId"), str):
                if evidence["lessonId"] not in lesson_ids:
                    errors.append(
                        f"{concepts_path(root)}: concept {concept_id!r}, evidence[{index}] references missing lesson {evidence['lessonId']!r}"
                    )
    return errors


def assert_valid_store(root: Path) -> None:
    require_initialized(root)
    errors = validate_store(root)
    if errors:
        raise StateError("Learner state is invalid; no changes were made:\n- " + "\n- ".join(errors))


def prepare_mutation(root: Path) -> None:
    recover_transaction(root)
    assert_valid_store(root)


def load_concept_store(root: Path) -> dict[str, Any]:
    require_initialized(root)
    store = load_json(concepts_path(root))
    errors = validate_concept_store(store, concepts_path(root))
    if errors:
        raise StateError("Cannot use invalid concepts store:\n- " + "\n- ".join(errors))
    return store


def load_lesson(root: Path, lesson_id: str) -> dict[str, Any]:
    directory = assert_safe_lesson_dir(root, lesson_id)
    path = directory / "state.json"
    lesson = load_json(path)
    errors = validate_lesson(lesson, path)
    if errors:
        raise StateError("Cannot use invalid lesson:\n- " + "\n- ".join(errors))
    return lesson


def command_init(args: argparse.Namespace) -> None:
    initialize(args.root)
    emit({"ok": True, "root": str(args.root)})


def command_validate(args: argparse.Namespace) -> None:
    if args.root.exists():
        with state_lock(args.root):
            recover_transaction(args.root)
            errors = validate_store(args.root)
    else:
        errors = validate_store(args.root)
    if errors:
        emit({"ok": False, "root": str(args.root), "errors": errors})
        raise StateError(f"Validation failed with {len(errors)} error(s)")
    emit({"ok": True, "root": str(args.root), "errors": []})


def command_profile_show(args: argparse.Namespace) -> None:
    assert_valid_store(args.root)
    emit(load_json(profile_path(args.root)))


def command_profile_set(args: argparse.Namespace) -> None:
    if not PROFILE_KEY_RE.fullmatch(args.key):
        raise StateError("Preference key must contain only letters, numbers, '_' or '-' and start with a letter")
    value = strict_json_loads(args.value, source="--value")
    with state_lock(args.root):
        prepare_mutation(args.root)
        profile = load_json(profile_path(args.root))
        profile["preferences"][args.key] = value
        profile["updatedAt"] = now()
        transactional_write(args.root, {profile_path(args.root): json_text(profile)})
    emit({"ok": True, "key": args.key, "value": value})


def command_concept_ensure(args: argparse.Namespace) -> None:
    concept_id = require_id(args.id, "concept ID")
    label = require_text(args.label, "label")
    scope = require_text(args.scope, "scope")
    prerequisites = sorted(set(require_id(item, "prerequisite ID") for item in args.prerequisite))
    with state_lock(args.root):
        prepare_mutation(args.root)
        store = load_concept_store(args.root)
        concepts = store["concepts"]
        missing = [item for item in prerequisites if item not in concepts]
        if missing:
            raise StateError("Create prerequisite concepts first: " + ", ".join(missing))
        existing = concepts.get(concept_id)
        if concept_id in concepts:
            if (existing["label"] != label or existing["scope"] != scope) and not args.update_metadata:
                raise StateError(
                    "Concept metadata differs from existing state; inspect it first and use --update-metadata for an intentional correction"
                )
            existing["prerequisites"] = sorted(set(existing["prerequisites"] + prerequisites))
            record = existing
        else:
            timestamp = now()
            record = {
                "id": concept_id,
                "label": label,
                "scope": scope,
                "status": "unassessed",
                "prerequisites": prerequisites,
                "lastAssessed": None,
                "lastVerified": None,
                "needsRecheck": False,
                "misconceptions": [],
                "evidence": [],
                "createdAt": timestamp,
                "updatedAt": timestamp,
            }
            concepts[concept_id] = record
        if args.update_metadata:
            record["label"] = label
            record["scope"] = scope
        record["updatedAt"] = now()
        cycle = find_cycle(concepts)
        if cycle:
            raise StateError(f"Prerequisites would create a cycle: {' -> '.join(cycle)}")
        store["updatedAt"] = now()
        transactional_write(args.root, {concepts_path(args.root): json_text(store)})
    emit(record)


def command_concept_show(args: argparse.Namespace) -> None:
    assert_valid_store(args.root)
    store = load_concept_store(args.root)
    concept_id = require_id(args.id, "concept ID")
    if concept_id not in store["concepts"]:
        raise StateError(f"Unknown concept: {concept_id}")
    emit(store["concepts"][concept_id])


def command_concept_list(args: argparse.Namespace) -> None:
    assert_valid_store(args.root)
    store = load_concept_store(args.root)
    records = []
    for concept in store["concepts"].values():
        if args.status and concept["status"] != args.status:
            continue
        records.append(
            {
                "id": concept["id"],
                "label": concept["label"],
                "status": concept["status"],
                "needsRecheck": concept["needsRecheck"],
                "lastAssessed": concept["lastAssessed"],
            }
        )
    emit({"concepts": sorted(records, key=lambda item: item["id"])})


def command_lesson_create(args: argparse.Namespace) -> None:
    lesson_id = require_id(args.id, "lesson ID")
    title = require_text(args.title, "title")
    goal = require_text(args.goal, "goal")
    relevant = sorted(set(require_id(item, "concept ID") for item in args.relevant_concept))
    with state_lock(args.root):
        prepare_mutation(args.root)
        concept_store = load_concept_store(args.root)
        missing = [item for item in relevant if item not in concept_store["concepts"]]
        if missing:
            raise StateError("Create relevant concepts first: " + ", ".join(missing))
        path = assert_safe_lesson_dir(args.root, lesson_id) / "state.json"
        if path.exists():
            raise StateError(f"Lesson already exists: {lesson_id}")
        timestamp = now()
        lesson = {
            "schemaVersion": SCHEMA_VERSION,
            "id": lesson_id,
            "title": title,
            "goal": goal,
            "status": "active",
            "phase": "probe",
            "currentNode": None,
            "lastAssessedStep": None,
            "nextStep": None,
            "openQuestions": [],
            "relevantConcepts": relevant,
            "planFile": None,
            "cardSourceFile": None,
            "createdAt": timestamp,
            "updatedAt": timestamp,
        }
        transactional_write(args.root, {path: json_text(lesson)})
    emit(lesson)


def command_lesson_update(args: argparse.Namespace) -> None:
    lesson_id = require_id(args.id, "lesson ID")
    with state_lock(args.root):
        prepare_mutation(args.root)
        lesson = load_lesson(args.root, lesson_id)
        store = load_concept_store(args.root)
        requested_status = args.status or lesson["status"]
        requested_phase = args.phase or lesson["phase"]
        if args.status == "paused" and args.phase is None:
            requested_phase = "paused"
        elif args.status == "completed" and args.phase is None:
            requested_phase = "completed"
        elif args.phase == "paused" and args.status is None:
            requested_status = "paused"
        elif args.phase == "completed" and args.status is None:
            requested_status = "completed"
        if requested_status == "active" and requested_phase in {"paused", "completed"}:
            raise StateError("Resuming a lesson requires both --status active and --phase probe, plan, or teach")
        if requested_status == "paused" and requested_phase != "paused":
            raise StateError("Paused status requires paused phase")
        if requested_status == "completed" and requested_phase != "completed":
            raise StateError("Completed status requires completed phase")
        lesson["status"] = requested_status
        lesson["phase"] = requested_phase
        for argument, field in (
            (args.current_node, "currentNode"),
            (args.last_assessed_step, "lastAssessedStep"),
            (args.next_step, "nextStep"),
        ):
            if argument is not None:
                lesson[field] = require_text(argument, field)
        if args.clear_open_questions:
            lesson["openQuestions"] = []
        for question in args.add_open_question:
            question = require_text(question, "open question")
            if question not in lesson["openQuestions"]:
                lesson["openQuestions"].append(question)
        for concept_id in args.add_relevant_concept:
            concept_id = require_id(concept_id, "concept ID")
            if concept_id not in store["concepts"]:
                raise StateError(f"Create relevant concept first: {concept_id}")
            if concept_id not in lesson["relevantConcepts"]:
                lesson["relevantConcepts"].append(concept_id)
        lesson["relevantConcepts"].sort()
        lesson["updatedAt"] = now()
        transactional_write(args.root, {lesson_path(args.root, lesson_id): json_text(lesson)})
    emit(lesson)


def command_lesson_show(args: argparse.Namespace) -> None:
    assert_valid_store(args.root)
    emit(load_lesson(args.root, args.id))


def command_lesson_list(args: argparse.Namespace) -> None:
    assert_valid_store(args.root)
    lessons = []
    lessons_root = args.root / "lessons"
    if lessons_root.exists():
        for directory in sorted(item for item in lessons_root.iterdir() if item.is_dir() and not item.is_symlink()):
            path = directory / "state.json"
            if not path.is_file():
                continue
            lesson = load_json(path)
            errors = validate_lesson(lesson, path)
            if errors:
                raise StateError("Invalid lesson encountered:\n- " + "\n- ".join(errors))
            if args.status and lesson["status"] != args.status:
                continue
            lessons.append(
                {
                    "id": lesson["id"],
                    "title": lesson["title"],
                    "status": lesson["status"],
                    "phase": lesson["phase"],
                    "nextStep": lesson["nextStep"],
                    "updatedAt": lesson["updatedAt"],
                }
            )
    emit({"lessons": lessons})


def command_plan_save(args: argparse.Namespace) -> None:
    source = Path(args.source).expanduser().resolve()
    if not source.is_file():
        raise StateError(f"Plan source does not exist: {source}")
    if source.stat().st_size > 1_000_000:
        raise StateError("Plan source exceeds 1 MB")
    content = source.read_text(encoding="utf-8").rstrip() + "\n"
    temporary_fd, temporary_name = tempfile.mkstemp(suffix=".md")
    os.close(temporary_fd)
    temporary_path = Path(temporary_name)
    try:
        temporary_path.write_text(content, encoding="utf-8")
        errors = validate_plan(temporary_path)
        if errors:
            raise StateError("Invalid plan:\n- " + "\n- ".join(errors))
    finally:
        temporary_path.unlink(missing_ok=True)
    with state_lock(args.root):
        prepare_mutation(args.root)
        lesson = load_lesson(args.root, args.id)
        destination = assert_safe_lesson_dir(args.root, args.id) / "plan.md"
        lesson["planFile"] = "plan.md"
        lesson["phase"] = "plan" if lesson["phase"] == "probe" else lesson["phase"]
        lesson["updatedAt"] = now()
        transactional_write(
            args.root,
            {destination: content, lesson_path(args.root, args.id): json_text(lesson)},
        )
    emit({"ok": True, "lessonId": args.id, "plan": str(destination)})


def parse_timestamp(value: str) -> datetime:
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    return parsed if parsed.tzinfo else parsed.replace(tzinfo=timezone.utc)


def card_source_freshness(value: dict[str, Any], max_age_days: int) -> list[dict[str, Any]]:
    if max_age_days < 1:
        raise StateError("max-age-days must be at least 1")
    current = datetime.now(timezone.utc)
    results = []
    for entry in value["entries"]:
        stale_fields: list[str] = []
        if entry["volatility"] == "changing":
            timestamps = [("verifiedAt", entry["verifiedAt"])]
            timestamps.extend(
                (f"source:{source['label']}", source["checkedAt"]) for source in entry["sources"]
            )
            for label, timestamp in timestamps:
                age_days = (current - parse_timestamp(timestamp)).total_seconds() / 86400
                if age_days > max_age_days:
                    stale_fields.append(f"{label} is {age_days:.1f} days old")
        results.append(
            {
                "conceptId": entry["conceptId"],
                "fresh": not stale_fields,
                "reason": "stable material" if entry["volatility"] == "stable" else "; ".join(stale_fields) or "current",
            }
        )
    return results


def load_card_source(root: Path, lesson_id: str) -> tuple[dict[str, Any], dict[str, Any], dict[str, Any]]:
    assert_valid_store(root)
    lesson = load_lesson(root, lesson_id)
    if lesson.get("cardSourceFile") != "card-source.json":
        raise StateError(f"Lesson {lesson_id!r} has no saved card source")
    concepts = load_concept_store(root)["concepts"]
    path = card_source_json_path(root, lesson_id)
    packet = load_json(path)
    errors = validate_card_source(packet, path, lesson, concepts)
    if errors:
        raise StateError("Invalid card source:\n- " + "\n- ".join(errors))
    return packet, lesson, concepts


def command_card_source_save(args: argparse.Namespace) -> None:
    source = Path(args.source).expanduser().resolve()
    try:
        content = source.read_text(encoding="utf-8")
    except OSError as exc:
        raise StateError(f"Cannot read card-source input {source}: {exc}") from exc
    packet = strict_json_loads(content, source=str(source))
    if not isinstance(packet, dict):
        raise StateError("Card-source input must be a JSON object")
    packet["schemaVersion"] = SCHEMA_VERSION
    packet["generatedAt"] = now()
    entries = packet.get("entries")
    if isinstance(entries, list):
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            for field in ("notation", "assumptions", "examples"):
                entry.setdefault(field, [])
            sources = entry.get("sources")
            if isinstance(sources, list):
                for source_item in sources:
                    if isinstance(source_item, dict):
                        source_item.setdefault("locator", None)
    with state_lock(args.root):
        prepare_mutation(args.root)
        lesson = load_lesson(args.root, args.id)
        concepts = load_concept_store(args.root)["concepts"]
        path = card_source_json_path(args.root, args.id)
        errors = validate_card_source(
            packet, path, lesson, concepts, require_current_demonstrated=True
        )
        if errors:
            raise StateError("Invalid card source:\n- " + "\n- ".join(errors))
        freshness = card_source_freshness(packet, args.max_age_days)
        stale = [item for item in freshness if not item["fresh"]]
        if stale:
            details = "; ".join(f"{item['conceptId']}: {item['reason']}" for item in stale)
            raise StateError(f"Changing card-source material must be reverified before saving: {details}")
        markdown = render_card_source(packet, lesson, concepts)
        lesson["cardSourceFile"] = "card-source.json"
        lesson["updatedAt"] = now()
        transactional_write(
            args.root,
            {
                path: json_text(packet),
                card_source_markdown_path(args.root, args.id): markdown,
                lesson_path(args.root, args.id): json_text(lesson),
            },
        )
    emit(
        {
            "ok": True,
            "lessonId": args.id,
            "concepts": [entry["conceptId"] for entry in packet["entries"]],
            "cardSource": str(path),
            "markdown": str(card_source_markdown_path(args.root, args.id)),
        }
    )


def command_card_source_show(args: argparse.Namespace) -> None:
    packet, _lesson, _concepts = load_card_source(args.root, args.id)
    emit(packet)


def command_card_source_check(args: argparse.Namespace) -> None:
    packet, _lesson, concepts = load_card_source(args.root, args.id)
    results = card_source_freshness(packet, args.max_age_days)
    stale = [item for item in results if not item["fresh"]]
    not_demonstrated = [
        entry["conceptId"]
        for entry in packet["entries"]
        if concepts[entry["conceptId"]]["status"] != "demonstrated"
    ]
    emit(
        {
            "ok": not stale and not not_demonstrated,
            "maxAgeDays": args.max_age_days,
            "entries": results,
            "conceptsNeedingRedemonstration": not_demonstrated,
        }
    )
    problems = []
    if stale:
        problems.append(f"{len(stale)} changing source entr{'y is' if len(stale) == 1 else 'ies are'} stale")
    if not_demonstrated:
        problems.append(f"{len(not_demonstrated)} concept(s) need renewed demonstration")
    if problems:
        raise StateError("; ".join(problems))


def next_status(
    current: str, current_recheck: bool, kind: str, outcome: str, reasoning: str
) -> tuple[str, bool, bool]:
    """Return status, needs_recheck, and whether this is verification evidence."""
    if outcome in {"fail", "partial"}:
        return "developing", True, False
    if outcome == "ungraded":
        if kind == "self_report" and STATUS_RANK[current] < STATUS_RANK["familiar"]:
            return "familiar", current_recheck, False
        return current, current_recheck, False
    if kind in GENERATIVE_KINDS:
        if reasoning == "sound":
            return "demonstrated", False, True
        return "developing", True, False
    if STATUS_RANK[current] < STATUS_RANK["familiar"]:
        return "familiar", current_recheck, False
    return current, current_recheck, False


def command_evidence_record(args: argparse.Namespace) -> None:
    concept_id = require_id(args.concept, "concept ID")
    lesson_id = require_id(args.lesson, "lesson ID")
    summary = require_text(args.summary, "evidence summary")
    misconception = require_text(args.misconception, "misconception", allow_empty=True) if args.misconception else None
    if args.kind in GENERATIVE_KINDS and args.outcome == "pass" and args.reasoning_quality == "not_applicable":
        raise StateError("Passed generative evidence requires an assessed reasoning quality; use sound, weak, or none")
    if args.outcome == "fail" and args.reasoning_quality == "sound":
        raise StateError("Failed evidence cannot have sound reasoning quality")
    with state_lock(args.root):
        prepare_mutation(args.root)
        store = load_concept_store(args.root)
        lesson = load_lesson(args.root, lesson_id)
        concept = store["concepts"].get(concept_id)
        if not concept:
            raise StateError(f"Create concept before recording evidence: {concept_id}")
        timestamp = now()
        evidence = {
            "id": f"ev-{uuid.uuid4().hex[:12]}",
            "timestamp": timestamp,
            "lessonId": lesson_id,
            "kind": args.kind,
            "outcome": args.outcome,
            "reasoningQuality": args.reasoning_quality,
            "summary": summary,
            "misconception": misconception,
        }
        status, needs_recheck, verified = next_status(
            concept["status"], concept["needsRecheck"], args.kind, args.outcome, args.reasoning_quality
        )
        concept["status"] = status
        concept["needsRecheck"] = needs_recheck
        concept["lastAssessed"] = timestamp
        if verified:
            concept["lastVerified"] = timestamp
        if misconception and misconception not in concept["misconceptions"]:
            concept["misconceptions"].append(misconception)
        concept["evidence"].append(evidence)
        concept["updatedAt"] = timestamp
        store["updatedAt"] = timestamp
        if concept_id not in lesson["relevantConcepts"]:
            lesson["relevantConcepts"].append(concept_id)
            lesson["relevantConcepts"].sort()
        lesson["lastAssessedStep"] = summary
        lesson["updatedAt"] = timestamp
        transactional_write(
            args.root,
            {
                concepts_path(args.root): json_text(store),
                lesson_path(args.root, lesson_id): json_text(lesson),
            },
        )
    emit({"ok": True, "conceptId": concept_id, "status": status, "needsRecheck": needs_recheck, "evidence": evidence})


def command_summary(args: argparse.Namespace) -> None:
    assert_valid_store(args.root)
    profile = load_json(profile_path(args.root))
    store = load_concept_store(args.root)
    lesson = load_lesson(args.root, args.lesson) if args.lesson else None
    concept_ids = set(args.concept)
    if lesson:
        concept_ids.update(lesson["relevantConcepts"])
    concepts = {}
    for concept_id in sorted(concept_ids):
        require_id(concept_id, "concept ID")
        if concept_id not in store["concepts"]:
            raise StateError(f"Unknown concept: {concept_id}")
        concepts[concept_id] = store["concepts"][concept_id]
    if not lesson and not concept_ids:
        lesson_summaries = []
        lessons_root = args.root / "lessons"
        if lessons_root.exists():
            for directory in sorted(item for item in lessons_root.iterdir() if item.is_dir() and not item.is_symlink()):
                path = directory / "state.json"
                if not path.is_file():
                    continue
                item = load_json(path)
                lesson_summaries.append(
                    {key: item[key] for key in ("id", "title", "status", "phase", "nextStep", "updatedAt")}
                )
    else:
        lesson_summaries = None
    emit(
        {
            "profile": {"preferences": profile["preferences"], "observations": profile["observations"]},
            "lesson": lesson,
            "lessons": lesson_summaries,
            "concepts": concepts,
        }
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT, help=f"state directory (default: {DEFAULT_ROOT})")
    subparsers = parser.add_subparsers(dest="command", required=True)

    init_parser = subparsers.add_parser("init", help="initialize the learner-state directory without overwriting existing files")
    init_parser.set_defaults(handler=command_init)

    validate_parser = subparsers.add_parser("validate", help="validate all learner-state files and prerequisite references")
    validate_parser.set_defaults(handler=command_validate)

    summary_parser = subparsers.add_parser("summary", help="load compact relevant context for teaching or resumption")
    summary_parser.add_argument("--lesson")
    summary_parser.add_argument("--concept", action="append", default=[])
    summary_parser.set_defaults(handler=command_summary)

    profile_parser = subparsers.add_parser("profile", help="show or update stable learner preferences")
    profile_subparsers = profile_parser.add_subparsers(dest="profile_command", required=True)
    profile_show = profile_subparsers.add_parser("show")
    profile_show.set_defaults(handler=command_profile_show)
    profile_set = profile_subparsers.add_parser("set")
    profile_set.add_argument("--key", required=True)
    profile_set.add_argument("--value", required=True, help="JSON value, for example '\"slow\"' or 'true'")
    profile_set.set_defaults(handler=command_profile_set)

    concept_parser = subparsers.add_parser("concept", help="manage capability-scoped concept records")
    concept_subparsers = concept_parser.add_subparsers(dest="concept_command", required=True)
    concept_ensure = concept_subparsers.add_parser("ensure")
    concept_ensure.add_argument("--id", required=True)
    concept_ensure.add_argument("--label", required=True)
    concept_ensure.add_argument("--scope", required=True)
    concept_ensure.add_argument("--prerequisite", action="append", default=[])
    concept_ensure.add_argument("--update-metadata", action="store_true")
    concept_ensure.set_defaults(handler=command_concept_ensure)
    concept_show = concept_subparsers.add_parser("show")
    concept_show.add_argument("--id", required=True)
    concept_show.set_defaults(handler=command_concept_show)
    concept_list = concept_subparsers.add_parser("list")
    concept_list.add_argument("--status", choices=CONCEPT_STATUSES)
    concept_list.set_defaults(handler=command_concept_list)

    lesson_parser = subparsers.add_parser("lesson", help="create, update, or inspect lesson checkpoints")
    lesson_subparsers = lesson_parser.add_subparsers(dest="lesson_command", required=True)
    lesson_create = lesson_subparsers.add_parser("create")
    lesson_create.add_argument("--id", required=True)
    lesson_create.add_argument("--title", required=True)
    lesson_create.add_argument("--goal", required=True)
    lesson_create.add_argument("--relevant-concept", action="append", default=[])
    lesson_create.set_defaults(handler=command_lesson_create)
    lesson_update = lesson_subparsers.add_parser("update")
    lesson_update.add_argument("--id", required=True)
    lesson_update.add_argument("--status", choices=STATUSES)
    lesson_update.add_argument("--phase", choices=PHASES)
    lesson_update.add_argument("--current-node")
    lesson_update.add_argument("--last-assessed-step")
    lesson_update.add_argument("--next-step")
    lesson_update.add_argument("--add-open-question", action="append", default=[])
    lesson_update.add_argument("--clear-open-questions", action="store_true")
    lesson_update.add_argument("--add-relevant-concept", action="append", default=[])
    lesson_update.set_defaults(handler=command_lesson_update)
    lesson_show = lesson_subparsers.add_parser("show")
    lesson_show.add_argument("--id", required=True)
    lesson_show.set_defaults(handler=command_lesson_show)
    lesson_list = lesson_subparsers.add_parser("list")
    lesson_list.add_argument("--status", choices=STATUSES)
    lesson_list.set_defaults(handler=command_lesson_list)

    plan_parser = subparsers.add_parser("plan", help="validate and save a Mermaid lesson plan")
    plan_subparsers = plan_parser.add_subparsers(dest="plan_command", required=True)
    plan_save = plan_subparsers.add_parser("save")
    plan_save.add_argument("--lesson", dest="id", required=True)
    plan_save.add_argument("--source", required=True)
    plan_save.set_defaults(handler=command_plan_save)

    card_source_parser = subparsers.add_parser(
        "card-source", help="save, inspect, or freshness-check verified material for Anki cards"
    )
    card_source_subparsers = card_source_parser.add_subparsers(dest="card_source_command", required=True)
    card_source_save = card_source_subparsers.add_parser("save")
    card_source_save.add_argument("--lesson", dest="id", required=True)
    card_source_save.add_argument("--source", required=True, help="structured card-source JSON input")
    card_source_save.add_argument("--max-age-days", type=int, default=30)
    card_source_save.set_defaults(handler=command_card_source_save)
    card_source_show = card_source_subparsers.add_parser("show")
    card_source_show.add_argument("--lesson", dest="id", required=True)
    card_source_show.set_defaults(handler=command_card_source_show)
    card_source_check = card_source_subparsers.add_parser("check")
    card_source_check.add_argument("--lesson", dest="id", required=True)
    card_source_check.add_argument("--max-age-days", type=int, default=30)
    card_source_check.set_defaults(handler=command_card_source_check)

    evidence_parser = subparsers.add_parser("evidence", help="record assessed evidence and update concept status")
    evidence_subparsers = evidence_parser.add_subparsers(dest="evidence_command", required=True)
    evidence_record = evidence_subparsers.add_parser("record")
    evidence_record.add_argument("--lesson", required=True)
    evidence_record.add_argument("--concept", required=True)
    evidence_record.add_argument("--kind", choices=KINDS, required=True)
    evidence_record.add_argument("--outcome", choices=OUTCOMES, required=True)
    evidence_record.add_argument("--reasoning-quality", choices=REASONING_QUALITIES, required=True)
    evidence_record.add_argument("--summary", required=True)
    evidence_record.add_argument("--misconception")
    evidence_record.set_defaults(handler=command_evidence_record)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    args.root = args.root.expanduser().resolve()
    try:
        args.handler(args)
        return 0
    except StateError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
