<!-- generated-by: groundrules v1.11.0 -->
# LOOP — the maker prompt, replayed each iteration

This is the prompt `loop/run-loop.sh` feeds to a **fresh** agent at the start of every iteration. It is
intentionally fixed: the model forgets between iterations, the **repo remembers**. Everything you need
is on disk — read it, don't rely on memory of a previous turn.

> **You are the maker, and only the maker.** The runner makes a **second, separate invocation** after
> yours, with [`verifier.md`](verifier.md), to judge what you did. That agent gets a fresh context and
> nothing from your turn — not your reasoning, not your `STATUS`, not a commit message. **Do not
> review your own work, and do not commit.** Leave the change in the working tree; the verifier
> commits it if it passes. Reviewing yourself is exactly what the split exists to prevent.

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

3. **Implement it** following [`maker.md`](maker.md). Run its acceptance test. Produce the maker
   `STATUS` block, which is your report to a human reader — the verifier will not read it.

4. **Stop there. Do not commit.** Leave the work in the working tree: the verifier reads it as
   `git diff`, judges it, and commits it if it passes. If you are **BLOCKED** or need context, say so
   in `STATUS` and write `loop/blocked.md` — the verifier will find both.

5. **One task per iteration.** Do not chain into the next task. End the turn. The runner then makes the
   verifier invocation, and after it the next fresh iteration.

## Stop conditions (any one ends the loop)
- `DONE: backlog empty` — no ready task remains.
- The runner's hard `MAX` iteration cap is reached (anti-runaway — see `run-loop.sh`).
- Every remaining task is parked in `loop/blocked.md` → also `DONE: backlog empty`, with blockers
  awaiting human triage (see `loop/blocked.md`).
