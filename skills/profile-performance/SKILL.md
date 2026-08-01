---
name: profile-performance
description: Profile and benchmark Rust, C, Go, or Python programs to locate CPU, latency, allocation, memory, I/O, lock, and concurrency bottlenecks and verify optimizations. Use for slow code, regressions, throughput or tail-latency problems, excess memory, suspected unnecessary work, benchmark design, flame graphs, pprof, perf, Instruments, Callgrind, cProfile, tracemalloc, or before/after performance validation.
---

# Profile performance

Measure the real workload before changing code. Optimize a demonstrated constraint, preserve correctness, and prove the result against the same work.

## Measurement rules

- Define the outcome and primary metric first: latency (including percentile), throughput, CPU time, allocation count/bytes, peak or steady RSS, I/O, lock/block time, startup, or binary size.
- Use a representative input, request mix, data size, concurrency level, and runtime duration. Record why it represents production or the user scenario.
- Profile optimized/release builds with symbols. Debug-build profiles commonly identify costs that disappear under optimization.
- Establish a stable baseline before profiling. Warm up when the runtime, filesystem cache, JIT, branch predictor, or application cache requires it.
- Keep hardware, power mode, affinity, compiler/runtime version, feature flags, input, and background load consistent. Record relevant differences when control is impossible.
- Change one hypothesis at a time. Compare equal completed work, not merely equal wall-clock profile duration.
- Preserve an output digest, tests, counters, or another correctness oracle so faster wrong output cannot win.
- Treat profiler overhead and sampling error as part of the experiment. Do not collect interfering CPU, allocation, race, and tracing profiles simultaneously unless the tool documents that combination.
- Report raw numbers, repetitions, spread, and command lines. Do not call noise an improvement.

## Workflow

### 1. Frame the question

State the workload, target metric, current baseline, desired threshold, environment, and constraints. If the user only says “make it faster,” derive these from existing benchmarks, production telemetry, tests, or a minimal representative harness.

### 2. Classify the bottleneck

Use coarse measurements before a detailed profiler:

- CPU-bound: sustained CPU with useful work; inspect sampled stacks and hardware counters.
- Allocation/GC-bound: high allocation rate, collector time, allocator frames, or retained heap.
- I/O-bound: disk/network wait, excessive calls, tiny operations, serialization, or request amplification.
- Contention-bound: lock/block time, runnable queues, scheduling, or oversubscription.
- Memory-bound: cache misses, bandwidth, layout, copying, or working-set size.
- Latency-bound but idle: dependencies, timers, queues, backpressure, or sequential round trips.

Check system ceilings before optimizing application code: CPU quota/frequency, memory pressure, disk, network, database, remote API, and rate limits.

### 3. Collect the least intrusive useful profile

Read [tooling.md](references/tooling.md) and load only the section for the active language/platform. Prefer a sampling profiler for CPU investigation, an allocation/heap profiler for memory, and runtime-native block/trace tools for concurrency.

Save profiles outside tracked source when possible. Never expose an unauthenticated production profiling endpoint, embed secrets in commands, or commit large profile artifacts unless explicitly requested.

### 4. Interpret evidence

- Inspect both **flat/self** cost and **cumulative/inclusive** cost. A dispatcher may have high cumulative cost but little removable self work.
- Follow the hottest complete call paths and quantify their share of the target metric.
- Separate frequency from cost per call. Count allocations, bytes, syscalls, queries, and iterations where possible.
- Look for repeated work, conversions, copies, parsing, formatting, collection growth, cache misses, lock scope, and fan-out that explain the profile.
- Confirm the suspected line or function under a representative input; do not optimize a symbol merely because it appears in a profile.

### 5. Test the smallest hypothesis

Predict the expected change before editing, for example: “removing one allocation per row should remove about N allocations and reduce allocator CPU.” Make the narrowest change that tests the prediction. Add a focused benchmark only when existing end-to-end measurement cannot isolate the hypothesis.

### 6. Compare and guard

Repeat the baseline and candidate interleaved when practical. Compare primary and guardrail metrics, correctness output, and resource tradeoffs. Re-profile the winner because bottlenecks move. Run functional tests and the repository's standard checks before recommending adoption.

Revert or reject changes that do not beat noise, only shift cost to an unacceptable metric, or add disproportionate complexity.

## Deliverable

Report:

1. workload and environment;
2. exact baseline/profile commands;
3. baseline measurements with repetitions/spread;
4. dominant call paths or resource constraint with evidence;
5. hypothesis and change, if authorized;
6. before/after result and percent/absolute delta;
7. correctness and regression checks;
8. limitations, profiler overhead, and next bottleneck.

Clearly label observations, inferences, and untested recommendations.

