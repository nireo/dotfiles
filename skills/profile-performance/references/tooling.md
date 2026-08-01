# Profiling tooling by language

Read only the relevant language and host sections. Adapt commands to the repository's package, binary, benchmark, interpreter, and build system. Prefer existing project tooling over adding a dependency.

## Host-level first pass

### Linux

Use `perf stat` for coarse counters and `perf record` for sampled stacks:

```bash
perf stat -r 5 -- <command>
perf record -g --call-graph dwarf -- <command>
perf report
```

Use `perf stat` counters comparatively; raw cache/branch metrics vary across machines. Use frame pointers where DWARF unwinding is too costly or incomplete.

Use `/usr/bin/time -v <command>` for wall time, CPU, faults, and peak RSS. Use `strace -c` only when syscall shape is relevant; tracing changes timing.

### macOS

Use `/usr/bin/time -l <command>` for coarse resource use. Use Instruments' Time Profiler, Allocations, Leaks, and System Trace templates for CPU, memory, and concurrency. List available command-line templates with:

```bash
xcrun xctrace list templates
```

Use `sample <pid> <seconds>` for a quick stack sample when Instruments is unnecessary.

## Rust

Build and benchmark optimized code:

```bash
cargo build --release
cargo bench
cargo clippy --all-targets
```

For clearer sampled stacks, temporarily build with symbols and frame pointers without changing shipped defaults unless the project wants them:

```bash
RUSTFLAGS="-C force-frame-pointers=yes -C debuginfo=1" cargo build --release
perf record -g --call-graph fp -- target/release/<binary> <args>
perf report
```

Use `cargo flamegraph`, `samply`, or Instruments when already available. Use DHAT, heaptrack, or bytehound for allocation questions and Callgrind/Cachegrind for instruction/cache questions; these tools add substantial overhead, so do not compare their wall time to native runs.

Inspect allocation-causing `clone`, `to_owned`, `format!`, `collect`, temporary collections, vector growth, hash tables, reference counting, and string conversion only after the profile identifies the path. Preallocation and alternative containers can lose on small or different workloads.

Useful references:

- [Rust Performance Book: profiling](https://nnethercote.github.io/perf-book/profiling.html)
- [Rust Performance Book: benchmarking](https://nnethercote.github.io/perf-book/benchmarking.html)
- [Rust Performance Book: heap allocations](https://nnethercote.github.io/perf-book/heap-allocations.html)

## C

Profile an optimized binary with debug symbols and usable stacks:

```bash
clang -O2 -g -fno-omit-frame-pointer <sources> -o <binary>
perf stat -r 5 -- ./<binary> <args>
perf record -g --call-graph fp -- ./<binary> <args>
perf report
```

Use Callgrind when deterministic instruction counts or simulated cache/branch behavior answer the question:

```bash
valgrind --tool=callgrind --cache-sim=yes ./<binary> <args>
callgrind_annotate callgrind.out.*
```

Use heaptrack, Massif, or Instruments Allocations for memory profiles. Run memory and undefined-behavior checks separately from performance measurements:

```bash
clang -O1 -g -fno-omit-frame-pointer -fsanitize=address,undefined <sources> -o <binary>-san
./<binary>-san <args>
```

Use a separate `-fsanitize=thread` build for race detection; do not combine TSan timings with native performance conclusions. Verify vectorization or inlining claims with compiler reports/disassembly and end-to-end measurements rather than source intuition.

Useful references:

- [Valgrind Callgrind manual](https://valgrind.org/docs/manual/cl-manual.html)
- [Clang AddressSanitizer](https://clang.llvm.org/docs/AddressSanitizer.html)
- [Clang UndefinedBehaviorSanitizer](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html)

## Go

Use benchmarks with allocation reporting and multiple samples:

```bash
go test -run '^$' -bench '<pattern>' -benchmem -count 10 ./...
go test -run '^$' -bench '<pattern>' -benchmem -cpuprofile cpu.pprof -memprofile mem.pprof <package>
go tool pprof -top cpu.pprof
go tool pprof -list '<symbol>' cpu.pprof
go tool pprof -top -alloc_space mem.pprof
```

Use `benchstat` when already installed to compare saved baseline and candidate outputs. For services, collect one profile type at a time with `runtime/pprof` or a protected `net/http/pprof` endpoint. Inspect:

- CPU for active computation;
- heap `inuse_space` for retained memory and `alloc_space` for allocation churn;
- block and mutex profiles for contention;
- goroutine profiles for leaks/stalls;
- `go tool trace` for scheduling, network blocking, and runtime events.

Use escape diagnostics when allocations are unexplained:

```bash
go build -gcflags='all=-m=2' ./...
```

Use `go test -race` as a correctness check, not a performance measurement. For PGO, feed a representative production CPU profile; microbenchmarks rarely represent a whole service.

Useful references:

- [Go diagnostics](https://go.dev/doc/diagnostics)
- [runtime/pprof](https://pkg.go.dev/runtime/pprof)
- [Go profile-guided optimization](https://go.dev/doc/pgo)

## Python

Respect the repository's environment manager, such as `uv run python`, rather than bypassing it.

Use `timeit` for isolated snippets and `cProfile` for deterministic call-level investigation:

```bash
python -m timeit -r 7 -n <loops> '<statement>'
python -m cProfile -o cpu.prof -m <module> <args>
python -m pstats cpu.prof
```

Inside `pstats`, sort by `tottime` for self cost and `cumtime` for inclusive cost. Deterministic tracing can distort call-heavy code; confirm important findings with an external sampling profiler such as `py-spy`, Instruments, or Linux `perf` when available.

Use `tracemalloc` snapshots for Python allocation source and growth. Start it early enough to see the relevant allocations:

```bash
python -X tracemalloc=25 <script> <args>
```

On supported Linux/Python versions, expose Python frames to `perf`:

```bash
perf record -F 999 -g -- python -X perf <script> <args>
perf report
```

For NumPy, Polars, pandas, PyTorch, and native extensions, process CPU can be spent below Python frames. Use native sampling, thread counts, device profilers, and end-to-end timing; `cProfile` alone may attribute native work only to the calling Python function. Control BLAS/OpenMP threads and synchronization when comparing results.

Useful references:

- [Python `cProfile` and `profile`](https://docs.python.org/3/library/profile.html)
- [Python `timeit`](https://docs.python.org/3/library/timeit.html)
- [Python `tracemalloc`](https://docs.python.org/3/library/tracemalloc.html)
- [Python support for Linux `perf`](https://docs.python.org/3/howto/perf_profiling.html)
