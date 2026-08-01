---
name: review-systems-code
description: Review Rust, C, Go, and other systems-oriented code for correctness, resource safety, concurrency behavior, simplicity, idiomatic design, and high performance. Use for diffs, pull requests, unsafe or FFI code, hot paths, services, parsers, data structures, and code where allocations, copies, syscalls, contention, or unnecessary work matter.
---

# Review systems code

Review observable behavior and resource costs before style. Do not edit unless the user asks for fixes.

## Build the execution model

1. Read repository instructions and determine the exact review range.
2. Trace ownership, lifetimes, mutation, blocking points, cleanup, error propagation, and concurrency across function boundaries.
3. Identify trusted and untrusted inputs, platform/ABI assumptions, hot paths, and workload scale.
4. Inspect callers and tests; do not infer a contract from the changed function alone.
5. Distinguish a demonstrated defect from a possible optimization that needs measurement.

## Correctness gate

Check these before performance:

- Arithmetic: overflow, underflow, truncation, signedness, unit mismatch, divide-by-zero, lossy casts, and size calculations.
- Memory: bounds, initialization, aliasing, alignment, object lifetime, ownership transfer, use-after-free, leaks, invalidation, and overlapping copies.
- Control flow: incomplete error handling, partial reads/writes, short buffers, EOF, interrupted operations, cancellation, timeout, retry duplication, and cleanup on every exit.
- Concurrency: data races, lock ordering, atomic memory ordering, missed wakeups, goroutine/thread lifetime, channel closure, cancellation propagation, backpressure, and shutdown.
- Interfaces: ABI/layout, FFI safety, pointer validity, callback lifetime, panic/unwind boundaries, endianness, and platform-width assumptions.
- State and persistence: crash consistency, transaction boundaries, idempotency, cache coherence, stale data, and failure after partial progress.
- Tests: concrete boundary and regression cases, concurrency/race coverage, sanitizer coverage, and assertions that verify results rather than only successful execution.

Treat `unsafe`, atomics, lock-free code, custom allocation, and manual buffer arithmetic as proof obligations. Require the invariant to be explicit and verify every caller satisfies it.

## Performance gate

Start with workload scale and algorithmic complexity. Then count avoidable work on the hot path:

- repeated traversal, sorting, hashing, parsing, formatting, serialization, or validation;
- heap allocations, growth reallocations, temporary collections, cloning, copying, ownership conversion, and boxing;
- poor locality, pointer chasing, oversized objects, false sharing, cache-unfriendly layout, and retained capacity;
- excessive syscalls, tiny I/O, redundant reads, flushes, network round trips, and database queries;
- lock scope, contention, atomics, task/thread creation, oversubscription, context switches, and unbounded queues;
- eager initialization, recomputation of invariants, duplicated caches, and work whose result is discarded;
- branch-heavy inner loops, missed batching/vectorization, and abstraction costs that survive optimization.

Do not assert that code is slow from appearance alone. Explain the cost model, identify the scale at which it matters, and request or run a representative benchmark/profile for non-obvious cases. Reject an optimization that obscures invariants without measured value.

## Apply language idioms

### Rust

- Prefer borrowing over ownership conversion when it stays simple; scrutinize hot `clone`, `to_owned`, `to_string`, `collect`, `format!`, and temporary `Vec` use.
- Preallocate only when a useful size estimate exists. Check iterator passes, enum/type size, reference counting, mutex choice, and accidental long-lived borrows.
- Verify `Send`/`Sync`, pinning, cancellation, drop order, panic behavior, and every `unsafe` safety contract.
- Run project checks plus `cargo clippy`; use `clippy::perf`, `correctness`, `suspicious`, and `complexity` as signals, not substitutes for review.

### C

- Make allocation size, ownership, buffer length, NUL termination, and cleanup conventions explicit.
- Scrutinize signed overflow, integer promotions/conversions, pointer arithmetic, aliasing, alignment, uninitialized padding/data, and undefined behavior.
- Check return values and partial I/O. Keep one auditable cleanup strategy and avoid hidden ownership transfer.
- Prefer clear portable code; require compiler output or measurements before `restrict`, forced inlining, hand vectorization, or architecture-specific paths.
- Use strong warnings and targeted ASan/UBSan/TSan or Valgrind runs when the build supports them.

### Go

- Propagate `context.Context`; make goroutine exit and channel ownership obvious; prefer synchronous APIs when callers can add concurrency.
- Handle every meaningful error. Preserve nil-versus-empty behavior when serialized or part of an API.
- Keep interfaces at the consumer and avoid premature interfaces, reflection, unnecessary goroutines, and synchronization.
- Inspect slice/map capacity, string/byte conversions, formatting, escape-to-heap, retained backing arrays, per-request allocations, and lock/block profiles.
- Use `gofmt`, tests (including `-race` where appropriate), benchmarks with `-benchmem`, compiler escape diagnostics, and pprof when evidence is needed.

## Seek simplification

Prefer removal over addition when behavior stays correct:

- eliminate redundant state, passes, conversions, abstractions, caching, concurrency, and dependencies;
- narrow types and APIs so invalid states are harder to express;
- shorten ownership and lock lifetimes;
- replace clever fast paths with standard-library operations when they are at least as clear and measurements do not regress;
- avoid speculative extensibility and single-use generic layers.

Do not request broad refactors unrelated to the change.

## Report

List findings by severity. Each finding must name a precise location, violated invariant, realistic trigger, concrete impact, and smallest fix. Label performance findings as measured or inferred and provide the cost model or measurements. Then state validation gaps. If no defect is found, say so without inventing nits.

## Research basis

- [Google Engineering Practices: code review](https://google.github.io/eng-practices/review/)
- [Rust Clippy lint categories](https://doc.rust-lang.org/stable/clippy/index.html)
- [Rust Performance Book](https://nnethercote.github.io/perf-book/)
- [Go code review comments](https://go.dev/wiki/CodeReviewComments)
- [Clang sanitizers](https://clang.llvm.org/docs/)
- [SEI CERT C Coding Standard](https://wiki.sei.cmu.edu/confluence/display/c)

