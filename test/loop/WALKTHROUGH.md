<!-- generated-by: groundrules v1.10.0 -->
# Loop walkthrough — from an empty folder to a working loop

This shows **how to use the groundrules loop** end-to-end on a fresh project, and **doubles as the
validation suite**: each step states the command and the **expected outcome**. Work through it and you
end with a real commit the autonomous loop produced.

**Honesty about what's deterministic.** Only `run-loop.sh` is plain shell — everything else
(`bootstrap`, `realize`, the maker/verifier prompts) is **driven by Claude**, so its output *varies*.
Steps are tagged:

- **`[shell]`** — deterministic, no LLM, exact result (you can script/CI it).
- **`[agent]`** — run by Claude (a skill or the loop); expected outcome is stated as an **invariant**
  ("the test goes green and a commit appears"), not an exact transcript.
- **`[human]`** — a quick manual edit.

Behavioural steps can be run **live** (real `claude -p`, costs tokens) or **replayed by a subagent**
(how we validate this doc, no extra cost — see "How this is validated").

---

## 0. `[shell]` Prove the runner is safe — before anything else

```bash
bash test/loop/validate-runner.sh
```
**Expect:** `11 passed, 0 failed`. This proves the anti-runaway `MAX` cap, the `DONE` stop, and
one-fresh-invocation-per-iteration — deterministically, with a stubbed `claude` (no tokens). It's the
only fully-automated part; the rest demonstrates *usage*.

---

## 1. `[agent]` Bootstrap a fresh project with loop scaffolding

```bash
mkdir /tmp/widgetkit && cd /tmp/widgetkit
claude
# then, in Claude Code:
/groundrules:bootstrap
```
Answer the interview: a **code** project (stack: Python), specialized docs **none**, and at **Call 2c —
loop scaffolding → Yes**. (Plan: yes; remote: none; intent: skip is fine.)

**Expect** (`[shell]`-checkable after):
```bash
ls -a loop/                      # maker.md verifier.md LOOP.md run-loop.sh backlog.md README.md .gitignore
test -x loop/run-loop.sh && echo "runner executable"
grep -q '## Invariants' CLAUDE.md && echo "Invariants section present"
grep -q '"scaffolded": true' .groundrules.json && echo "loop.scaffolded recorded"
! grep -rq '{{' loop/ && echo "no leftover placeholders"
```

---

## 2. `[human]` State your invariants (30 seconds)

Edit `CLAUDE.md` → `## Invariants`. The verifier enforces these every iteration. For this demo:

```markdown
- The acceptance test suite stays green (`python3 test/test_slugify.py` exits 0).
- No secrets or `.env` values are committed.
```

---

## 3. `[human]` + `[agent]` Author the spec as a *red* test, then `realize` the plan

The loop's back pressure is a **pre-written, red acceptance test, authored before the maker** (TDD-before-loop).
Drop one in (this *is* the spec, in executable form):

```bash
mkdir -p test
cp "$GROUNDRULES/test/loop/fixtures/test_slugify.py" test/test_slugify.py   # $GROUNDRULES = the plugin repo
python3 test/test_slugify.py ; echo "exit=$?"     # [shell] expect: FAIL / exit=1  (RED — no code yet)
```

Then turn the plan into a loop backlog:
```
/groundrules:realize
# source: paste — paste the tasks from test/loop/fixtures/sample-plan.md
```
**Expect** (`[agent]`, as invariants):
- **`slugify` → `[loop]`** — it has a red behavioural acceptance test (`test/test_slugify.py`), authored
  by you, not the maker. It's appended to `loop/backlog.md` in the maker format (with the test command).
- **`truncate` and the caching task → `[supervised]`** — `truncate` has no red test *and* hides a
  "where to cut" decision; caching is an explicit decision. They're tagged `[supervised]` in `PLAN.md`
  with the reason. *(If `slugify` had no test, `realize` would offer to author one and confirm it red
  before tagging `[loop]` — that's the gate.)*
```bash
grep -q 'slugify' loop/backlog.md && echo "slugify is in the loop backlog"   # [shell]
grep -q '\[supervised\]' PLAN.md && echo "supervised tasks tagged in PLAN.md"
```

---

## 4. `[agent]` Run the loop — watch it converge

```bash
bash loop/run-loop.sh --max 5
```
Each iteration is a **fresh** agent: it reads `loop/backlog.md`, the maker implements `slugify` in
`widgetkit/text.py` and runs the test, the verifier **re-runs the test itself** and reviews the diff,
and on PASS the loop commits and checks the task off.

**Expect** (invariants):
- `widgetkit/text.py` now exists and `python3 test/test_slugify.py` **exits 0** (green).
- `git log --oneline` shows a **loop-authored commit** for the slugify task.
- `loop/backlog.md` shows the slugify task as `- [x]`.
- The loop ends with **`DONE: backlog empty`** (no ready task left) — or stops at `MAX`.
```bash
python3 test/test_slugify.py && echo "GREEN"          # [shell]
git log --oneline -1
grep -q '\- \[x\].*slugify' loop/backlog.md && echo "task checked off"
```
**This is convergence** — behaviour (1) of the contract.

---

## 5. See the rest of the back pressure (the other four behaviours)

Convergence (1) and the TDD gate (4) you just saw. The other three — best run live or subagent-simulated:

- **(2) Reject a gamed diff.** Hand the verifier a `widgetkit/text.py` that *hard-codes* the test's
  expected outputs (a lookup table) instead of implementing `slugify`. **Expect:** the verifier
  **REJECTs** it — it probes inputs the test doesn't cover (e.g. `slugify("A  B")`) and catches that the
  general behaviour is wrong, even though `test_slugify.py` is green. (A green test alone is necessary,
  not sufficient.)
- **(3) Park a decision — don't guess.** Add the under-specified `truncate` task to `loop/backlog.md`
  and run the loop. **Expect:** the maker reports `BLOCKED` and appends a section to `loop/blocked.md`
  ending `Resolution: (open — awaiting triage)`, touching no code — it refuses to guess where to cut.
- **(5) Triage the block (the backward crossing).** Open `loop/blocked.md` and follow the triage
  convention in `loop/README.md`: a hidden decision → decide it, `/groundrules:add-adr`, re-add the
  now-decided task; then **close** the `Resolution:` line (`Resolution: Decide → ADR 00NN; task re-added`).
  **Expect:** the blocker is closed with a route + pointer — `blocked.md` is an audit trail, not a
  graveyard.

---

## How this is validated

- **Deterministic layer** — `bash test/loop/validate-runner.sh` (step 0): 11 checks, repeatable, zero
  tokens. Run it in CI or before any release that touches the loop.
- **Behavioural layer** — steps 1, 3, 4, 5: run them **live** (real `claude -p`, real tokens) or have a
  **subagent replay** this walkthrough on a `/tmp` project (no extra cost; this is how we validate the
  doc still works). Outcomes are invariants, so a different-but-correct maker run still passes.
- **Why the split** — the loop's value is LLM-driven and can't be pinned to an exact transcript; pinning
  only the runner (the one executable) keeps the safety net honest and automatic.
