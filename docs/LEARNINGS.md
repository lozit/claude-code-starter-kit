<!-- generated-by: groundrules v1.11.0 -->
# Learnings — groundrules

Non-trivial learnings that emerged during the project. Reverse-chronological order (newest at the top).

One entry per learning. Keep the format simple: title, context, lesson.

---

## Writing a case that *reproduces* a failure is far harder than writing one that *describes* it

**Why**: 2026-09-10, and it is now three cases out of four. Every green the `evals/` suite has
produced was green for a reason other than *the guard works*:

- **Case 1** — green 3/3, then **discounted**: two of the three runs read `evals/evals.json`, the
  file holding the expectations grading them. The answer key sits inside the repository the case
  explores.
- **Case 2** — green on **both** arms in its first form. The question was answerable from general
  knowledge of Claude Code, so it measured competence and not this plugin's configuration. Only a
  **checkable false premise** — a version number wrong in a way verifiable here and unknowable
  elsewhere — made it discriminate.
- **Case 4** — green 3/3 on its first outing, and the recorded failure **did not reproduce**. The
  entry describes inserting into a large file mid-session, by a scripted string anchor, under load;
  the case handed a fresh agent a small file and one focused instruction. Different task, so the
  green says the task was easy.

Only **case 3** was written the other way round — a prompt whose comfortable answer is the wrong one
— and it is the only case that has ever produced a delta.

**When to apply**: when writing an eval case from a recorded failure, do not transcribe the entry
into a prompt. **Ask what made the failure happen** — the pressure, the size, the shortcut that was
tempting, the plausible-but-wrong answer — and rebuild *that*, or admit the case reproduces nothing.
Three tests before trusting a green: could a reader answer it without the thing under test (then it
measures competence); can the agent reach the grading criteria (then it is not blind); and were the
conditions that produced the failure actually present (then it is a different task wearing the same
name). **A green from a case that cannot fail is more dangerous than a red**, because it is filed as
evidence.

## A guard in a file nothing reads cannot fire — check that the lesson is *loaded*, not just written

**Why**: 2026-09-10. A guard was written into `docs/AGENT-EVALS.md` on 2026-09-08 and broken on
2026-09-09, in the same file, on the next edit of the same kind. The guard was not wrong and the
entry was not vague; **nothing put it in front of the agent**. This repository's own `CLAUDE.md` had
no *Session start* section at all — while the template it ships gives every generated project one,
naming `PLAN.md`, `docs/LEARNINGS.md` and `docs/VISION.md` as required reading. So `LEARNINGS.md`
and `AGENT-EVALS.md` were **write-only** here: the agent was told where to record lessons and never
told to read them. Every guard in both files was structurally unable to fire, which makes the whole
capture ritual a filing habit rather than a feedback loop. Found while checking whether a proposed
eval case could ever be meaningful — the case needed the guard to be loaded, and it was not.

**When to apply**: whenever you write a rule meant to change future behaviour — a guard, a lesson, a
convention. **Name the file that will carry it into the next session**, and check that something
actually loads that file: a session-start list, an always-loaded config, a rule with a `paths:`
frontmatter. If nothing does, you have written a note, not a guard, and the honest choice is to move
it somewhere loaded or to accept that it will not fire. The tell is a recurrence shortly after a
capture: the rule existed, the failure repeated, so the path from one to the other was never there.
And dogfooding is not automatic — a plugin can ship the mechanism it fails to apply to itself.

## A baseline arm run anywhere the plugin is reachable is not a baseline — and three channels reach it

**Why**: 2026-09-09, the first real run of the `evals/` suite. Case 3 asks whether the capture ritual
fires at session end; it cannot. Two arms were run, one with the repository and one meant to be
without. **Both passed, so the measured delta was zero** — which would have read as *the plugin
changes nothing here*. It was wrong three times over:

1. **A subagent launched from the repository receives the project `CLAUDE.md` automatically.** The
   control asked one directly: it reported three auto-loaded instruction blocks, quoted the file's
   first lines, and said its knowledge of `/groundrules:close` came from that context and not from
   training — naming the section. Zero tool calls. The configuration under test walks into the
   baseline through the front door.
2. **An isolated `claude -p` in an empty directory outside the repository still found it.** The
   plugin is *installed* on this machine, so its full sources sit in the plugin cache, readable by
   any session. The answer said *"vérifié dans le repo"*.
3. Only with **tools disallowed as well** did the arm answer without the plugin — and it then
   **failed the case**: it speculated that a `Stop` hook *probably* drives the capture, invented a
   command name, and left the automatic reading wide open. That is the delta the case exists to
   measure, and it was invisible until the third attempt.

**Two further things the same run showed, both about what a case can measure.** A baseline
**does not apply uniformly across case shapes**: for a case that asks the agent to read the
repository, *without the plugin* is not a meaningful condition — the shielded arm correctly refused
to answer, and a delta claimed there would be manufactured. And a case can pass on **both** arms,
which is not a success but a verdict on the case: the guard it encodes is one the model already
has, so the case measures general competence rather than this configuration's contribution. Decide
such a case, do not leave it green.

**And the answer key sits inside the repository under test.** One arm greps the repo and reads
`evals/evals.json`, the file holding the very expectations it is graded on. No clean fix exists
while the suite lives where the cases explore; prefer prompts whose answer cannot be improved by
knowing the rubric, and discount a green from a repo-reading case accordingly.

**When to apply**: whenever an eval, an ablation or an A/B claims to compare *with* against
*without*. Before trusting a zero delta, ask what the "without" arm can still reach: auto-loaded
project and global instructions, an installed copy of the thing under test, the working directory
itself. A contaminated baseline does not fail loudly — it agrees with the other arm, which reads
as a reassuring result. **Prefer a contaminated arm that fails to one that passes**: the second is
indistinguishable from success. And state the confound you could not remove — disallowing tools
buys isolation at the price of conflating *no plugin* with *no ability to look anything up*, which
is not the same experiment.

## A skill's acceptance cases must be *run* on fixtures — reading the instructions back does not find their gaps

**Why**: 2026-09-08, `/groundrules:close` shipped after being read and re-read by its author, then had its
five acceptance cases exercised for real: two throwaway git repositories, and two **fresh subagents** given
only the `SKILL.md` and a repository path, with no idea what the author expected. All five cases passed —
and the runs returned **seven defects the author had read past**, three of them silent-failure class.
The worst: rule 2 of the baseline said *"on a topic branch, use `git merge-base HEAD <default>`"*, which on
the default branch resolves to `HEAD` itself, yielding an empty window and a confident **"nothing changed"**
indistinguishable from a real one. Verified on this repo: zero commits in the window. Next: the fallback
*"the last 15 commits"* names a **window** where every command needs a **ref**, so `HEAD~15` does not resolve
in a young repository — and the only base left, the empty tree, puts the commit that *created* `PLAN.md`
inside the diff the tool compares `PLAN.md` against. And two sentences one paragraph apart contradicted each
other, *"a path or directory is a match"* against *"a filename is not a match"*, which is precisely the
judgement call the skill's central rule exists to settle. None of these are visible by reading; all three
appeared within minutes of a fixture.

**When to apply**: whenever a skill is authored or substantially changed. Before calling it done, write the
smallest fixtures its acceptance cases need — a positive, a negative, and one built to trip its central rule —
and have a **fresh subagent** run the instructions against them, told to stop before writing and to report
where the instructions were unclear. Its *ambiguity* section is worth more than its result: a case that passes
still exposes the branches the author never took. Deliberately include a case where the honest answer is
"nothing to do"; a check that cannot come back empty is a check that manufactures work. This is the cheap,
manual form of the [ADR 0037](decisions/0037-executable-evals-over-agent-config.md) eval suite, and it needs
no runner.

## Commit the acceptance test before the loop — an untracked test makes the "untampered" guard guard nothing

**Why**: 2026-06-20, a field test of the loop quickstart (a real `to_roman` task) converged correctly —
real algorithm, cleanly-scoped commit, natural stop — but surfaced a flow gap: the pre-written
`test_roman.py` was **never committed**, so the loop's commit held only the implementation, and the
*spec that proves correctness wasn't in git*. Worse, the verifier's Stage-1 "acceptance test untampered"
check works via `git diff -- <test>`: on an **untracked** file that diff is empty, so a maker could
rewrite the test and the verifier would see nothing. The guard was guarding nothing. (Also surfaced: the
loop appended `loop/lessons.md` but didn't commit it, though our `loop/.gitignore` keeps it tracked on
purpose; and placeholder `## Invariants` mean the invariants diff-check guards nothing either.)

**When to apply**: the acceptance test is the **frozen spec**, authored in reflection (writer ≠ maker) —
it must be **committed *before* the loop runs**, for two reasons: (1) the spec is durable; (2) the
verifier's tamper-check needs a tracked baseline. Surfaces that now say so: `QUICKSTART`/`TUTORIAL` (commit
the test before launching), `realize` Phase 5 recap (remind), `verifier.md` check 7 (flag an untracked
test), `LOOP.md` (commit `loop/lessons.md` with the iteration). General rule for any TDD-gated loop: **a
guard that compares against git only works on committed files** — commit the thing you want protected
before the autonomous agent can touch it.

## A safety guard doesn't travel between prompt surfaces — restate it everywhere an agent can act

**Why**: 2026-06-14, the brick-5 backward-crossing E2E found that the "don't guess a parked decision"
guard lived only in `loop/maker.md` (where the maker writes the blocker), **not** in the triage
convention (`loop/README.md`) that a *different* agent reads later. The triage table said "Decide → ADR:
**make the call**, record it with `add-adr`" — addressed to a human, but with nothing forbidding an
autonomous *triage* agent from reading "make the call" as license to invent the decision. The guard the
maker respects didn't automatically protect the triager; the two are separate prompt surfaces read by
separate agents at separate times. (Fixed: the anti-guess guard — could-act ≠ cleared-to-act — is now
stated in the triage convention itself, plus a multi-category tie-breaker and a "routed-but-pending ≠
resolved" close-out state so a human-pending decision isn't falsely marked done.)

**When to apply**: whenever a workflow is split across multiple prompts/docs read by different agents (a
maker prompt + a triage convention; a skill that hands off to another skill; scaffolding + its README).
A safety guard, a vocabulary, or a "don't do X" rule **must be repeated at each surface where an agent
could act on it** — it is not inherited from the doc that first stated it. Audit every hand-off point and
restate the guard there. A fresh-subagent E2E that drives *that specific surface in isolation* is what
exposes the missing guard (the maker E2E would never have caught it — only the triage E2E did).

## A red acceptance test must fail on a behavioural assertion, not just a missing import

**Why**: 2026-06-14, the brick-4 TDD-gate E2E surfaced that "the test is currently red (exit ≠ 0)" is
necessary but not sufficient evidence that a test is real back pressure. Both looped fixtures were red
**only** by `ModuleNotFoundError` (the symbol didn't exist yet) — the test never reached a single
assertion. A gate that accepts any non-zero exit as "red" can't tell *red-because-unbuilt* from
*red-because-the-behaviour-is-wrong*: a test that imports a missing function and a test whose assertions
genuinely constrain behaviour pass the gate identically. The same E2E noted the gate guarantees writer ≠
maker (the maker can't grade itself) but **not** that the spec/test is *correct* — a wrong spec yields a
wrong-but-green test, and no gate can catch that (it's reflection's job, upstream).

**When to apply**: anywhere "red-first" is used as a stop-condition gate (`/groundrules:realize`'s
`[loop]` bar; any TDD-before-loop discipline). Require the acceptance test to contain **real behavioural
assertions that would fail if the behaviour were wrong, not merely if it's absent** — a
`ModuleNotFoundError`-only red is acceptable as the *first* greenfield red but is weak evidence on its
own. And be honest about the gate's reach: it stops self-grading and proves the test constrains; it does
**not** validate the spec is right. Both are now documented in `realize`'s author-the-test step.

## A skill's `allowed-tools` must match its write pattern — append/edit needs `Edit`, fresh files need only `Write`

**Why**: 2026-06-14, the brick-3 `/groundrules:realize` E2E (whose subagent audited the frontmatter)
caught that its Phase 4 mandated "append / never overwrite" on two existing files while `allowed-tools`
listed only `Read, Write, …` — no `Edit`. A faithful run constrained to that grant would have to
Read-the-whole-file-then-Write-it-back to "append", which **is** an overwrite and races a
concurrently-edited file — the exact clobber the phase forbids. The same audit surfaced that `bootstrap`
(also `Edit`-less) had been given a brick-2 instruction to "insert `## Invariants` into the *generated*
CLAUDE.md" — an edit-after-write it couldn't perform. Both passed every static check (signatures,
placeholders, drift) because the mismatch is between the *tool grant* and the *prose*, invisible until
you execute the skill under its real constraints.

**When to apply**: authoring or changing any side-effecting skill. (1) If a phase **edits or appends to
an existing file**, `allowed-tools` must include `Edit`, and the prose should say "append with `Edit`",
not Read+Write-back. (2) If a skill only **composes fresh files**, `Write` alone is right — and any
"insert X into the generated file" step must be reworded to **splice-before-the-single-`Write`**
(compose-then-write), not write-then-rewrite (the `bootstrap` `## Invariants` fix). Cross-check the
frontmatter `allowed-tools` against what every phase actually does to disk. A fresh-subagent E2E that
*executes* the skill is what catches this — a static read won't.

## A hardcoded version string in a generated artifact drifts — the release sweep only bumps signatures

**Why**: 2026-06-14, the brick-2 fresh-subagent E2E caught `bootstrap` Phase 6 emitting
`git commit -m "...with groundrules v1.3.3"` while the plugin was at v1.5.0 — the version was missed at
two releases. The release ritual bumps the `<!-- generated-by: vX.Y.Z -->` **signatures** in
templates/docs, but a version string living *anywhere else* (a commit message, prose, an example) is not
a signature and is not swept, so it silently rots. The same run also surfaced a French comment in
`gitignore.minimal` (an English-only/ADR-0012 violation a verbatim-copied template carried into every
user project).

**When to apply**: when a generated artifact needs to reference the plugin version, make it
**version-agnostic** (drop it — the version lives in `.groundrules.json` + the file signatures) or derive
it, never hardcode a literal `vX.Y.Z` outside the swept signature. More broadly: anything the release
sweep doesn't touch (commit messages, non-signature version mentions, example output, non-English strings
in verbatim templates) needs its own check — a fresh-subagent E2E that *executes* the skill surfaces
these where a static signature/placeholder scan cannot. Fixed both inline; the commit message is now
version-free.

## The maker/verifier loop contract works — but only because the verifier distrusts the test, not just the report

**Why**: 2026-06-14, brick 1 of M1 (PRD `docs/prd/loop-minimal-runnable.md`) built a minimal loop
prototype (`docs/prototypes/loop/`: `maker.md`, `verifier.md`, `LOOP.md`, capped `run-loop.sh`, the
`blocked.md` convention) and validated the contract by **subagent simulation** on a `slugify` fixture
with a pre-written acceptance test (red before code). All three required behaviours held: **(a)
convergence** — maker `DONE` → verifier `PASS` after independently re-running the test and re-deriving
from the diff; **(b) distrust-the-report** — a maker that **gamed the test** (hard-coded the 10 expected
outputs in a lookup table, so `python3 test_slugify.py` was genuinely green 10/10) was still **REJECTed**,
because the verifier tested inputs the acceptance test *doesn't* cover (`slugify("A  B")=="a--b"`,
`slugify("--x--")=="--x--"`) and caught the gap; **(c) park-don't-guess** — on a deliberately
under-specified `max_length` task the maker reported `BLOCKED`, wrote `blocked.md`, touched no code, and
left the task unchecked. The single decisive finding: **a green acceptance test is necessary but not
sufficient — gaming passes it. What caught the gamed diff was the verifier's mandate to re-derive the
*general* behaviour from the diff and probe uncovered inputs**, not the test result. A verifier that only
re-runs the test would have rubber-stamped plausible-but-wrong work (the PRD's headline risk).

**When to apply**: productizing the loop scaffolding into `bootstrap`/`adopt` (brick 2) and
`/groundrules:realize` (brick 3). **Verdict: the contract is good enough to productize**, with these
fixes the simulation surfaced — (1) the **verifier must run as a separate subagent / fresh context**;
the independence is what made the adversarial catch credible, so generated scaffolding should spawn it
separately, not have one agent self-review in the same turn; (2) **the acceptance test is the linchpin
but is not the whole back pressure** — this confirms M1's open questions: `realize` must gate `[loop]`
on a *real* acceptance test **and** the verifier must be allowed to reject work whose test is too weak
to constrain it (a green-but-gamed diff), so "verifier may reject a too-weak test" graduates from open
question to requirement; (3) the runner/`LOOP.md` commit step must **stage the intended diff, never
`git add -A`** (it sweeps `__pycache__`/in-flight `blocked.md`) — ship a `.gitignore` with the
scaffolding. Validation was by simulation (like our skill E2Es); a live `claude -p` run is left to the
user, gated by the runner's hard `MAX` cap (anti-runaway).

## A skill with create + refine flows must branch the WRITE step; baseline-test it against a fresh agent

**Why**: 2026-06-13, the new `/groundrules:vision` passed static checks (placeholders ↔ template, path) but a **fresh-subagent E2E** (an agent who didn't write it follows the SKILL.md on fixtures with canned answers — superpowers' "writing skills IS TDD" #10) caught a real **contradiction**: Phase 3 said "read the template, substitute, write" while Phase 1 said "apply only confirmed section changes". For an *existing* (refine) VISION, following Phase 3 literally would **regenerate the full current template and silently upgrade the header/footer/source line** — overwriting content the user never confirmed. One write step served two flows. The same test also surfaced `<today>` with no source (a headless agent has no date → tell it to run `date +%F`) and an implicit `.new` default. Static checks could not have found any of these.

**When to apply**: authoring any side-effecting skill with a **create vs refine/resume** path — **branch the write step explicitly** (create = substitute-template-then-write; refine = edit only the confirmed sections **in place**, never rebuild from the template). And **baseline-test the skill with a fresh subagent + canned answers before shipping**: it catches contradictions, unsourced values, and ambiguous instructions that placeholder/path checks can't. Proven on our own skill — this is the concrete payoff of borrowing superpowers' #10.

## Patterns mined from superpowers — what to borrow, what to reject

**Why**: 2026-06-13, a deep review of `obra/superpowers`' 13 skills + reviewer prompts (idea #4) surfaced reusable patterns, all expressible as Markdown prompt templates (zero runtime). **Borrow — for loop-readiness (M1)**: a **two-stage ordered verifier** (spec-compliance THEN code-quality); **"don't trust the maker's report — re-derive from the diff"**; an **evidence-before-claim gate** ("can't claim it passes if you didn't run the command this turn"); a **"no placeholders" acceptance bar** for atomic todos (a todo saying "handle edge cases" is a failure); a **maker four-status protocol** (DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT). **Borrow — authoring (Layer A)**: **CSO** — a skill `description:` states *WHEN* to use it, never *WHAT* it does (a workflow-summarizing description makes Claude follow the summary and skip the body); the **rationalization-table + red-flags** hardening format. **Borrow — interviews** (bootstrap/prd/vision): propose 2-3 approaches with a recommendation, decompose over-scoped requests, run a "spec self-review" (placeholder/consistency/ambiguity scan). **Reject** (conflict with our principles): mandatory TDD "Iron Law" and the coercive `<HARD-GATE>` register (violate *handoff-not-gospel* — we keep back-pressure as a loop-regime *precondition*, ADR 0027, not a global mandate); the always-on session-bootstrap skill (runtime-ish, ADR 0025); the git-worktree plumbing and their fixed `docs/superpowers/...` paths (outside our doc-memory scope).

**When to apply**: building **ROADMAP M1** (the verifier/maker contract design note records the loop-specific borrows); auditing our own SKILL.md `description:` fields (CSO); formatting AGENT-EVALS guards (rationalization-table); writing the `/groundrules:vision` PRD (interview principles). Borrow the *structure*, keep our *register* — groundrules proposes, it doesn't impose; never import the coercive tone or runtime mechanisms.

## superpowers creates specs+plans (not "PRDs"); defer realization, add the PRD-altitude above

**Why**: 2026-06-13, verified against the `obra/superpowers` source (not a summary). It never uses the term "PRD". It produces two artifacts: a **spec / design doc** at `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` (technical: data model, server/frontend changes, an `## Out of Scope` section) and an **implementation plan** at `docs/superpowers/plans/YYYY-MM-DD-<feature>.md` (bite-sized TDD tasks with real code). It **imposes TDD hard** ("The Iron Law: NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST", RED→GREEN→REFACTOR) and a two-stage **verifier** (spec-compliance + code-quality reviewer subagents). Confirmed the same layout on a real project. The specs cover context+decisions+design+scope but have **no risks, no measurable success criteria, no acceptance criteria** — that altitude is genuinely empty.

**When to apply**: whenever reasoning about the superpowers interop (the `/groundrules:prd` deferral, the CLAUDE.md interop note, ROADMAP M1). Defer **the whole realization pipeline** (spec→plan→TDD→verify) to superpowers when present — not just the PRD; groundrules' own loop scaffolding (M1) is for the *non-superpowers* case. groundrules adds value **above** (a PRD: problem framing, success metrics, **risks**) and **around** (durable memory: ADR/LEARNINGS/VISION — the comprehension-debt antidote superpowers lacks), with zero overlap on the design/plan superpowers owns. Detection caveat: superpowers lets the user **override the spec/plan location**, which defeats path-based detection (`docs/superpowers/plans|specs/`) — so on doubt, `/groundrules:prd` should **ask** rather than presume.

## Validate on a fresh bootstrap, not only the dogfood

**Why**: 2026-06-08, the first fresh-project E2E (a kitchen-sink bootstrap in `/tmp`, all docs enabled) immediately caught a `verify-bootstrap` **false positive on `.gitignore`** ("signature missing") that the dogfood **structurally could not reveal**: the dogfood's `.gitignore`, `CLAUDE.md` and `README.md` are *foreign* files (in `skippedFiles`), so verify never checks them — yet a real bootstrap puts `.gitignore` in `generatedFiles`. Every real user would have hit the spurious warning; the dogfood was blind to it.

**When to apply**: before shipping changes to `bootstrap` / `verify-bootstrap` / the templates, run a **fresh-folder bootstrap→verify** (enable all docs to exercise every template), not just `verify` on the dogfood. The dogfood only validates the layer-B docs it *owns*; it cannot catch bugs in the generation or verification of files it adopted as foreign.

## Updating a Claude Code plugin is two steps — marketplace update ≠ plugin update

**Why**: 2026-06-08, the maintainer ran `/plugin marketplace update claude-code-groundrules` after each release and restarted — but stayed stuck on plugin **1.1.0 across two releases** (1.2.0, 1.3.0). `marketplace update` refreshes only the *catalog* (`~/.claude/plugins/marketplaces/…`); the *installed* plugin (`~/.claude/plugins/cache/…/<version>/`) is unchanged until you explicitly reinstall/update it. So `/groundrules:checkpoint` and `/groundrules:slim` never appeared, and a restart just reloaded the old version.

**When to apply**: shipping or advising any plugin update — it's **two steps**: (1) `/plugin marketplace update <marketplace>`, then (2) `/plugin install <plugin>@<marketplace>` (or `/plugin` → Update). And a **new skill** (new directory) needs a **full restart**, not just `/reload-plugins`. To diagnose "command missing", check the *installed* version on disk: `ls ~/.claude/plugins/cache/<marketplace>/<plugin>/`. Enabling marketplace auto-update avoids the trap. Captured in the README "Updating the plugin" section + the skills' Phase 0 notices.

## When a template/format changes, sweep the skills that read or write it

**Why**: 2026-06-08, the `LEARNINGS.md` template moved to the rule format (*Why* + *When to apply*) in ADR 0019, but `skills/learn/SKILL.md` kept emitting the old `Context/Lesson` shape — the coupling was missed for two releases, so `/groundrules:learn` silently produced stale-format entries until caught while building `/groundrules:checkpoint`.

**When to apply**: whenever you change a template, a file format, a placeholder, or a `.groundrules.json` field — immediately `grep` for every skill and doc that *produces or consumes* it (here: any skill that writes `docs/LEARNINGS.md`). A format lives in more than one place: the template **and** the skills that fill it. Bump them together.

## Anchor agent rituals to observable events, never to "session end"

**Why**: 2026-06-08, the agent-evals work shipped a "session close" ritual as a passive
`CLAUDE.md` instruction ("before ending a session, capture…") and called it a *forcing
function*. The user pointed out it would never fire: an agent **cannot perceive that a
session is ending** (no model-visible signal; `CLAUDE.md` loads at *start* only; `SessionEnd`
hooks fire too late and can't drive an agent turn). A "forcing function" with no perceivable
trigger forces nothing — it just reads well in the file.

**When to apply**: when designing any agent convention/ritual, anchor it to a **boundary the
agent actually flows through and can act on** — a tool call it's about to make (`git push`,
tag, release), a completed `PLAN.md` milestone — not to an unobservable lifecycle moment.
The fix here: re-anchored capture to "before a push/release", wired concretely into the
`RELEASE.md` pre-release checklist (cf. ADR 0022). Rule of thumb: if the trigger isn't a
thing the agent *does* or *reads*, it won't happen.

## Reference sweeps must exclude historical records

**Why**: during the crm-heyjoe `tasks/` → `docs/specs/` rename (2026-06-07), a blind `tasks/ → docs/specs/` sweep across all Markdown rewrote a **past CHANGELOG entry** — it then claimed the consolidation had moved `docs/specs/todo.md` → `PLAN.md`, a path that never existed at that time. History was falsified silently; caught only by re-reading the diff.

**When to apply**: any bulk path-rename sweep (adopt consolidate, migrate renames, manual refactors). Exclude or hand-review: past CHANGELOG entries, `migrations`/`migratedFiles` records, dated ADRs and logs — they describe old paths *truthfully*. Sweep only living references (current docs, code, configs). The adopt SKILL Phase 4b now carries this guard.


## 2026-06-03 — Ecosystem interop: compare by altitude, not by name

**Context**: Asked whether starter-kit's `PLAN.md` / `docs/VISION.md` duplicate superpowers' `docs/superpowers/plans/` and `specs/`. Both have "plan" and "design/vision" artifacts, so on names they look like duplicates.
**Lesson**: When checking overlap between two tools, compare **altitude (project vs feature) and lifecycle (durable/hand-curated vs volatile/agent-generated)**, not just the noun. starter-kit = durable project memory (the *why*); superpowers = per-feature working docs of a TDD loop (the *how*). The only real friction was `PLAN.md` (one rolling "now" view) vs per-feature plan files — resolved by *referencing* not *duplicating*. Default to documenting the division of labor (a conditional note in the CLAUDE.md template) rather than changing behavior — cheaper and doesn't presume the other tool is present.

## 2026-05-11 — Verify-bootstrap regex must be whitelist, not catch-all

**Context**: First E2E run of `/starter-kit:verify-bootstrap` on the dogfood (V0.6). Initial regex `\{\{[A-Z_]+\}\}` flagged 4 files as having "unsubstituted placeholders" — but they were all *documentation* references like `` `{{KEY}}` `` in backticks (PLAN.md mentioning a future hook, CHANGELOG describing the feature, etc.).
**Lesson**: When validating a templating output, use a **whitelist of real placeholder names** (`PROJECT_NAME`, `DESCRIPTION`, `LANG`, etc.), not a catch-all pattern. Documentation about placeholders is a normal occurrence in a self-aware project; the validator must distinguish "documentation of `{{KEY}}` as a concept" from "actual `{{KEY}}` that should have been substituted."

## 2026-05-11 — YAML frontmatter forces signature placement after closing `---`

**Context**: Same E2E run. `.claude/rules/plugin-meta.md` was flagged as "signature absente" even though it had the right signature — but on line 7, after the YAML frontmatter (`---\npaths:\n  - "..."\n---`). The verify-bootstrap script only scanned `head -6`.
**Lesson**: Rules, skills, and any file requiring YAML frontmatter at line 1 **cannot** carry an HTML signature on line 1. Convention: place the signature on the line **immediately after the closing `---`**, and the validator must scan at least the first **10 lines** to find it. Generators (e.g., `apply-best-practices` creating `.claude/rules/*.md`) must follow the same convention.

<!-- Example:

## YYYY-MM-DD — Short title

**Context**: what we were doing.
**Lesson**: what we learned, and how to apply it next time.

-->
