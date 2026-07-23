<!-- generated-by: groundrules v1.10.0 -->
# LOOP — the fixed prompt, replayed each iteration

This is the prompt `loop/run-loop.sh` feeds to a **fresh** agent every iteration. It is intentionally
fixed: the model forgets between iterations, the **repo remembers**. Everything you need is on disk —
read it, don't rely on memory of a previous turn.

> **Backlog ownership.** The loop reads `loop/backlog.md` — **never `PLAN.md` directly**. `PLAN.md` is
> the human's planning surface; `loop/backlog.md` holds only loop-safe tasks (atomic, verifiable,
> invariant-aware). For now it is hand-filled; `/groundrules:realize` will populate it once it lands.

## Each iteration, do exactly this

1. **Read state.**
   - `loop/backlog.md` — the backlog (tasks are `- [ ]` unchecked / `- [x]` done).
   - `CLAUDE.md` → `## Invariants` — what must never break.
   - `loop/lessons.md` (if present) — apply accumulated lessons.
   - `loop/blocked.md` (if present) — tasks already parked; skip them.
   - `git log --oneline -10` and `git status` — what already exists.

2. **Pick the first ready task** — the first `- [ ]` task in `loop/backlog.md` that is **not** parked in
   `loop/blocked.md`. If there is none → output `DONE: backlog empty` and **stop** (the loop's natural
   stop condition).

3. **Maker pass.** Implement that one task following [`maker.md`](maker.md). Run its acceptance test.
   Produce the maker `STATUS` block.

4. **Verifier pass.** Review the maker's diff following [`verifier.md`](verifier.md) — **as an
   independent reviewer that re-derives from the diff and re-runs the test**, not trusting the maker's
   report. For real independence the verifier should run as a **separate subagent / fresh context**.

5. **Act on the verdict.**
   - **PASS** → flip `- [ ]` → `- [x]` in `loop/backlog.md` and (optionally) append a one-line lesson to
     `loop/lessons.md`, **then commit the intended diff** — the files the task changed **+** the
     `loop/backlog.md` check-off **+ `loop/lessons.md` if you touched it** (it's tracked on purpose —
     durable loop memory). Message references the task. Stage explicitly rather than `git add -A`: that
     would sweep build artifacts and any in-flight `loop/blocked.md` into the commit.
   - **REJECT** → leave the task unchecked. If this task has now been REJECTed across multiple
     iterations with no progress, or the maker reported **BLOCKED**, **write/append `loop/blocked.md`**
     and leave the task for human triage (the backward crossing). Otherwise the next iteration retries
     it with the verifier's note.
   - Maker **BLOCKED / NEEDS_CONTEXT** → ensure `loop/blocked.md` is written, do not commit, move on.

6. **One task per iteration.** Do not chain into the next task. End the turn. The runner starts the
   next fresh iteration.

## Stop conditions (any one ends the loop)
- `DONE: backlog empty` — no ready task remains.
- The runner's hard `MAX` iteration cap is reached (anti-runaway — see `run-loop.sh`).
- Every remaining task is parked in `loop/blocked.md` → also `DONE: backlog empty`, with blockers
  awaiting human triage (see `loop/blocked.md`).
