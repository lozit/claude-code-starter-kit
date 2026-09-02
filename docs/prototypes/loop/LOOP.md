<!-- generated-by: groundrules v1.10.0 -->
# LOOP — the fixed prompt, replayed each iteration

This is the prompt `run-loop.sh` feeds to a **fresh** agent every iteration. It is intentionally fixed:
the model forgets between iterations, the **repo remembers** (ADR 0020/0021). Everything you need is on
disk — read it, don't rely on memory of a previous turn.

## Each iteration, do exactly this

1. **Read state.**
   - `TODO.md` — the backlog (tasks are `- [ ]` unchecked / `- [x]` done).
   - `LESSONS.md` (if present) — apply accumulated lessons.
   - `blocked.md` (if present) — tasks already parked; skip them.
   - `git log --oneline -10` and `git status` — what already exists.

2. **Pick the first ready task** — the first `- [ ]` task in `TODO.md` that is **not** parked in
   `blocked.md`. If there is none → output `DONE: backlog empty` and **stop** (this is the loop's
   natural stop condition).

3. **Maker pass.** Implement that one task following [`maker.md`](maker.md). Run its acceptance test.
   Produce the maker `STATUS` block.

4. **Verifier pass.** Review the maker's diff following [`verifier.md`](verifier.md) — **as an
   independent reviewer that re-derives from the diff and re-runs the test**, not trusting the maker's
   report. For real independence the verifier should run as a **separate subagent / fresh context**,
   handed only the **task line + its pre-written acceptance test** and the **diff** — never the maker's
   reasoning, its `STATUS` narrative or the commit message. Those carry the author's framing, and a
   fresh agent fed the author's story is no longer a fresh one.

5. **Act on the verdict.**
   - **PASS** → commit **the intended diff** (the files the task changed + the `TODO.md` check-off),
     message referencing the task. Stage explicitly rather than blindly `git add -A`: that would sweep
     build artifacts (`__pycache__/`, etc.) and any in-flight `blocked.md` into the commit — keep a
     `.gitignore` and stage the real changes. Then flip `- [ ]` → `- [x]` in `TODO.md`. Optionally
     append a one-line lesson to `LESSONS.md`.
   - **REJECT** → leave the task unchecked. If this task has now been REJECTed across multiple
     iterations with no progress, or the maker reported **BLOCKED**, **write/append `blocked.md`** and
     leave the task for human triage (the backward crossing). Otherwise the next iteration retries it
     with the verifier's note.
   - Maker **BLOCKED / NEEDS_CONTEXT** → ensure `blocked.md` is written, do not commit, move on.

6. **One task per iteration.** Do not chain into the next task. End the turn. The runner starts the
   next fresh iteration.

## Stop conditions (any one ends the loop)
- `DONE: backlog empty` — no ready task remains.
- The runner's hard `MAX` iteration cap is reached (anti-runaway — see `run-loop.sh`).
- Every remaining task is parked in `blocked.md` (nothing ready → also `DONE: backlog empty`,
  with blockers awaiting human triage).
