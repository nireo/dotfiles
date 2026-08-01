---
name: review-wlho-model
description: Review diffs, branches, pull requests, or working-tree changes in the wlho-model repository. Use for correctness-first reviews across its Python model/data pipeline, Go API, Astro site and Cloudflare worker, and Rust/Tauri overlay, with special emphasis on keeping site changes lightweight, efficient, measurable, and simple.
---

# Review wlho-model

Review for defects and regressions, not stylistic preference. Do not modify code unless the user explicitly asks for fixes.

## Establish the change

1. Read the root `AGENTS.md` and every nearer `AGENTS.md` governing touched files.
2. Inspect `git status`, the complete diff, and enough surrounding code to understand runtime behavior. For a branch review, identify the intended base and use the merge-base diff.
3. Trace changed values through callers, consumers, schemas, generated artifacts, cache boundaries, and tests. A diff-only reading is insufficient.
4. Separate pre-existing problems from regressions introduced by the change.
5. Identify the affected subsystem before choosing checks or commands.

## Review in priority order

### 1. Correctness and safety

Check the actual requirements and invariants first:

- Validate behavior for normal, boundary, empty, malformed, partial, timeout, cancellation, retry, and shutdown paths.
- Check schema and contract changes end to end: producers, storage, readers, API payloads, client types, generated data, migrations, tests, and documentation.
- Look for stale state, races, duplicate work, lost cancellation, leaked resources, unbounded inputs or queues, unsafe cache keys, and incorrect error/status semantics.
- Check security boundaries involving auth, cookies, redirects, CSRF, trusted proxies, secrets, external HTML, SQL, filesystem paths, and outbound requests.
- Treat a passing test suite as evidence, not proof. Identify missing regression tests for a concrete failure mode.

Apply repository-specific invariants:

- **Model and typed data:** preserve game-level split isolation, canonical typed schemas, side-mirroring semantics, feature ordering, artifact compatibility, and probability calibration. Reject accuracy claims based on a single seed or a mismatched split/data source. For real model comparisons, expect seeds 42/43/44 and relevant BCE, Brier, ECE, time-bin, and mirror-consistency results.
- **Go server:** preserve request contexts and deadlines, bounded Riot/database work, goroutine ownership, graceful shutdown, HTTP body limits, transactional migrations, and parameterized sqlc queries. Never edit generated `db/sqlc` code as the source of a database change.
- **Astro site and worker:** preserve base-path URLs, prerender/runtime intent, cache and `no-store` semantics, auth boundaries, same-origin checks, input narrowing, semantic HTML, keyboard access, metadata, and no unsanitized HTML insertion.
- **Tauri overlay:** preserve Windows/macOS platform parity, Tauri command contracts, window/click-through behavior, CSP constraints, event cleanup, and the split TypeScript build lanes.

### 2. Lightweight site and runtime performance

Treat every byte, parse, node, request, and runtime initialization on a user path as work that needs a reason.

- Preserve Astro's HTML-first behavior. Do not add hydration or a client framework where a small Astro component or focused browser script suffices.
- Prefer prerendered, cacheable static assets for immutable public data. Do not route them through Astro, Go, PostgreSQL, or the Worker without a dynamic requirement.
- Flag broad imports that pull large JSON or unrelated data into server chunks, especially shared layouts and dynamic routes.
- Look for repeated parsing, serialization, sorting, filtering, aggregation, database/Riot calls, full-page fetches used as fragments, and duplicate data in HTML plus JSON.
- Avoid rendering hidden tabs, collapsed details, offscreen rows, tooltips, or images before they are needed. Preserve useful initial HTML and no-JavaScript fallbacks.
- Avoid eager images, late-discovered hero assets, missing intrinsic dimensions, oversized decoded images, global CSS growth, route-independent scripts, and unused JavaScript.
- Check cacheability and cache keys at browser, Cloudflare, Astro, Go, and database layers. Never trade correctness, privacy, or freshness for a superficial cache hit.
- For Go/Python/Rust hot paths, inspect asymptotic work, allocations, copies, conversions, serialization, syscalls, locks, fan-out, queue growth, and peak memory.

Require evidence for performance conclusions. Select metrics that match the suspected regression:

- Site: raw and compressed HTML/JSON/JS/CSS bytes, DOM and image counts, transferred and decoded image bytes, route chunk size, LCP/INP/CLS, request count, and interaction delay.
- Services: latency distribution, throughput, request amplification, database calls, CPU, allocations, RSS, lock/block time, and concurrency ceilings.
- Builds/model jobs: wall time, peak RSS, input rows, output equivalence, and repeated-run variance.

Use existing baselines in `server/site/docs/performance-*.md` when relevant. Do not demand new infrastructure or a benchmark for cold code with no plausible material cost; state uncertainty instead.

### 3. Simplification

Look for a smaller correct design:

- Remove new layers, state, branches, caches, conversions, abstractions, or dependencies that do not earn their cost.
- Prefer explicit client payloads over broad object spreading and narrow modules over convenience imports with heavy side effects.
- Prefer one clear pass over repeated traversals when it remains readable; avoid fusing unrelated work merely to reduce line count.
- Reuse an established project primitive when it makes ownership and behavior clearer.
- Reject speculative generality, duplicated representations, unnecessary concurrency, and wrappers used only once.
- Keep simplification suggestions inside the changed scope unless an adjacent issue is required to fix the defect.

## Validate proportionally

Use focused checks first, then the subsystem's required gate when practical:

- Model/Python: `uv run ruff check .`, focused `uv run pytest ...`, then `uv run pytest`.
- Go server: `make lint`, `make test`, `make build`; note when Docker-dependent integration tests could not run.
- Astro site: focused Vitest where useful, then `pnpm run validate` for site changes.
- Overlay: `npm run typecheck`, `npm test`, `npm run build`; use `cargo check` and `cargo clippy` for native changes.

Do not run costly training, destructive database resets, deployment commands, or production profiling without explicit scope and authority.

## Report findings

Lead with findings ordered by severity. For each finding include:

- severity (`P0` critical through `P3` low);
- a precise file and line;
- the violated invariant and concrete impact;
- the input, sequence, or runtime condition that exposes it;
- the smallest credible correction;
- supporting test or measurement evidence, distinguishing observed facts from inference.

After findings, list unresolved assumptions and validation gaps briefly. If no actionable defect is found, say so and name the remaining test or performance risks. Omit praise, diff summaries, and style nits unless the user asks for them.

## Research basis

- [Google Engineering Practices: what reviewers look for](https://google.github.io/eng-practices/review/)
- [Astro islands: send client JavaScript only for explicit interactivity](https://docs.astro.build/en/concepts/islands/)
- [Core Web Vitals and field/lab measurement](https://web.dev/articles/vitals)
- [Chrome Lighthouse performance audits](https://developer.chrome.com/docs/lighthouse/)

