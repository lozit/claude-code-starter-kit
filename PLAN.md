<!-- generated-by: groundrules v1.11.0 -->
# PLAN — groundrules

**Active** plan/todo for the project. Maintained by Claude during work.

This file differs from the long-term roadmap: it describes what is happening **now**.

## In progress

- [ ] *(empty)*

- [ ] **Give the sharpened case 2 a rate** — it was sharpened on 2026-09-09 and discriminates on its first run (6/6 with the plugin, 4/6 isolated), but one run is not a rate and the old 3/3 does not carry to a changed case. Three runs of each arm makes its entry `probed` again ([ADR 0043](docs/decisions/0043-probed-not-validated.md)). Superseded framing: — it passes on both arms, so it does not discriminate; its entry is `probed` on the missing-command instance, which is honest but thin. Either move it onto something only this repo knows, or accept the guard as one the model no longer needs. Older framing: — the first pass ran all three on 2026-09-09. Cases 1 and 3 do what they were written to do (5/5 and 4/4 with the plugin; case 3's isolated baseline fails three expectations, a real delta; case 1's baseline is inapplicable by shape). **Case 2 passed on both arms**, so it does not discriminate: either sharpen it onto something only this repo knows, or accept that its `docs/AGENT-EVALS.md` guard is one the model no longer needs. Then run each case three times, which is what turns a green into a rate and is the precondition for any entry moving to `validated`. Older framing: — case 3 ran once on 2026-09-09 (with-plugin 4/4, isolated baseline 3 failures, a real delta), which is the suite's first signal but not a rate. Three runs per case is `skill-creator`'s default for the non-determinism, and no `docs/AGENT-EVALS.md` entry moves to `validated` on one green. Cases 1 and 2 are unexecuted; case 1's baseline arm is expected to be meaningless, since its question is about files a shielded arm cannot reach — if so, record that a baseline does not apply uniformly across case shapes. No longer blocked ([ADR 0042](docs/decisions/0042-skill-creator-harness-as-the-runner.md)). The three cases are transposed to `evals/evals.json` and the harness (`skill-creator`, paired runs with and without the plugin) needs no early access. **Still never executed.** Expect the first run to be about the *method* — does the baseline arm actually differ, do the expectations grade cleanly — before it is a signal about the agent. Only after a case has run, repeatedly and green, may its `docs/AGENT-EVALS.md` entry move to `validated`; that is the outstanding half of [ADR 0037](docs/decisions/0037-executable-evals-over-agent-config.md).

- [ ] *(empty)*

## Up next

- [ ] *(empty)*


> **Long-term milestones moved to [`docs/ROADMAP.md`](docs/ROADMAP.md)** — M1 *Loop-readiness* (loop scaffolding opt-in, `/groundrules:realize`, triage convention; ADR 0027) and M2 *Multi-harness support*. They enter "In progress" here, and get a PRD/ADR, only when actively tackled.

<!-- Triaged 2026-06-08: stale items removed (already implemented): migrate 00-VISION rename; verify-bootstrap adopted projects.
     Closed as won't-do (ADR 0025): PreToolUse {{KEY}} hook; /watch-bootstrap. -->

## Ideas — to triage

Raw ideas, captured before they're lost. Not yet vetted. Each gets triaged later → a **decision** (ADR), a **build** (PRD), a **milestone** (ROADMAP), or dropped.

- [ ] *(empty — both 2026-06-14 authoring wins done: CSO description audit + AGENT-EVALS guard hardening format → Recently done)*

<!-- 2026-06-13 first batch triaged: #1 dashboard -> ROADMAP M3; #2 vision & #3 adopt-analysis -> Up next; #4 superpowers research -> done (LEARNINGS + ROADMAP M1). -->


## Waiting / blocked

- [ ] ...

## Recently done

- [x] **Case 2 sharpened, and it now discriminates** (closes the decision `evals/README.md` had left open). Its first form passed on both arms, measuring general knowledge of Claude Code rather than this plugin's configuration. The prompt now carries a **checkable false premise** — the user's colleague dates `/groundrules:close` to 1.10.0, when it shipped in 1.11.0 — verifiable from this repository and unknowable without it. First run: **6/6 with the plugin**, which corrected the premise and proved it against both tags, against **4/6 on the isolated baseline**, which never questioned the figure and invented a verification path for a directory layout the plugin does not use. — under `[Unreleased]` (2026-09-09)

- [x] **`validated` retired — [ADR 0043](docs/decisions/0043-probed-not-validated.md)** (amends [ADR 0037](docs/decisions/0037-executable-evals-over-agent-config.md) decision 2). An entry names a behavioural *class*; a case grades one *instance*; the class recurred on 2026-09-08, six days before its case went green 3/3 — so `validated` would have read green while the guard was failing. Vocabulary is now `watching` / `probed: <case>, N/N since <date>`, and a recurrence does not falsify a probe, it records that the class failed elsewhere. Cases 2 and 3 make their entries `probed`; case 1's green stays discounted. Nothing changes for users — the shipped template only ever used `watching`. — under `[Unreleased]` (2026-09-09)

- [x] **Both loop-verifier defects fixed — [ADR 0044](docs/decisions/0044-runner-enforces-verifier-isolation.md)** (found by `evals/` case 1). `run-loop.sh` now runs **two** invocations per iteration, a maker pass then a **separate** verifier pass with a fresh context, so the loop's central guarantee is produced by the runner instead of requested by a prompt. The maker no longer commits or reviews; the verifier finds its own inputs, judges the working tree and holds the write. `validate-runner.sh` **asserts the split** — six calls for three iterations, one when the backlog empties — so the defect cannot come back silently. The preamble's *"nothing else"* is reworded to bar the maker's narration rather than the artifacts its own checks 5 and 7 require. The prototype stays frozen at the one-invocation shape, and its README says so. — under `[Unreleased]` (2026-09-09)

- [x] **Eval suite transposed to a runner that actually runs** ([ADR 0042](docs/decisions/0042-skill-creator-harness-as-the-runner.md), amends [ADR 0037](docs/decisions/0037-executable-evals-over-agent-config.md) decision 1): `claude plugin eval` stayed gated through three checks, including after installing `skill-creator` and restarting, so the suite moved to that plugin's own harness — paired runs with and without the plugin, aggregated over repetitions, no gate. The three cases became `evals/evals.json`; the CLI-format files were **deleted rather than kept in parallel**, since maintaining an unverified container for an unavailable runner is the abstraction ADR 0034 refuses. — under `[Unreleased]` (2026-09-09)

- [x] **First three eval cases authored** (implements [ADR 0037](docs/decisions/0037-executable-evals-over-agent-config.md)): `evals/` holds one case per `Status: watching` entry of `docs/AGENT-EVALS.md` — the layer A/B confusion, the restart advised without checking the installed version, and the trigger asserted without verification. Each pairs an LLM judge carrying the guard's rubric with a deterministic grader as a floor under it. Running them is blocked and tracked above; the gate itself became a fourth `AGENT-EVALS` entry, since adopting the runner on the strength of its `--help` is the very reflex the third case grades. — under `[Unreleased]` (2026-09-08)

- [x] **`close` acceptance pass — five cases exercised, seven instruction defects fixed**: two throwaway git repositories and two fresh subagents running `skills/close/SKILL.md` blind. All five of the brief's cases pass — an in-progress item whose work is in the diff is proposed for ticking; a diff matching nothing open proposes nothing and writes nothing; an item linked to the change only through a file it names as *raw material* is not ticked; only `PLAN.md` and `CHANGELOG.md` (via `git diff`) are read; the generated `CLAUDE.md` names the command. The runs found what review had not: the baseline's topic-branch rule yields an **empty window on the default branch** (silent false "nothing changed", verified here), the no-tag fallback named a **count where a ref is needed**, and *"a path is a match"* contradicted *"a filename is not a match"* one paragraph later. Fixed, plus a *leave as is* outcome, tick-supersedes-rewrite, and commit subjects demoted to pointers. Rule captured in `docs/LEARNINGS.md`. — under `[Unreleased]` (2026-09-08)

- [x] **`/groundrules:close` shipped — [ADR 0038](docs/decisions/0038-close-reconcile-plan-against-diff.md)** (implements `intake/2026-09-08-close-the-session-update-the-context.md`): reconcile `PLAN.md` against the diff since a baseline, proposal shown as a diff, one-gesture confirmation, matching on what changed and never on a filename, `PLAN.md` + git and nothing else. Checkpoint lists (generated template + meta) name it; `checkpoint`'s recap points to it; README skill 15 + a *Reconciliation over reminders* practices row. — under `[Unreleased]` (2026-09-08)

- [x] **Evals ADR written — [ADR 0037](docs/decisions/0037-executable-evals-over-agent-config.md)** (tensions 1 & 2 of the AI-native SDLC brief, source read): adopt `evals/` + `claude plugin eval`, **out of band** so ADR 0025 stands untouched; `docs/AGENT-EVALS.md` keeps the word and **feeds** the cases; **native case format adopted as-is** — portability is a property of what we *generate*, not of how we *test*, and the system under test is already a Claude Code plugin. Nothing generated for users, CI deferred with its reason. — under `[Unreleased]` (2026-09-02)

- [x] **AI-native SDLC brief — tensions 3 & 4 closed** (`intake/2026-09-02-ai-native-sdlc-evals-and-verification.md`): the loop's verifier now states **what it is handed** (task line + pre-written acceptance test + diff, and nothing that carries the author's framing) in the shipped template *and* the prototype, which also loses the stale "at minimum, switch frame" fallback; separation of duties for a solo operator recorded in [ADR 0036](docs/decisions/0036-git-workflow-corrected.md) (`enforce_admins` is the mechanism, no ceremony). — under `[Unreleased]` (2026-09-02)

- [x] **Git workflow ADR corrected against the machine — [ADR 0036](docs/decisions/0036-git-workflow-corrected.md)** (supersedes [ADR 0028](docs/decisions/0028-git-workflow-conventions.md)): `main` is protected (PR required, `enforce_admins`, no force-push) so the model is **short branch + self-merged PR**, not trunk-based direct push; and AI attribution is **forbidden** here (global `CLAUDE.md`), which 0028 wrongly claimed no rule did — now recorded in-repo as `policies.noAiAttribution: true` in `.groundrules.json` (dogfoods ADR 0011). Boundary commits unchanged, no history rewrite. Meta `CLAUDE.md` + CHANGELOG updated — under `[Unreleased]` (2026-09-02)

- [x] **Released V1.10.0 — posture & positioning, harvested from the field** (no new skill, no runtime): generated `CLAUDE.md` `## Posture` gains a third axis **"Keep the diff small"** (simplicity first / surgical changes / clean up only your own mess), question-led per ADR 0032, from [karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) — [ADR 0034](docs/decisions/0034-posture-keep-the-diff-small.md); recorded decision to **decline auto-capture memory** (claude-mem class), reaffirming ADR 0020/0021/0025, with a `CONTEXT-ECONOMY` contrast section + README leaves-out line — [ADR 0035](docs/decisions/0035-no-auto-capture-memory-layer.md); the **canary** adherence probe documented in `CONTEXT-ECONOMY` (detective complement to the <200-line budget; root canary tests saturation not compaction; we generate none — opt-in). README "Established practices" gains a small-surgical-diffs row. 105 signatures swept, pushed + tagged + GitHub release. (2026-07-23)

- [x] **Released V1.9.0 — `adopt` Full adoption mode** (implements [ADR 0033](docs/decisions/0033-adopt-full-mode.md)): third adoption strategy alongside map-in-place and consolidate, for a project you fully own — reformat by default, `git rm` merged sources for a clean canonical layout, Call 3b completeness pre-check, all behind a single grouped confirmation (Phase 3 recap is the gate, never per-file, never silent). Selectable via Call 1 option + a `--full` flag (composes with `--dry-run`). `adoptionMode` gains `"full"`. Reuses the consolidate Phase 4b mechanics (ADR 0018), no new skill. 103 signatures swept, pushed + tagged + GitHub release. (2026-06-26)

- [x] **Released V1.8.0 — `/goal` interop surfaced** (implements [ADR 0031](docs/decisions/0031-goal-interop-swappable-loop-executor.md), PRD `docs/prd/goal-interop.md`): `realize` recap emits both launch options per `[loop]` task (light `/goal "<command-based condition>"` + high-fidelity `run-loop.sh`, choose-by-stakes); "Two ways to run the loop" in generated `loop/README.md`; two-fidelity explanation in README; QUICKSTART/TUTORIAL pointers; `run-loop.sh` header note. Docs + recap only (no runtime/detection/skill). Fresh-subagent validation 5/5 surfaces + 3/3 critical checks. 107 signatures swept, pushed + tagged + GitHub release. (2026-06-23)

- [x] **Released V1.7.0 — premortem & anti-sycophancy** ([ADR 0032](docs/decisions/0032-premortem-anti-sycophancy.md)): new skill **`/groundrules:premortem`** (assume-it-failed adversarial pass — the reflection-side twin of the loop verifier) + premortem hint in `PRD.md.tpl` Risks + Posture pointer in `CLAUDE.md`; README sycophancy row refreshed with **verified** 2026 evidence (Science ~50%, AISI reframing>instruction) alongside Sharma 2023, honest sourcing (no "+30% on LLM"). + field-test fix (commit the acceptance test before the loop) + README intro hook. 106 signatures swept, pushed + tagged + GitHub release. Skill validated by a fresh-subagent run (non-rubber-stamp; 5 issues fixed incl. a real contradiction). (2026-06-20)

- [x] **Released V1.6.1 — loop docs + validation + `/goal` decision** (docs/tests only, no plugin behaviour change): three-tier loop guide `test/loop/` (**QUICKSTART** 5-step everyday flow → **TUTORIAL** build Conway's Game of Life, Go oracle, watch it engage → **WALKTHROUGH** validation reference) + deterministic **`validate-runner.sh`** (stubs `claude`, 11/11) + fixtures; **[ADR 0031](docs/decisions/0031-goal-interop-swappable-loop-executor.md)** `/goal` interop (swappable executor: `/goal` light vs groundrules loop high-fidelity); README "Updating" moved under Installation. 105 signatures swept, pushed + tagged + GitHub release. Each doc validated by a fresh-subagent replay/read. (2026-06-20)

- [x] **Released V1.6.0 — M1 Loop-readiness** (6 bricks, each PRD + adversarial fresh-subagent E2E): opt-in maker/verifier **loop scaffolding** (`loop/` namespace, ADR 0030) · new skill **`/groundrules:realize`** (plan → partitioned `[loop]`/`[supervised]` backlog) · **TDD-before-loop gate** (pre-written red acceptance test, writer ≠ maker) · **backward-crossing convention** (triaging `blocked.md`) · generated `CLAUDE.md` **routes work by regime** (ADR 0027). Prototype validated in `docs/prototypes/loop/`. 94 signatures swept, pushed + tagged + GitHub release. Detail in CHANGELOG `[1.6.0]`. (2026-06-14)

- [x] **2 authoring wins (from superpowers research)** — (1) **CSO audit**: all 12 skill `description:` rewritten WHEN-first (not workflow summaries) + durable rule in `.claude/rules/plugin-meta.md`; (2) **AGENT-EVALS guard hardening**: optional rationalization-table + red-flag format in `AGENT-EVALS.md.tpl` + `checkpoint`. Both Ideas-batch items cleared — under `[Unreleased]` (2026-06-14)

- [x] **Released V1.5.0** — vision skill, content-aware tailoring (retire lean), adoption-log, superpowers research. 74 signatures swept, pushed + tagged + GitHub release. (2026-06-14)

- [x] **`adopt` → opt-in `docs/ADOPTION-LOG.md`** (idea #3 — reframed during PRD: a **feedback log**, not a structural audit). Records what was here + what groundrules did (with *why*) + a Remarks section to annotate and share back to improve the plugin. New `ADOPTION-LOG.md.tpl`, Phase 5b in `adopt`, README row. PRD `docs/prd/adoption-log.md`. **Fresh-subagent E2E** (fresh + resume): self-contained + honest log, resume-safe (`.new`, original intact); caught 2 instruction gaps (generatedFiles destination, `.new`-branch recording), fixed — under `[Unreleased]` (2026-06-14)

- [x] **Content-aware CLAUDE.md tailoring — lean template retired** ([ADR 0029](docs/decisions/0029-content-aware-claude-md-tailoring.md), supersedes 0009). Rewrote `bootstrap` Phase 5 (read global content → omit only covered sections, bias-to-keep, omission list + veto) + `adopt` (content-aware + gap-driven free-zone additions); deleted `CLAUDE.lean.md.tpl`; 0009 superseded-header + index; meta `CLAUDE.md` fixed. **Fresh-subagent E2E** on no/thin/rich globals: all correct (thin → no holes; rich → 5 sections omitted, signature kept, `## Don't` kept) + caught 4 instruction frictions (dead generic-Don'ts clause, coverage threshold, orphan parent heading, leading-newline), all fixed — under `[Unreleased]` (2026-06-14)

- [x] **New skill `/groundrules:vision`** (idea #2) — guided VISION interview, create-if-absent / refine-if-present; PRD `docs/prd/vision-skill.md`; README workflow (skill↔README drift 12/12) + CHANGELOG. **Fresh-subagent E2E** (superpowers #10) on no-vision + thin-vision fixtures: both flows correct (create → clean VISION, name from README H1; refine → no overwrite, `.new`) and it **caught a real bug** (Phase 3 rebuild contradicted Phase 1 edit-in-place on refine) + 3 frictions, all fixed. Captured the authoring lesson in LEARNINGS — under `[Unreleased]` (2026-06-13)

- [x] **Superpowers research (idea #4)** — reviewed its 13 skills + reviewer prompts; borrowable patterns + rejected ones captured in `docs/LEARNINGS.md`; verifier/maker contract design note added to ROADMAP M1; 2 authoring-win ideas spawned (CSO description audit, rationalization-table guards) — under `[Unreleased]` (2026-06-13)

- [x] **Triaged the 2026-06-13 idea batch** — #1 dashboard → ROADMAP M3 (companion-tool, archi caveat); #2 vision skill & #3 adopt-analysis → Up next (PRD); #4 superpowers research → done — (2026-06-13)

- [x] **Git workflow review closed — [ADR 0028](docs/decisions/0028-git-workflow-conventions.md)**: (1) branching neutral in template + trunk-based dogfood; (2) **boundary commits** (completed chunks, Conventional Commits, tag at release — not a mega-commit per release); (3) **AI attribution by default, deferring to any forbidding rule** (global CLAUDE.md / `policies.noAiAttribution`). No history rewrite. Meta `CLAUDE.md` Git workflow section updated — under `[Unreleased]` (2026-06-13)

- [x] **New skill `/groundrules:idea`** — parks a one-line idea in `PLAN.md`'s "Ideas — to triage" inbox (append-only, creates section if absent); `PLAN.md.tpl` + README workflow updated; dogfooded the skill↔README drift check (11/11) — under `[Unreleased]` (2026-06-13)

- [x] **superpowers interop sharpened + README section** for superpowers users; LEARNINGS (verified facts), ROADMAP M1 deferral, `/groundrules:prd` thin-PRD-above + ask-on-doubt — under `[Unreleased]` (2026-06-13)

- [x] **Method captured — [ADR 0027](docs/decisions/0027-reflection-realization-interactive-loop.md)**: reflection vs realization phases; interactive vs loop regimes; the doc as method-agnostic contract; bidirectional frontier crossed on purpose; PRD (build) vs ADR (decision) as reflection outputs; the "could-act ≠ cleared-to-act" guard (back pressure of reflection, reappears in the loop verifier); plan mode as native enforcement. Spun from the *Write Loops, Not Prompts* + variolab intake docs. Created `docs/ROADMAP.md` (M1 loop-readiness, M2 multi-harness); validated the 2026-06-13 AGENT-EVALS guard entry — under `[Unreleased]` (2026-06-13)

- [x] Git workflow point 1 — `CLAUDE.md.tpl` branching note made neutral/fillable + meta `CLAUDE.md` states trunk-based; release-time README-review rule added to meta Versioning — under `[Unreleased]` (2026-06-13)

- [x] README: dropped the Roadmap; added "What the research says" + "References" to show choices are science-driven. Enriched to 5 rows across 3 fields — LLM behavior (context rot, lost-in-middle, sycophancy, <200-line), software-engineering economics (Boehm 1981 → PRD), usability (Nielsen #3 → reversibility) — with two honest caveats labelling established standards (ADRs/Changelog/Conventional Commits) as such, not science — under `[Unreleased]` (2026-06-13)

- [x] Harvested the four-principles doc (intake): `## Posture` (pushback + reversibility) in CLAUDE.md templates + new `/groundrules:prd` skill (superpowers-aware), ADR 0026 — under `[Unreleased]` (2026-06-13)

- [x] **E2E on a fresh project** (kitchen-sink bootstrap in /tmp, all docs) → bootstrap→verify **23/23 PASS**; caught & fixed a real `verify-bootstrap` false-positive on `.gitignore` the dogfood couldn't reveal + a LEARNINGS rule (validate on a fresh bootstrap) (2026-06-08)

- [x] E2E `verify-bootstrap` on the dogfood: **15/15 coherent** after sharpening the placeholder check with an explicit **backtick rule** (backticked `{{KEY}}` = doc reference, ignore; only bare = real leftover) — surfaced 2 false positives in own CHANGELOG/PLAN (2026-06-08)

- [x] Hardened plugin-update docs (two-step: marketplace ≠ plugin) in README + Phase 0 notices; LEARNINGS + AGENT-EVALS capture of the trap — under `[Unreleased]` (2026-06-08)
- [x] New skill `/groundrules:slim` — propose CLAUDE.md optimizations to stay <200 lines (ADR 0024); verify-bootstrap points to it; no CLAUDE.md bloat — under `[Unreleased]` (2026-06-08)
- [x] Team portability: bootstrap + adopt suggest project-scope install (ADR 0023); README note; no CLAUDE.md bloat — under `[Unreleased]` (2026-06-08)
- [x] New skill `/groundrules:checkpoint` (manual capture ritual) + README "Capturing knowledge as you go" + wired the manual trigger into the CLAUDE.md convention (ADR 0022) — under `[Unreleased]` (2026-06-08)
- [x] Dogfooded the checkpoint ritual before pushing: added own `docs/AGENT-EVALS.md` + a LEARNINGS rule (anchor rituals to observable events) — under `[Unreleased]` (2026-06-08)
- [x] Agent-memory article → adopted session-close ritual (CLAUDE.md templates) + optional `docs/AGENT-EVALS.md` (ADR 0022); rejected journal/`.claude/memory`/`@import` auto-load — under `[Unreleased]` (2026-06-08)
- [x] Evaluated graphify (GraphRAG) → interop pointer in `docs/CONTEXT-ECONOMY.md` + optional large-codebase hint in `adopt` (no dependency) — under `[Unreleased]` (2026-06-08)
- [x] Context-economy study → `docs/CONTEXT-ECONOMY.md` + ADR 0021 + "map, not territory" note in CLAUDE.md templates (index over doc-search for own docs) — under `[Unreleased]` (2026-06-08)
- [x] README restructured pitch-before-install (superpowers-inspired) + MIT license — under `[Unreleased]` (2026-06-08)

- [x] V1.1.0 — adopt consolidate mode (ADR 0018) + heyjoe harvest (ADR 0019) + repo-is-the-only-memory (ADR 0020), validated E2E on crm-heyjoe (2026-06-07)
- [x] Post-release: npm name secured (`groundrules@0.0.1` placeholder published, pointer stub) + formal TMview check archived in ADR 0017 (2026-06-06)
- [x] V1.0.0 — full rebrand starter-kit → groundrules RELEASED: repo renamed lozit/groundrules (harness-neutral), manifests, 7 skills + legacy handling, templates, migrate V1.0 pass, dogfood self-migration (2026-06-06)
- [x] V0.12 — best-effort update check (Phase 0, ADR 0015) + marketplace renamed `claude-code-starter-kit` (ADR 0016) + public email + groundrules decision (ADR 0017) (2026-06-06)
- [x] V0.11 — renamed `brief/` → `intake/` (templates, skills, dogfood `git mv`) + migrate rename logic + ADR 0014 (2026-06-06)
- [x] V0.10 — fix: `adopt` always offers optional/specialized docs (Call 3b); add "living docs" maintenance rule to generated CLAUDE.md (2026-06-04)
- [x] V0.9 — moved `media/` → `docs/media/` (avoid collision with project media/public) + migrate move logic + ADR 0013 (2026-06-04)
- [x] V0.7 — optional specialized docs in `bootstrap` (DATA_MODEL, SECURITY, DESIGN_SYSTEM, ROADMAP, I18N) + ADR 0006 (2026-06-03)
- [x] V0.7 — de-number entry docs: `00-VISION.md`→`VISION.md`, `00-INTENT.md`→`INTENT.md` + ADR 0007 (2026-06-03)
- [x] V0.7 — new skill `/starter-kit:adopt` (brownfield) + broadened planning detection (case-insensitive/nested/multiple + collision guard) + ADR 0008 (2026-06-03)
- [x] V0.8 — English-only: dropped FR templates + `{{LANG}}` logic, single `.tpl` per file, all skills/docs translated to English + ADR 0012 (2026-06-04)
- [x] V0.7 — global/enterprise CLAUDE.md awareness: detection + lean template (`CLAUDE.lean.md.tpl`) + `{{GLOBAL_CLAUDE_NOTE}}` + ADR 0009 (2026-06-03)
- [x] V0.7 — defer to tool-managed project CLAUDE.md (no generation, opt-in docs pointer into free zone) + ADR 0010 (2026-06-03)
- [x] V0.7 — detect "no AI attribution" policy → `policies.noAiAttribution` + adapt suggested/made commits (bootstrap/adopt/migrate) + ADR 0011 (2026-06-03)
- [x] V0.6 — `/starter-kit:verify-bootstrap` skill (report ✅/⚠️/❌ + `--fix` for trivial signature bumps) (2026-05-11)
- [x] First real-world run of `/starter-kit:apply-best-practices` on the dogfood (2026-05-11)
- [x] ADR 0005 — Intent capture in bootstrap + separate apply-best-practices skill (2026-05-11)
- [x] V0.5 — intent capture in `bootstrap` + new skill `apply-best-practices` + dogfood backfill of brief/vision (2026-05-11)
- [x] Published to GitHub: https://github.com/lozit/claude-code-starter-kit (public marketplace) (2026-05-11)
- [x] ADRs 0003 (multi-skill architecture) + 0004 (.starter-kit.json schema) (2026-05-11)
- [x] V0.4 — skill `/starter-kit:migrate` with diff-per-file + `.new` fallback + `--dry-run` (2026-05-11)
- [x] V0.3 — skills `/starter-kit:add-adr` and `/starter-kit:learn` (2026-05-11)
- [x] ADRs 0001 + 0002 (2026-05-11)
- [x] V0.2 — `CLAUDE.md.{fr,en}.tpl` restructured with Boris Cherny / shanraisshan best practices (2026-05-11)
- [x] V0.1 — Project bootstrapped, skill + 15 templates + dogfood (2026-05-11)

---

**Convention**: Claude updates this file at the start/end of each session. Completed tasks stay in "Recently done" for ~1 week then are archived (deleted or moved to CHANGELOG).
