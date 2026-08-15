from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path

SCRIPT = Path(__file__).parents[1] / "scripts" / "learning_state.py"


class LearningStateCliTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name) / "state"
        self.run_cli("init")

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def run_cli(self, *arguments: str, check: bool = True) -> subprocess.CompletedProcess[str]:
        result = subprocess.run(
            [sys.executable, str(SCRIPT), "--root", str(self.root), *arguments],
            text=True,
            capture_output=True,
            check=False,
        )
        if check and result.returncode != 0:
            self.fail(f"command failed: {arguments}\nstdout:\n{result.stdout}\nstderr:\n{result.stderr}")
        return result

    def output_json(self, *arguments: str) -> dict:
        return json.loads(self.run_cli(*arguments).stdout)

    def ensure_concept(self, concept_id: str = "math:vectors") -> None:
        self.run_cli(
            "concept",
            "ensure",
            "--id",
            concept_id,
            "--label",
            "Evaluate vectors",
            "--scope",
            "Compute and explain basic vector operations",
        )

    def create_lesson(self, lesson_id: str = "linear-algebra") -> None:
        self.run_cli(
            "lesson",
            "create",
            "--id",
            lesson_id,
            "--title",
            "Linear algebra",
            "--goal",
            "Explain and apply covectors",
        )

    def demonstrate(self, concept_id: str = "math:vectors", lesson_id: str = "linear-algebra") -> str:
        result = self.output_json(
            "evidence",
            "record",
            "--lesson",
            lesson_id,
            "--concept",
            concept_id,
            "--kind",
            "application",
            "--outcome",
            "pass",
            "--reasoning-quality",
            "sound",
            "--summary",
            "Applied the concept correctly and justified the steps",
        )
        return result["evidence"]["id"]

    def write_card_source(
        self,
        evidence_id: str,
        *,
        volatility: str = "stable",
        verified_at: str | None = None,
    ) -> Path:
        timestamp = verified_at or datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
        packet = {
            "lessonId": "linear-algebra",
            "entries": [
                {
                    "conceptId": "math:vectors",
                    "verifiedClaims": ["Vector addition combines corresponding components."],
                    "notation": ["v + w"],
                    "assumptions": ["The vectors belong to the same vector space."],
                    "examples": ["(1, 2) + (3, 4) = (4, 6)"],
                    "learnerEvidenceIds": [evidence_id],
                    "volatility": volatility,
                    "verifiedAt": timestamp,
                    "sources": [
                        {
                            "label": "Course notes",
                            "location": "notes/linear-algebra.md",
                            "locator": "Vector addition",
                            "checkedAt": timestamp,
                            "support": "The notes define addition component by component.",
                        }
                    ],
                }
            ],
        }
        path = Path(self.temporary.name) / "card-source-input.json"
        path.write_text(json.dumps(packet), encoding="utf-8")
        return path

    def test_init_is_idempotent_and_valid(self) -> None:
        self.run_cli("init")
        result = self.output_json("validate")
        self.assertTrue(result["ok"])
        self.assertTrue((self.root / "profile.json").is_file())
        self.assertTrue((self.root / "concepts.json").is_file())

    def test_evidence_rules_and_lesson_relevance(self) -> None:
        self.ensure_concept()
        self.create_lesson()

        recognition = self.output_json(
            "evidence",
            "record",
            "--lesson",
            "linear-algebra",
            "--concept",
            "math:vectors",
            "--kind",
            "recognition",
            "--outcome",
            "pass",
            "--reasoning-quality",
            "none",
            "--summary",
            "Selected the correct vector operation",
        )
        self.assertEqual(recognition["status"], "familiar")

        application = self.output_json(
            "evidence",
            "record",
            "--lesson",
            "linear-algebra",
            "--concept",
            "math:vectors",
            "--kind",
            "application",
            "--outcome",
            "pass",
            "--reasoning-quality",
            "sound",
            "--summary",
            "Computed a vector result and justified each step",
        )
        self.assertEqual(application["status"], "demonstrated")
        self.assertFalse(application["needsRecheck"])

        failure = self.output_json(
            "evidence",
            "record",
            "--lesson",
            "linear-algebra",
            "--concept",
            "math:vectors",
            "--kind",
            "application",
            "--outcome",
            "fail",
            "--reasoning-quality",
            "weak",
            "--summary",
            "Confused scalar and vector addition",
            "--misconception",
            "Treated scalar addition as component-wise vector addition",
        )
        self.assertEqual(failure["status"], "developing")
        self.assertTrue(failure["needsRecheck"])

        recognition_after_failure = self.output_json(
            "evidence",
            "record",
            "--lesson",
            "linear-algebra",
            "--concept",
            "math:vectors",
            "--kind",
            "recognition",
            "--outcome",
            "pass",
            "--reasoning-quality",
            "none",
            "--summary",
            "Recognized the correct operation after the contradiction",
        )
        self.assertEqual(recognition_after_failure["status"], "developing")
        self.assertTrue(recognition_after_failure["needsRecheck"])

        context = self.output_json("summary", "--lesson", "linear-algebra")
        self.assertIn("math:vectors", context["concepts"])
        self.assertEqual(
            context["lesson"]["lastAssessedStep"],
            "Recognized the correct operation after the contradiction",
        )
        self.assertTrue(self.output_json("validate")["ok"])

    def test_prerequisites_must_exist_and_cycles_are_rejected(self) -> None:
        missing = self.run_cli(
            "concept",
            "ensure",
            "--id",
            "math:covectors",
            "--label",
            "Covectors",
            "--scope",
            "Evaluate covectors",
            "--prerequisite",
            "math:vectors",
            check=False,
        )
        self.assertNotEqual(missing.returncode, 0)
        self.assertIn("Create prerequisite concepts first", missing.stderr)

        self.ensure_concept()
        self.run_cli(
            "concept",
            "ensure",
            "--id",
            "math:covectors",
            "--label",
            "Covectors",
            "--scope",
            "Evaluate covectors",
            "--prerequisite",
            "math:vectors",
        )
        cycle = self.run_cli(
            "concept",
            "ensure",
            "--id",
            "math:vectors",
            "--label",
            "Evaluate vectors",
            "--scope",
            "Compute and explain basic vector operations",
            "--prerequisite",
            "math:covectors",
            check=False,
        )
        self.assertNotEqual(cycle.returncode, 0)
        self.assertIn("cycle", cycle.stderr)
        self.assertTrue(self.output_json("validate")["ok"])

    def test_plan_must_contain_mermaid_and_is_saved_atomically(self) -> None:
        self.create_lesson("differential-forms")
        source = Path(self.temporary.name) / "plan.md"
        source.write_text(
            "# Differential forms plan\n\n```mermaid\ngraph LR\n  A[Vectors] --> B[Covectors]\n```\n",
            encoding="utf-8",
        )
        result = self.output_json(
            "plan", "save", "--lesson", "differential-forms", "--source", str(source)
        )
        self.assertTrue(result["ok"])
        saved = self.root / "lessons" / "differential-forms" / "plan.md"
        self.assertEqual(saved.read_text(encoding="utf-8"), source.read_text(encoding="utf-8"))
        lesson = self.output_json("lesson", "show", "--id", "differential-forms")
        self.assertEqual(lesson["planFile"], "plan.md")
        self.assertEqual(lesson["phase"], "plan")
        self.assertTrue(self.output_json("validate")["ok"])

        invalid = Path(self.temporary.name) / "invalid.md"
        invalid.write_text("# No diagram\n", encoding="utf-8")
        rejected = self.run_cli(
            "plan", "save", "--lesson", "differential-forms", "--source", str(invalid), check=False
        )
        self.assertNotEqual(rejected.returncode, 0)
        self.assertEqual(saved.read_text(encoding="utf-8"), source.read_text(encoding="utf-8"))

    def test_card_source_requires_demonstration_and_renders_grounded_markdown(self) -> None:
        self.ensure_concept()
        self.create_lesson()
        unassessed_source = self.write_card_source("ev-000000000000")
        rejected = self.run_cli(
            "card-source",
            "save",
            "--lesson",
            "linear-algebra",
            "--source",
            str(unassessed_source),
            check=False,
        )
        self.assertNotEqual(rejected.returncode, 0)
        self.assertIn("must be demonstrated", rejected.stderr)

        evidence_id = self.demonstrate()
        source = self.write_card_source(evidence_id)
        saved = self.output_json(
            "card-source", "save", "--lesson", "linear-algebra", "--source", str(source)
        )
        self.assertTrue(saved["ok"])
        self.assertEqual(saved["concepts"], ["math:vectors"])

        packet = self.output_json("card-source", "show", "--lesson", "linear-algebra")
        self.assertEqual(packet["entries"][0]["learnerEvidenceIds"], [evidence_id])
        markdown = self.root / "lessons" / "linear-algebra" / "card-source.md"
        rendered = markdown.read_text(encoding="utf-8")
        self.assertIn("Vector addition combines corresponding components", rendered)
        self.assertIn("notes/linear-algebra.md", rendered)
        self.assertIn("Applied", self.output_json("concept", "show", "--id", "math:vectors")["evidence"][0]["summary"])
        self.assertTrue(self.output_json("card-source", "check", "--lesson", "linear-algebra")["ok"])
        self.assertTrue(self.output_json("validate")["ok"])

        self.run_cli(
            "evidence",
            "record",
            "--lesson",
            "linear-algebra",
            "--concept",
            "math:vectors",
            "--kind",
            "application",
            "--outcome",
            "fail",
            "--reasoning-quality",
            "weak",
            "--summary",
            "Could no longer apply vector addition reliably",
        )
        self.assertTrue(self.output_json("validate")["ok"])
        recheck = self.run_cli("card-source", "check", "--lesson", "linear-algebra", check=False)
        self.assertNotEqual(recheck.returncode, 0)
        self.assertEqual(json.loads(recheck.stdout)["conceptsNeedingRedemonstration"], ["math:vectors"])

    def test_changing_card_source_must_be_fresh(self) -> None:
        self.ensure_concept()
        self.create_lesson()
        evidence_id = self.demonstrate()
        old = (datetime.now(timezone.utc) - timedelta(days=45)).isoformat().replace("+00:00", "Z")
        source = self.write_card_source(evidence_id, volatility="changing", verified_at=old)
        rejected = self.run_cli(
            "card-source",
            "save",
            "--lesson",
            "linear-algebra",
            "--source",
            str(source),
            "--max-age-days",
            "30",
            check=False,
        )
        self.assertNotEqual(rejected.returncode, 0)
        self.assertIn("reverified", rejected.stderr)
        lesson = self.output_json("lesson", "show", "--id", "linear-algebra")
        self.assertIsNone(lesson["cardSourceFile"])
        self.assertFalse((self.root / "lessons" / "linear-algebra" / "card-source.json").exists())

    def test_invalid_state_is_reported_and_not_overwritten(self) -> None:
        broken = "{ definitely not JSON\n"
        path = self.root / "concepts.json"
        path.write_text(broken, encoding="utf-8")

        validation = self.run_cli("validate", check=False)
        self.assertNotEqual(validation.returncode, 0)
        self.assertIn("Invalid JSON", validation.stdout)

        initialization = self.run_cli("init", check=False)
        self.assertNotEqual(initialization.returncode, 0)
        self.assertEqual(path.read_text(encoding="utf-8"), broken)

        (self.root / "profile.json").unlink()
        initialization = self.run_cli("init", check=False)
        self.assertNotEqual(initialization.returncode, 0)
        self.assertFalse((self.root / "profile.json").exists())
        self.assertEqual(path.read_text(encoding="utf-8"), broken)

    def test_nested_corruption_is_reported_without_traceback(self) -> None:
        path = self.root / "concepts.json"
        store = json.loads(path.read_text(encoding="utf-8"))
        store["concepts"]["bad:record"] = []
        path.write_text(json.dumps(store), encoding="utf-8")
        result = self.run_cli("validate", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("must be an object", result.stdout)
        self.assertNotIn("Traceback", result.stderr)

    def test_symlinked_lesson_directory_is_rejected(self) -> None:
        external = Path(self.temporary.name) / "external"
        external.mkdir()
        (self.root / "lessons" / "evil").symlink_to(external, target_is_directory=True)
        result = self.run_cli(
            "lesson",
            "create",
            "--id",
            "evil",
            "--title",
            "Unsafe",
            "--goal",
            "Must not escape the state root",
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((external / "state.json").exists())

    def test_pending_transaction_is_recovered_before_validation(self) -> None:
        profile_path = self.root / "profile.json"
        profile = json.loads(profile_path.read_text(encoding="utf-8"))
        profile["preferences"]["pace"] = "deliberate"
        journal = {
            "schemaVersion": 1,
            "writes": [
                {
                    "path": "profile.json",
                    "content": json.dumps(profile, indent=2, sort_keys=True) + "\n",
                }
            ],
        }
        (self.root / ".pending-transaction.json").write_text(json.dumps(journal), encoding="utf-8")
        self.assertTrue(self.output_json("validate")["ok"])
        self.assertFalse((self.root / ".pending-transaction.json").exists())
        restored = self.output_json("profile", "show")
        self.assertEqual(restored["preferences"]["pace"], "deliberate")

    def test_lesson_status_and_phase_remain_consistent(self) -> None:
        self.create_lesson()
        paused = self.output_json("lesson", "update", "--id", "linear-algebra", "--status", "paused")
        self.assertEqual((paused["status"], paused["phase"]), ("paused", "paused"))
        invalid_resume = self.run_cli(
            "lesson", "update", "--id", "linear-algebra", "--status", "active", check=False
        )
        self.assertNotEqual(invalid_resume.returncode, 0)
        resumed = self.output_json(
            "lesson", "update", "--id", "linear-algebra", "--status", "active", "--phase", "teach"
        )
        self.assertEqual((resumed["status"], resumed["phase"]), ("active", "teach"))

    def test_profile_values_are_parsed_as_json(self) -> None:
        result = self.output_json("profile", "set", "--key", "pace", "--value", '"slow"')
        self.assertEqual(result["value"], "slow")
        profile = self.output_json("profile", "show")
        self.assertEqual(profile["preferences"]["pace"], "slow")
        rejected = self.run_cli("profile", "set", "--key", "bad", "--value", "NaN", check=False)
        self.assertNotEqual(rejected.returncode, 0)
        unchanged = self.output_json("profile", "show")
        self.assertNotIn("bad", unchanged["preferences"])

    def test_generating_evidence_requires_assessed_reasoning(self) -> None:
        self.ensure_concept()
        self.create_lesson()
        result = self.run_cli(
            "evidence",
            "record",
            "--lesson",
            "linear-algebra",
            "--concept",
            "math:vectors",
            "--kind",
            "explanation",
            "--outcome",
            "pass",
            "--reasoning-quality",
            "not_applicable",
            "--summary",
            "Claimed an explanation without assessed reasoning",
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        concept = self.output_json("concept", "show", "--id", "math:vectors")
        self.assertEqual(concept["status"], "unassessed")


if __name__ == "__main__":
    unittest.main()
