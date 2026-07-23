<!-- generated-by: groundrules v1.10.0 -->
<!-- Inserted into CLAUDE.md only when loop scaffolding is opted in (after ## Conventions). -->
## Invariants

What the autonomous loop (`loop/`) must **never** break — the verifier checks the diff against this
section every iteration, and the maker treats a would-be violation as a `BLOCKED`, not a judgement
call. Keep it short and checkable; state your own:

- <fill in — e.g. the build/test suite stays green>
- <fill in — e.g. no secrets, credentials, or `.env` values committed>
- <fill in — e.g. public API / DB schema not changed without an ADR>
- <fill in — e.g. no edit outside the task's stated scope>

> **Loop blocked?** On a parked decision, triage `loop/blocked.md` (re-decompose / decide → ADR / fix interactively) — see `loop/README.md`.
