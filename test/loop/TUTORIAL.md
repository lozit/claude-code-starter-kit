<!-- generated-by: groundrules v1.11.0 -->
# Tutorial — learn the loop by building Conway's Game of Life

By the end of this (~15 min) you'll have watched an **autonomous loop implement Conway's Game of Life
from a spec and a failing test**, iterating on its own until the tests go green — and you'll understand
*why* each part of the loop exists.

**Why Game of Life?** Because it has a **deterministic oracle** (`go test`) *and* a real trap: the
tempting first implementation — mutating the grid in place while you scan it — corrupts the result, and
the blinker/glider tests catch it. So the oracle has genuine work to do. Depending on how the maker
writes its first pass you'll get **one of two valid outcomes** — a clean one-shot green, or you **watch
the loop fix a failing attempt** — and in both cases it's the *test*, not the agent's say-so, that
decides "done". (Want to *guarantee* you see the fail → fix arc? See **[Force the engage](#optional--force-the-engage)** below.)
A trivial task converges blindly and teaches nothing; here you watch the back pressure actually work.

**You'll need:** Claude Code with the groundrules plugin, **Go** (`go version`), and a terminal.

---

## The mental model (30 seconds)

- **Reflection (you):** write the *why* (a PRD) and the **acceptance test** — the spec in executable
  form. For Game of Life that's `life_test.go` (block · corner · blinker · glider).
- **Realization (the loop):** a **fresh** agent each iteration reads the repo, the **maker** implements
  one task and runs the test, an **independent verifier** re-runs the test and reviews the diff (it does
  *not* trust the maker's word), commits on green, and **parks a decision** it can't verify rather than
  guessing.
- *The model forgets between iterations; the repo remembers.* The failing test on disk is the handoff.

---

## Step 1 — Create the project (with loop scaffolding)

```bash
mkdir /tmp/life && cd /tmp/life
claude
# in Claude Code:
/groundrules:bootstrap
```
Answer: a **code** project, stack **Go**; specialized docs none; **Call 2c — loop scaffolding → Yes**.
You now have a `loop/` namespace and a `## Invariants` section in `CLAUDE.md`.

> In a hurry? You can skip bootstrap and let `/groundrules:realize` generate the `loop/` scaffolding
> inline (it offers to, in Step 3). Either way you end up with `loop/`.

---

## Step 2 — Drop in the spec and its (red) oracle

This is the **reflection** half — authored *before* any code, by you, not the maker:

```bash
mkdir -p docs/prd
cp "$GROUNDRULES/test/loop/fixtures/game-of-life/PRD.md"        docs/prd/game-of-life.md
cp "$GROUNDRULES/test/loop/fixtures/game-of-life/go.mod"        .
cp "$GROUNDRULES/test/loop/fixtures/game-of-life/life_test.go"  .
go test ./...        # RED — "undefined: Step". The oracle exists; the code doesn't yet.
git add docs/prd/game-of-life.md go.mod life_test.go && git commit -m "spec: Game of Life PRD + red oracle"
```
(`$GROUNDRULES` = wherever the plugin repo lives.) The red test is the point: it's the loop's back
pressure, written **before** the implementation — and **committed before** the loop runs, so it's the
frozen spec (and the verifier's "test untampered" check, which works via `git diff`, actually has a
tracked baseline to compare against).

Set your invariants in `CLAUDE.md` → `## Invariants`, e.g.:
```markdown
- `go test ./...` stays green.
- `Step` is pure — it never mutates its argument.
```

---

## Step 3 — Turn the PRD into a loop task

```
/groundrules:realize
# source: a PRD → docs/prd/game-of-life.md
```
**What happens:** `realize` sees the success criterion is `go test ./...` and that a **pre-written,
currently-red** acceptance test (`life_test.go`) already exists — authored by you, not the maker. That
satisfies the **TDD-before-loop gate**, so the "implement `Step`" task is tagged **`[loop]`** and written
to `loop/backlog.md` with its test command. (Had there been no red test, `realize` would refuse `[loop]`
and offer to author one first — that's the gate doing its job.)

---

## Step 4 — Run the loop and watch it engage

```bash
bash loop/run-loop.sh --max 8     # headless `claude -p`, twice per iteration — maker then verifier; costs tokens
```
This is the **high-fidelity** executor (the verifier re-runs `go test` itself). For a lighter, in-the-box
alternative on a single task — `/goal "the command \`go test ./...\` exits 0"` — and when to pick which,
see `loop/README.md` → *Two ways to run the loop*.

You'll see **one of two valid arcs** (stated as **invariants** — the exact transcript varies):

- **One-shot green.** A capable maker may write the correct "snapshot the input, build a **new** grid"
  version on the first pass — `[][]bool` returning `[][]bool` nudges that way. `go test` is green, the
  verifier re-runs it, PASSes, commits. *That's a good outcome — the oracle still proved it.*
- **Fail → fix → green.** A first version **mutates the grid in place**; `go test` fails the
  **blinker and glider** tests (the bug corrupts the grid mid-scan); the verifier **REJECTs** (no green,
  no commit); a **fresh** maker reads the failing test on disk, switches to simultaneous update, and the
  next run goes green → commit + check off.

Either way the loop ends with `DONE: backlog empty`, and **the test — not the agent's word — decided
"done"**. Verify:
```bash
go test ./... && echo GREEN
git log --oneline          # one or more loop-authored commits
```

---

## Step 5 — Read what the loop left behind

- `life.go` — a correct, **pure** `Step` (look: it builds a new grid, never mutates its input).
- `git log` — the loop's own commits, each referencing the task.
- `loop/backlog.md` — the task now `- [x]`.
- `loop/lessons.md` (maybe) — a one-line lesson the loop kept for next time.

Nothing landed without the test going green, and the maker never graded its own work — the verifier
re-ran the oracle every time.

---

## Why each piece earned its place

| Piece | What it bought you here |
|-------|--------------------------|
| **A pre-written oracle** (`life_test.go`) | The loop *can't fake done* — `go test` is binary. This is the back pressure. |
| **writer ≠ maker** | The maker can't weaken the test to pass; it was written in reflection, before the code. |
| **Fresh context each iteration** | No accumulated confusion; the failing test on disk *is* the handoff between attempts. |
| **The verifier re-runs the test** | "Distrust the report" — a maker claiming green doesn't make it so. |
| **The `MAX` cap** | The loop can't run away; it stops at the ceiling even if it never converges. |

---

## Optional — Force the engage

If your maker passed first try and you want to **see the loop fix a failing attempt deterministically**,
seed the classic in-place bug *before* running the loop, then let the loop repair it:

```bash
cat > life.go <<'EOF'
package life

func liveNeighbours(g [][]bool, r, c int) int {
	n := 0
	for dr := -1; dr <= 1; dr++ {
		for dc := -1; dc <= 1; dc++ {
			if dr == 0 && dc == 0 {
				continue
			}
			rr, cc := r+dr, c+dc
			if rr >= 0 && rr < len(g) && cc >= 0 && cc < len(g[rr]) && g[rr][cc] {
				n++
			}
		}
	}
	return n
}

// BUG: mutates g in place while scanning, so later cells see already-updated neighbours.
func Step(g [][]bool) [][]bool {
	for r := range g {
		for c := range g[r] {
			n := liveNeighbours(g, r, c)
			if g[r][c] {
				g[r][c] = n == 2 || n == 3
			} else {
				g[r][c] = n == 3
			}
		}
	}
	return g
}
EOF
go test ./...      # RED — FAIL: TestBlinkerPeriod2 and TestGliderMovesDiagonally (the still lifes still pass)
```
Now run `bash loop/run-loop.sh --max 8`. The maker reads the **failing** test plus the buggy code, sees
the in-place mutation, switches to "snapshot input → new grid", and the loop converges to green — the
**fail → fix → green** arc, on demand. This is also the honest demonstration that *the in-place version
really is wrong and the oracle really catches it.*

## Optional — see the other behaviours

- **Reject a gamed diff:** hand the verifier a `life.go` that special-cases the exact test grids (a
  lookup table) instead of computing `Step`. The verifier probes another pattern and **REJECTs** —
  green-but-gamed doesn't pass.
- **Park a decision (BLOCKED):** Game of Life has *no* hidden decision (the spec is complete), so it
  converges cleanly. To see the loop refuse to guess, try the under-specified `truncate` task in
  [`WALKTHROUGH.md`](WALKTHROUGH.md) §5 — the maker writes `loop/blocked.md` instead of inventing a
  behaviour, and you triage it (the *backward crossing*).

## Where to go next

- [`WALKTHROUGH.md`](WALKTHROUGH.md) — a terser reference run (slugify) plus the **deterministic**
  runner test (`validate-runner.sh`, no tokens) you can drop in CI.
- `loop/README.md` (in your generated project) — the full maker/verifier contract and the
  `blocked.md` triage convention.
