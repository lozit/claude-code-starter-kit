<!-- generated-by: groundrules v1.10.0 -->
# Loop backlog

The tasks the autonomous loop is allowed to execute. **The loop reads only this file** — never
`PLAN.md`. Put here **only loop-safe tasks**: atomic, isolatable, and **verifiable** (each names an
acceptance test or check the verifier can re-run). Anything that needs a human decision, exploration, or
a cross-cutting refactor stays in `PLAN.md` as `[supervised]`.

> **Hand-filled for now.** Once `/groundrules:realize` lands it will partition an approved plan into
> `[loop]` vs `[supervised]` and populate this file for you. Until then, add tasks by hand using the
> shape below.

## How to write a loop-safe task

Each task is one `- [ ]` line (the loop checks it off to `- [x]` on a verified PASS). State, crisply:
1. **what** to build (one atomic unit — no "and also"),
2. **where** (the file/module),
3. the **acceptance test** to run and what "green" means (the verifier re-runs it; no test → not
   loop-safe, keep it `[supervised]` in `PLAN.md`).

A task the loop can't verify its way out of, or that hides a decision, will be parked in
`loop/blocked.md` for you to triage — by design. See `loop/README.md` for the full contract.

## Tasks

<!-- Example shape — replace with real tasks:
- [ ] **Implement `<unit>` in `<path>`.** Acceptance test: `<command>` → exit 0 = green.
      Behaviour: <the precise, unambiguous spec>. Out of scope: <what NOT to touch>.
-->

- [ ] <fill in your first loop-safe task>
