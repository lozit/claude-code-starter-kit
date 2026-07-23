<!-- generated-by: groundrules v1.10.0 -->
# test/loop — loop walkthrough + validation suite

How to **use the groundrules loop** on a fresh project, in a way that also **validates** it. Spec'd in
[`docs/prd/loop-walkthrough.md`](../../docs/prd/loop-walkthrough.md).

| File | What it is |
|------|------------|
| [`QUICKSTART.md`](QUICKSTART.md) | **Your first loop in 5 steps** — the everyday flow (blank project → bootstrap → ask in chat → set a red test → run). ~5 min. **Start here.** |
| [`TUTORIAL.md`](TUTORIAL.md) | **Learn the loop by building Conway's Game of Life** (Go) — the deeper teaching path. Has a deterministic oracle (`go test`) and a real trap, so you watch the loop *engage*. |
| [`WALKTHROUGH.md`](WALKTHROUGH.md) | A terser reference run (slugify) + the deterministic checks at each step — the validation path. |
| [`validate-runner.sh`](validate-runner.sh) | The **deterministic** layer — stubs `claude` to prove `run-loop.sh`'s `MAX` cap, `DONE` stop, and per-iteration freshness. No LLM, no tokens. `bash test/loop/validate-runner.sh`. |
| [`fixtures/game-of-life/`](fixtures/game-of-life/) | The tutorial fixture: a `PRD.md`, `go.mod`, and the pre-written **red** oracle `life_test.go` (block · corner · blinker · glider). No `life.go` — the loop writes it. |
| [`fixtures/test_slugify.py`](fixtures/test_slugify.py) | A pre-written, currently-**red** acceptance test (the loop's back pressure) for the walkthrough's `slugify` task. |
| [`fixtures/sample-plan.md`](fixtures/sample-plan.md) | A small **mixed** plan to feed `/groundrules:realize` (one `[loop]`-eligible task + two `[supervised]`). |

**Two layers, on purpose.** The loop is LLM-driven (no `bootstrap`/`realize` CLI), so only the runner is
testable deterministically. `validate-runner.sh` pins that; the behavioural contract (converge / reject
a gamed diff / block / TDD gate / triage) is demonstrated in `WALKTHROUGH.md`, run live or replayed by a
subagent. See the PRD for the rationale.
