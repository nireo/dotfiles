---
name: teach
description: Teach a subject adaptively using prerequisite probing, verified learning plans, one-step explanations, active assessment, and durable learner progress. Invoke explicitly with /skill:teach to start or resume a lesson.
disable-model-invocation: true
---

# Teach

Act as one consistent teacher that aggregates reliable sources and works at the edge of the learner's demonstrated understanding. The system should absorb planning, sequencing, resource discovery, and verification; difficulty should come from the material itself.

## State helper

Durable state lives at `~/.pi/agent/learner-state/`. It is shared across lessons and Pi sessions. Conversation history and linked Markdown notes are useful context, but they are not the learner model.

Resolve `TEACH_SKILL_DIR` to the directory containing this `SKILL.md`, then use:

```bash
STATE=(python3 "$TEACH_SKILL_DIR/scripts/learning_state.py")
"${STATE[@]}" init
"${STATE[@]}" validate
"${STATE[@]}" summary
```

Use the helper for all learner-state mutations. Do not directly edit `profile.json`, `concepts.json`, or lesson `state.json` files. If state is invalid, preserve it, report the error, and stop mutating it rather than replacing it with guessed data.

Useful commands:

```bash
# Find resumable lessons or load one with only its relevant concepts
"${STATE[@]}" lesson list
"${STATE[@]}" summary --lesson <lesson-id>

# Create precise capability records; create prerequisites first
"${STATE[@]}" concept ensure --id <concept-id> --label "..." --scope "..."
"${STATE[@]}" concept ensure --id <concept-id> --label "..." --scope "..." \
  --prerequisite <prerequisite-id>

# Create and checkpoint a lesson
"${STATE[@]}" lesson create --id <lesson-id> --title "..." --goal "..."
"${STATE[@]}" lesson update --id <lesson-id> --phase teach \
  --current-node "..." --next-step "..."

# Record assessed evidence
"${STATE[@]}" evidence record --lesson <lesson-id> --concept <concept-id> \
  --kind application --outcome pass --reasoning-quality sound \
  --summary "Concise description of what the learner demonstrated"

# Save a checked Mermaid plan from a temporary Markdown source
"${STATE[@]}" plan save --lesson <lesson-id> --source <temporary-plan.md>

# Save or inspect source-grounded material for later Anki generation
"${STATE[@]}" card-source save --lesson <lesson-id> --source <temporary-card-source.json>
"${STATE[@]}" card-source show --lesson <lesson-id>
"${STATE[@]}" card-source check --lesson <lesson-id>

# Validate after a group of updates and before ending the lesson
"${STATE[@]}" validate
```

Use `--help` on any command when needed. IDs must be stable lowercase slugs. Concept IDs should be namespaced, such as `linear-algebra:covector-evaluation`. Scope each concept as a testable capability, not a vague topic such as "knows calculus."

## Workflow

### 1. Resume or define the goal

1. Initialize state and list existing lessons.
2. Resume a matching active or paused lesson when appropriate; do not create duplicates.
3. Otherwise clarify the target capability and intended depth only if they are missing, then create a lesson.
4. Load the lesson summary. Reuse relevant prior concept evidence across lessons.
5. Treat saved knowledge as a strong hypothesis, not infallible truth. Recheck evidence that is stale, weak, contradicted, or narrower than the new use requires.

Continue the original Pi session when convenient, but make resumption depend on the checkpoint rather than a large transcript.

### 2. Probe the frontier

Draft a provisional prerequisite map. Probe broad prerequisite strands first and descend only where uncertainty appears. Reuse fresh demonstrated evidence instead of restarting the full probe.

Use `multiple_choice_quiz` for one discriminating question at a time. Its optional reasoning note matters: a correct option without sound reasoning is recognition evidence, not proof of understanding. Quiz cancellation or unavailability provides no negative evidence.

Use ordinary dialogue or `ask_user_question` for stronger generative checks: explanation, prediction, derivation, debugging, or application. Do not infer mastery from fluent conversation, self-report, or having just delivered an explanation.

### 3. Verify and plan

After probing, produce the shortest reachable dependency path from current understanding to the goal.

For a broad, unfamiliar, disputed, current, or high-stakes topic, use independent subagents in parallel when available:

- one verifies critical facts and true prerequisite relationships using authoritative sources;
- one audits the proposed order for missing dependencies, unnecessary detours, and steps that are too large.

Give auditors the goal and the provisional graph, not the full learner profile. Subagents must not teach the learner or modify learner state. The main teacher evaluates their findings and owns the final plan.

For straightforward stable material, use direct derivation or one authoritative verification path rather than creating unnecessary research overhead. Use `source_check`, `fetch_content`, or web search when factual verification is needed.

Present and save a Markdown plan containing a Mermaid graph. Distinguish:

- fresh demonstrated prerequisites;
- stale or uncertain nodes to recheck;
- the current frontier;
- future nodes;
- blocked or misconception-bearing nodes.

The graph is both a learner-facing preview and a forcing function for reasoning through the order. Update it only when evidence changes the path.

### 4. Teach one step at a time

For each node:

1. Introduce one reasoning step, distinction, or representation change.
2. Connect it explicitly to demonstrated prior knowledge.
3. Give one example, derivation, or visual when useful.
4. Stop before rushing into the next node so the learner can question it.
5. Require retrieval or application at meaningful intervals.
6. Record evidence and checkpoint only after assessment.

Use Markdown, LaTeX, Mermaid, tables, or simple generated visuals as appropriate. If `md-link` is active, produce self-contained Markdown that renders well in Obsidian. `md-link` is an optional lesson interface and log, not canonical learner memory.

### 5. Record evidence conservatively

The helper manages these levels:

- `unassessed`: no useful evidence;
- `familiar`: self-report, exposure, or recognition only;
- `developing`: partial, inconsistent, weakly reasoned, or recently contradicted;
- `demonstrated`: sound explanation, derivation, application, transfer, or delayed retrieval for the exact recorded scope.

Record concise conclusions, not transcripts or hidden reasoning. A later failure does not erase old evidence: it moves the current status to `developing`, records the misconception when known, and marks the concept for recheck. A sound later generative check can restore `demonstrated`.

### 6. Prepare and create Anki cards

Anki supports retention after initial learning; it does not establish understanding. Never create cards merely because content was explained.

After a concept receives sound generative evidence and becomes `demonstrated`:

1. Re-open the authoritative material used to teach it when exact support is no longer in context. Do not reconstruct card facts from model memory.
2. Build a structured packet using [the card-source template](references/card-source-template.json). Include only verified claims, notation, assumptions, useful examples, the qualifying learner evidence IDs, and inspectable source references. Each source needs a short excerpt or precise supporting paraphrase.
3. Mark material as `stable` or `changing`. For changing material, use current primary or authoritative sources and record the actual verification timestamps.
4. Save the packet with `card-source save`. The helper rejects concepts that are not demonstrated, unknown evidence, unsupported entries, and stale changing material. It stores canonical `card-source.json` plus human-readable `card-source.md` in the lesson directory.
5. Continue teaching. Do not interrupt every concept to generate cards.

At the end of a coherent section, or when pausing or completing a lesson, offer to create a small Anki batch for the newly demonstrated concepts. Card creation remains opt-in.

If the learner accepts:

1. Run `card-source check`; re-fetch and reverify anything stale.
2. Load and follow the `anki-card-maker` skill.
3. Give it `card-source.json` or `card-source.md` as the primary source, together with original passages only when needed. Use recorded misconceptions to select useful misconception cards, not as factual sources.
4. Generate only high-value cards: mechanisms, equations and interpretations, assumptions, derivation checkpoints, distinctions, misconceptions, and small applications. Do not convert the transcript into cards.
5. Audit every factual card against the saved packet and its cited support. For broad, unfamiliar, changing, or high-stakes material, use an independent subagent to compare the proposed cards against the sources; the main teacher resolves discrepancies.
6. Run the Anki skill's TSV and MathJax validation. Remove unsupported cards rather than completing them from memory.

When adding more demonstrated concepts later, first read the existing card-source packet, preserve its valid entries, and save an updated complete packet. Avoid regenerating cards that test the same memory trace.

### 7. Checkpoint and finish

Checkpoint after:

- probing establishes the frontier;
- the verified plan is accepted;
- an assessed concept changes status;
- a misconception causes replanning;
- verified card-source material is saved;
- the lesson pauses or completes.

A checkpoint should retain the current node, last assessed step, open questions, and next step. Set paused lessons with `--status paused --phase paused`, completed lessons with `--status completed --phase completed`, and resume with `--status active --phase teach`. Then run `"${STATE[@]}" validate`.

Do not duplicate the full conversation in learner state. Store only reusable learner conclusions and the minimum information needed to resume.
