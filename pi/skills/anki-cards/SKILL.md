---
name: anki-card-maker
description: Create, inspect, update, move, and delete Anki decks and flashcards through the safe ankiedit CLI. Use when the user asks to manage Anki cards, decks, study cards, or spaced-repetition material, including cards derived from notes, PDFs, lessons, transcripts, slides, code, mathematics, or technical sources.
---

# Anki Collection Manager

Use the globally installed `ankiedit` command for all Anki collection work. It is the only supported collection interface for this skill.

Do not edit `collection.anki2` with SQLite, invoke Anki's Python library directly, copy the live collection, or assemble ad hoc import scripts. `ankiedit` owns profile discovery, offline checks, locking, backups, note/card bookkeeping, and pre/post integrity verification.

## Operational contract

- Anki Desktop must be fully closed. If `ankiedit` reports an unsafe collection state, stop and ask the user to close Anki; never bypass the check.
- Confirm the command is available with `command -v ankiedit` when first needed. If it is missing, report that installation is required instead of falling back to direct database access.
- Let `ankiedit` select the collection when there is exactly one profile. Use `--profile NAME` when multiple profiles exist. Use `--collection PATH` only when the user explicitly provides a nonstandard collection.
- Read operations are safe to run when needed. Mutations still require the user's intent; do not infer permission to create, edit, move, or delete unrelated material.
- Every mutation performs its own safety checks and returns `safety.before` and `safety.after`. Treat any non-`ok` quick or integrity check as a hard stop.
- For destructive operations, always run `--dry-run` first and compare the exact deck/note/card IDs and counts. Use `--confirm` only when the preview matches the user's requested target.
- Use JSON files or stdin for structured input. Do not encode complex fields as shell arguments.

## Anki's content model

Anki stores editable content in **notes**. A note type's templates generate one or more **cards** from a note.

- Create or edit content with `notes create` and `notes update`.
- A reversed or Cloze note can generate multiple cards; report all returned card IDs.
- `notes delete` removes a note and every card generated from it.
- `cards delete` removes only a selected generated card and is rarely the right content-deletion operation.
- Moving a note during `notes update` moves all of its generated cards. `cards move` targets individual cards.

## Workflow

1. Ground card content in the user's source material. When invoked from the `teach` skill, use its validated `card-source.json` or `card-source.md` as the primary claim set.
2. Inspect existing targets before deciding anything:

   ```sh
   ankiedit decks list --pretty
   ankiedit note-types list --pretty
   ```

3. If the target deck is not explicit and cannot be safely inferred, ask for it. Never silently put cards in `Default`.
4. Search before creating when duplicates are plausible:

   ```sh
   ankiedit notes search --query 'deck:"Deck Name" tag:topic' --limit 100 --pretty
   ```

5. Draft structured JSON using the exact field names returned by `note-types list`.
6. Apply the quality filter below. Prefer a smaller, high-value batch.
7. Preview the mutation with `--dry-run`; inspect resolved deck, note type, rendered HTML, and affected IDs.
8. Execute the same payload. Batch creation and every destructive operation require `--confirm`.
9. Check that the response has `ok: true`, the expected counts/IDs, `backup_created: true` for a real write, and `ok` pre/post safety checks. Report the outcome concisely.

## Command reference

```sh
# Health and discovery
ankiedit doctor --pretty
ankiedit profiles list --pretty
ankiedit decks list --pretty
ankiedit note-types list --pretty

# Read
ankiedit notes search --query 'deck:"Biology"' --limit 50 --pretty
ankiedit notes get --note-id 123 --pretty
ankiedit notes get --card-id 456 --pretty
ankiedit cards search --query 'tag:review' --limit 50 --pretty
ankiedit cards get --card-id 456 --pretty

# Mutate using JSON
ankiedit decks create --input deck.json --dry-run --pretty
ankiedit decks create --input deck.json --pretty
ankiedit notes create --input notes.json --dry-run --pretty
ankiedit notes create --input notes.json --confirm --pretty
ankiedit notes update --input updates.json --dry-run --pretty
ankiedit notes update --input updates.json --confirm --pretty
ankiedit cards move --input move.json --dry-run --pretty
ankiedit cards move --input move.json --confirm --pretty
ankiedit notes delete --input notes.json --dry-run --pretty
ankiedit notes delete --input notes.json --confirm --pretty
ankiedit decks delete --input deck.json --dry-run --pretty
ankiedit decks delete --input deck.json --confirm --pretty
```

## Payloads

### Create a deck

Deck creation is idempotent. Nested names use Anki's `Parent::Child` syntax.

```json
{"name": "Biology::Cell Biology"}
```

### Create notes

Input may be one object or an array. Markdown is the default field format.

```json
[
  {
    "deck": "Biology::Cell Biology",
    "note_type": "Basic",
    "format": "markdown",
    "fields": {
      "Front": "What is the main function of the **mitochondrion**?",
      "Back": "It produces ATP through cellular respiration."
    },
    "tags": ["biology", "cell_biology"]
  },
  {
    "deck": "Biology::Cell Biology",
    "note_type": "Cloze",
    "format": "markdown",
    "fields": {
      "Text": "The {{c1::mitochondrion}} produces {{c2::ATP}}.",
      "Back Extra": "Two cloze numbers generate two cards."
    },
    "tags": ["biology", "cell_biology", "cloze"]
  }
]
```

### Update a note

Updates are partial: omitted fields and tags remain unchanged. Identify the note with exactly one `note_id` or `card_id`.

```json
{
  "note_id": 123,
  "format": "markdown",
  "fields": {"Back": "Updated answer with inline math: $E=mc^2$."},
  "tags": {"add": ["checked"], "remove": ["draft"]},
  "deck": "Physics"
}
```

### Move cards

```json
{"card_ids": [456, 457], "deck": "Physics"}
```

### Delete notes or a deck

```json
[{"note_id": 123}, {"card_id": 456}]
```

```json
{"name": "Temporary Deck"}
```

Deck deletion removes that deck's notes and cards. It refuses `Default` and refuses a parent with child decks until the children are explicitly handled.

## Formatting

Use Markdown for authoring and let `ankiedit` convert it to sanitized Anki HTML.

- `**bold**`, `*italic*`, `~~strikethrough~~`
- headings, paragraphs, lists, blockquotes, links, tables, and inline code
- safe inline HTML for `<u>`, `<sub>`, `<sup>`, colors, and alignment
- `$...$` for inline MathJax and `$$...$$` for display MathJax
- `{{c1::answer}}` and `{{c1::answer::hint}}` for Cloze notes

Use `"format": "html"` only when native HTML is materially easier. Media import is not supported; do not invent file or URL attachment workflows.

## Card quality filter

The objective is durable recall and useful understanding, not maximum card count.

- **Source fidelity:** Ground factual cards in supplied material. Do not silently encode ambiguous, stale, or unsupported claims.
- **Atomicity:** Test one main mental operation per card. Split long explanations and derivations into retrievable checkpoints.
- **Specificity:** Make the target clear and independently understandable weeks later.
- **Minimum information:** Keep answers concise while retaining the mechanism or qualification that makes them correct.
- **Recall over recognition:** Prefer free recall to multiple choice.
- **Mechanism over wording:** Test why/how, assumptions, implications, and failure modes when those matter.
- **Gradeability:** The learner must be able to tell whether the recalled answer is correct.
- **No answer leakage:** Do not reveal most of the answer in the prompt unless required mathematical context makes it unavoidable.
- **No low-value redundancy:** Multiple cards about one concept should test genuinely different dimensions.
- **Useful difficulty:** Preserve meaningful reconstruction and reasoning; do not turn technical material into trivia.

For important technical or mathematical concepts, consider a small orthogonal cluster drawn from:

- definition,
- mechanism,
- equation reconstruction,
- term interpretation,
- assumptions,
- derivation checkpoint,
- shape or dimensionality,
- small application,
- implementation consequence,
- failure mode or misconception.

Use only the dimensions that improve learning. Usually 2–5 strong cards are better than one oversized card or a repetitive batch.

## Explicit TSV export mode

`ankiedit` is the default. Only produce an importable Front/Back TSV when the user explicitly requests a TSV file instead of live collection changes. In that case, use HTML fields with Anki MathJax delimiters, keep exactly one physical row and one tab per card, and run:

```sh
node scripts/validate_tsv.cjs <temporary-file>
```

Fix every validation error before delivering the file. Do not import it automatically.

## Flashcard quality examples

Use these examples as patterns, not as unsupported source material. A good rewrite should preserve the source's actual scope and terminology.

### One testable idea instead of a list

**Bad**

- Front: What is TCP?
- Back: TCP is connection-oriented, reliable, ordered, uses acknowledgements, retransmits packets, performs flow and congestion control, and has a three-way handshake.

This tests too many facts at once, so partial recall is hard to grade. Split it into distinct cards, such as:

**Good**

- Front: What property of TCP ensures an application receives bytes in sequence?
- Back: TCP provides an ordered byte stream by sequencing data and reassembling it in order.

**Good**

- Front: How does TCP recover from data it infers was lost?
- Back: It retransmits the missing data, based on signals such as timeouts or duplicate acknowledgements.

### Specific prompt instead of vague context

**Bad**

- Front: What does it do?
- Back: It produces ATP.

The prompt will not be understandable after it is separated from the original lesson.

**Good**

- Front: What is the mitochondrion's main role in aerobic cellular respiration?
- Back: It produces most of the cell's ATP through oxidative phosphorylation.

### Free recall instead of recognition

**Bad**

- Front: Which structure produces most cellular ATP: the nucleus, Golgi apparatus, or mitochondrion?
- Back: The mitochondrion.

The alternatives make the answer easier to recognize than to recall.

**Good**

- Front: Which organelle produces most ATP in a eukaryotic cell during aerobic respiration?
- Back: The mitochondrion.

### Mechanism instead of a label alone

**Bad**

- Front: What is a hash table's average lookup complexity?
- Back: $O(1)$.

This can encourage memorizing a slogan without its conditions.

**Good**

- Front: Why can a hash table provide $O(1)$ average-case lookup?
- Back: A hash function maps a key directly to a bucket; with a suitable hash function and controlled load factor, only a constant expected number of entries must be checked.

### Gradeable answer instead of an open-ended dump

**Bad**

- Front: Explain photosynthesis.
- Back: A long paragraph covering light reactions, the Calvin cycle, chloroplast anatomy, and ecological importance.

There is no clear boundary for a complete answer.

**Good**

- Front: What immediate products of the light-dependent reactions are used by the Calvin cycle?
- Back: ATP and NADPH.

### No answer leakage

**Bad**

- Front: In which organelle does mitochondrial oxidative phosphorylation occur?
- Back: The mitochondrion.

The wording reveals the answer.

**Good**

- Front: In which organelle does oxidative phosphorylation occur in eukaryotic cells?
- Back: The mitochondrion, specifically its inner membrane.

### Focused cloze deletion

**Bad**

- Text: {{c1::TCP is a connection-oriented transport protocol that provides reliable, ordered delivery with flow control and congestion control.}}

Deleting the whole sentence tests verbatim recitation rather than a precise relationship.

**Good**

- Text: TCP flow control prevents a sender from overwhelming the {{c1::receiver}}, whereas congestion control prevents it from overwhelming the {{c2::network}}.

Each deletion tests a distinct contrast. If the two deletions are not independently useful, use separate notes instead.

### Meaningful application instead of trivia

**Bad**

- Front: In what year was Dijkstra's shortest-path algorithm published?
- Back: 1959.

Unless the date serves a learning goal, it does not improve understanding or application.

**Good**

- Front: Why does standard Dijkstra's algorithm not handle negative edge weights correctly?
- Back: It assumes that once the lowest-distance unvisited node is finalized, no later path can make it cheaper; a negative edge can violate that assumption.
