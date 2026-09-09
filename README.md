# groundrules

**groundrules lays the documentation backbone of a software project — and keeps it alive.** A Claude Code plugin that interviews you, captures the project's intent, and generates a tailored, opinionated doc structure (vision, decisions, learnings, architecture…), then gives you the skills to maintain it as the project evolves.

> **Opinionated, and it shows its work.** Each choice is sourced — *context rot* / lost-in-the-middle, LLM **sycophancy** (countered with Gary Klein's **premortem**), Michael Nygard's **ADRs**, **TDD** as a loop's back pressure, the *"write loops, not prompts"* shift — and it's explicit about what it **leaves out**: no GraphRAG / *graphify* layer (a small index beats doc-search for your own repo), no auto-captured machine-local memory daemon (the repo is the only memory — it travels with `git clone`), no coercive mandatory-TDD. The receipts: [`docs/decisions/`](docs/decisions/) and [**What the research says**](#what-the-research-says).

## Why

Coding agents rarely fail for lack of information — they fail for lack of the *right* information, structured and at hand. Two forces make that hard, and groundrules is built to answer both:

- **More context isn't better — it's measured.** Research on [*context rot*](https://www.understandingai.org/p/context-rot-the-emerging-challenge) (Chroma, 2025) found every frontier model tested — Claude included — degrades as the input grows; the classic *lost in the middle* effect drops accuracy **30%+** for anything buried mid-window. [Anthropic's own guidance](https://code.claude.com/docs/en/memory) agrees: keep `CLAUDE.md` **under 200 lines**, because "larger files produce lower adherence." Stuffing everything into context actively hurts.
- **Knowledge evaporates.** Decisions, conventions, and hard-won lessons end up in chat logs and an agent's volatile memory — gone by the next session, invisible to the next contributor.

groundrules' answer is a *method*, not just a folder of templates: **write everything down on disk, load almost none of it.** It generates a small always-loaded index (`CLAUDE.md`) that points to exhaustive docs read **on demand**, an ADR trail for the *why*, a rule-format learnings journal, and the discipline that **the repo is the only memory**. Exhaustive storage, minimal loading — the agent gets precisely what each task needs and nothing it doesn't.

**What it buys you:**

- **Sharper agents** — a small, current index plus on-demand reads keeps attention undiluted and adherence high, instead of a bloated always-on file.
- **Knowledge that survives** — decisions, conventions and lessons live in the repo, available to the next session, the next contributor, and any agent — not trapped in one chat.
- **Lower token cost** — exhaustive on disk, minimal in context: you don't pay to carry the whole project every turn.
- **No lock-in** — it's plain markdown; the structure stays readable and useful even without the plugin.
- **Docs that don't rot** — living-docs discipline, checkpoint capture, and `/groundrules:slim` keep the backbone current and under budget over time.

The full reasoning and token economics: [`docs/CONTEXT-ECONOMY.md`](docs/CONTEXT-ECONOMY.md) ([ADR 0021](docs/decisions/0021-context-economy-index-over-doc-search.md)).

## Built for the age of loops

The way people drive coding agents is shifting from **prompts to loops**: instead of typing each prompt, you run a loop that restarts the agent from a *fresh* context every iteration and lets the **repo** — not the model — carry the memory. Claude Code's creator [puts it plainly](https://www.youtube.com/watch?v=SlGRN8jh2RI): *"I don't prompt Claude anymore… my job is to write loops."* The [technique](https://ghuntley.com/ralph/)'s slogan is blunter still: **the model forgets, the repo remembers.**

That is groundrules' thesis, arrived at independently — and the **same [context-rot](https://www.understandingai.org/p/context-rot-the-emerging-challenge) research** underwrites both: a short, fresh context each turn isn't a compromise, it's the goal. A loop only survives its amnesiac restarts on **durable, on-disk state** — a vision of what to build, a plan checked off run after run, lessons so it stops repeating mistakes, decisions for the *why*, and git for what's done. **That state is exactly what groundrules generates.** It makes a repo *loop-ready*: the structure a loop re-reads at the start of every iteration.

And it answers the paradigm's sharpest risk. Loops ship code fast, but they accrue **comprehension debt** — code that exists and works, yet no human ever read. groundrules' ADR trail, learnings journal, and the *why* it preserves are the antidote: **loops write the code fast; groundrules keeps the understanding of the code.**

> Today groundrules is the **memory + reflection layer** a loop runs on — and ships **opt-in loop scaffolding** (`loop/`: a maker/verifier split with an independent, report-distrusting verifier, a capped runner, and a loop-safe backlog; off by default, offered by `bootstrap`/`adopt`), plus **`/groundrules:realize`** (turn an approved plan into a partitioned backlog, gated on a pre-written red acceptance test). **New to it? [`test/loop/QUICKSTART.md`](test/loop/QUICKSTART.md)** is the everyday flow in 5 steps (blank project → bootstrap → ask in chat → set a red test → run). Go deeper with [`TUTORIAL.md`](test/loop/TUTORIAL.md) (build Conway's Game of Life and watch the loop *engage*), or see the validation reference in [`WALKTHROUGH.md`](test/loop/WALKTHROUGH.md). **Two ways to run it, by stakes** ([ADR 0031](docs/decisions/0031-goal-interop-swappable-loop-executor.md)): Claude Code's native **`/goal`** is the *light* loop (one self-evident, command-verifiable task; its evaluator judges the transcript), the **groundrules loop** (`run-loop.sh` + maker/verifier) is the *high-fidelity* one (whole backlog, fresh context, the verifier re-runs the oracle, parks decisions) — groundrules writes the goal either way; only the runner differs. Decisions: [ADR 0027](docs/decisions/0027-reflection-realization-interactive-loop.md), [ADR 0030](docs/decisions/0030-loop-namespace-and-backlog.md); the [roadmap](docs/ROADMAP.md).

## How it works

It starts the moment you run `/groundrules:bootstrap` in a fresh folder.

groundrules **interviews you** — a handful of grouped questions about the project's name, type, stack, and intent. It captures that intent (you paste a brief, point to a file, or answer an interview), synthesizes it into a `docs/VISION.md`, and generates a documentation backbone *tailored to your answers*: a `CLAUDE.md` that fits the project, an ADR folder for decisions, a learnings journal, a plan, and only the specialized docs you actually need (data model, security, design system, release runbook…). Then it `git init`s, makes the first commit, and — if you asked — creates the remote.

From there, **the project is alive**. As you work, `learn` and `add-adr` capture knowledge where it belongs; `apply-best-practices` pulls fresh practices from the community and tailors them to your vision; `verify-bootstrap` checks coherence; and when the plugin itself improves, `migrate` brings your project up to date without ever overwriting your work. Already have a project? `adopt` brings it under management — and can consolidate an existing layout onto the canonical one.

The throughline: **knowledge lives in the repo, structured and current** — not in scattered notes or an agent's volatile memory.

## Installation

In Claude Code:

```bash
/plugin marketplace add https://github.com/lozit/groundrules
/plugin install groundrules
```

From a local clone, or for fast iteration without installing:

```bash
/plugin marketplace add /path/to/groundrules
/plugin install groundrules@claude-code-groundrules
# or, dev mode:
claude --plugin-dir /path/to/groundrules
```

> **Working in a team / shared repo?** Install at **Project scope** (choose *Project*, not *User*, during `/plugin install`). This commits the plugin reference to `.claude/settings.json`, so anyone who clones and trusts the repo is prompted to install it — the `/groundrules:*` commands then work for everyone. The plugin does **not** travel with a `git clone` otherwise; a user-scope install is per-machine. (The generated docs are plain markdown and remain readable without the plugin — only the slash-command ergonomics need it. See [ADR 0023](docs/decisions/0023-project-scope-for-team-portability.md).)

> groundrules is a Claude Code plugin today. Extending it to other harnesses is a planned direction — the repo is named `groundrules` (harness-neutral) for that reason.

## Updating the plugin

Updating is **two steps** — and skipping the second is the most common trap.

```
# 1. Refresh the marketplace catalog — this does NOT update your installed plugin
/plugin marketplace update claude-code-groundrules

# 2. Update the installed plugin itself — the step people miss
/plugin install groundrules@claude-code-groundrules     # re-installing pulls the new version
# (or: /plugin → select groundrules → Update)
```

Then **restart Claude Code**. A *new* skill ships in its own directory and only registers on a **full restart** — `/reload-plugins` alone surfaces edits to existing skills, not a brand-new command.

> **Why two steps?** `/plugin marketplace update` only refreshes the *catalog*; your *installed* plugin stays on its old version until you explicitly reinstall/update it. If a new command (e.g. `/groundrules:slim`) doesn't appear even after a restart, you almost certainly did step 1 but not step 2. Check the version you actually have: `ls ~/.claude/plugins/cache/claude-code-groundrules/groundrules/`.

To avoid the trap entirely, turn on auto-update: `/plugin` → **Marketplaces** tab → select `claude-code-groundrules` → **Enable auto-update**.

`bootstrap`, `adopt` and `migrate` also run a **best-effort update check** when invoked (single `git ls-remote`, ~3s timeout, silent when offline) and print a notice if a newer version is published. To update an already-bootstrapped **project** after updating the plugin, run `/groundrules:migrate` in that project.

## The workflow

Seven skills ordered by a project's lifecycle, plus eight cross-cutting skills:

1. **`bootstrap`** — *new, empty folder.* Interview + intent capture (paste / file / interview) + from-scratch generation of the whole structure, `git init`, optional remote. Run it on a folder that already holds someone else's files and it says so, points you at `adopt` first, then offers to continue anyway — it never refuses, and never pretends there is prior state to resume ([ADR 0040](docs/decisions/0040-three-bootstrap-modes.md)).
2. **`adopt`** — *existing (brownfield) project.* Scans, maps existing files to roles, generates only what's missing, backfills `.groundrules.json`. Map-in-place never overwrites; supports `--dry-run`, a **consolidate** mode that migrates an existing layout onto the canonical paths (per-file), and a **full** mode (`--full`) that consolidates *and* reformats everything onto the canonical layout behind a single grouped confirmation — for a project you fully own.
3. **`learn`** — *after a correction or a discovery.* Adds an actionable rule to `docs/LEARNINGS.md` (*Why* + *When to apply*).
4. **`add-adr`** — *a structural decision is made.* Creates a numbered ADR and updates the index.
5. **`apply-best-practices`** — *want outside input.* Fetches the up-to-date `shanraisshan/claude-code-best-practice` and proposes recommendations tailored to your `docs/VISION.md`. (The only skill that needs the network.)
6. **`verify-bootstrap`** — *sanity check.* Validates signatures, leftover `{{KEY}}` placeholders, CLAUDE.md size, valid JSON, git. `--fix` for trivial corrections.
7. **`migrate`** — *the plugin has a new version.* Per-file diff, never overwrites without confirmation, chains historical renames, `--dry-run`. **A migration never damages a file that was correct** ([ADR 0041](docs/decisions/0041-a-migration-never-damages-a-correct-file.md)): an unresolved `{{KEY}}` is never written into your file, `Overwrite` is not offered on the files your project writes into (`PLAN.md`, `CHANGELOG.md`, `LEARNINGS`, `docs/decisions/`…) nor on a file whose version signature contradicts the state file, and the diff is taken against what `bootstrap` would generate for *your* project rather than the raw template.
8. **`checkpoint`** — *any time, especially before a push.* Runs the capture ritual (see below).
9. **`slim`** — *when `CLAUDE.md` approaches 200 lines.* Proposes concrete optimizations to stay under budget — extract a bulky section to `docs/`, move file-type rules to `.claude/rules/` (loaded on demand), compress, de-duplicate. Moves content, never deletes it. (`verify-bootstrap` points here when it flags the size.)
10. **`prd`** — *before a non-trivial feature.* Writes a per-feature PRD (problem, success criteria, scope, constraints, build plan, risks) to `docs/prd/<feature>.md`, so the agent builds the right thing. **Defers to superpowers** if that plugin is in use (its per-feature spec altitude).
11. **`vision`** — *the project needs a strong vision.* Builds or refreshes `docs/VISION.md` through a guided interview (goal, users, constraints, non-goals, acceptance criteria) — for an adopted project with no vision, or to deepen a thin one. Create-if-absent / refine-if-present, never overwrites. Complements `bootstrap`'s intent capture.
12. **`idea`** — *a thought you don't want to lose.* Parks a one-line idea in `PLAN.md`'s "Ideas — to triage" inbox, fast. Prospective capture (forward ideas), the complement to `checkpoint`. Triage later → ADR / PRD / ROADMAP / drop.
13. **`realize`** — *you have an approved plan and want to loop part of it.* The forward bridge: partitions the plan into **`[loop]`** (atomic, isolatable) vs **`[supervised]`** tasks and writes the loop-safe ones into `loop/backlog.md`. **Gates `[loop]` on a pre-written, currently-red acceptance test authored separately from the maker** (TDD-before-loop — the loop's back pressure, *not* a global rule); no such test → it stays `[supervised]`. Requires the loop scaffolding (opt-in); **defers to superpowers** when present.
14. **`premortem`** — *before committing to a plan, PRD, ADR, or strategy.* Runs Gary Klein's premortem: assume it **already failed**, list the causes ranked by probability × impact, and name the early signal for each — the reflection-side adversarial pass that beats asking "is this good?" (which invites a sycophantic yes). Offers to fold the result into a PRD's Risks. See [ADR 0032](docs/decisions/0032-premortem-anti-sycophancy.md).
15. **`close`** — *at a checkpoint, or when you close a work session.* Reconciles `PLAN.md` with what actually changed: reads the diff since a baseline (commit subjects, paths touched, the `[Unreleased]` lines added), compares it with the open items, and **shows the edit as a diff** — items to tick, a status sentence the change made false. It **proposes**; one confirmation, never a silent write. It matches on what changed — paths, identifiers, ADR numbers, commit subjects — and **never on a filename**, because a check that cries wolf gets switched off. `PLAN.md` and git metadata, nothing else, so it costs seconds. See [ADR 0038](docs/decisions/0038-close-reconcile-plan-against-diff.md).

## Capturing knowledge as you go

Knowledge is worthless if it evaporates. groundrules captures it at the moments that matter, routed to where it belongs:

- **Decided** something structural → an **ADR** (`docs/decisions/`)
- **Learned** something, or **blocked 30+ min** → a rule in `docs/LEARNINGS.md` (*Why* + *When to apply*)
- **Caught the agent** repeating a mistake, hallucinating, or drifting → `docs/AGENT-EVALS.md` (optional doc) + a guard in `CLAUDE.md`

This **checkpoint-capture ritual** fires two ways. The agent **proposes it proactively** at the boundaries it can perceive — **before a `git push`, tag, or release** (the most reliable moment, also wired into the `RELEASE.md` pre-release checklist) or at a completed `PLAN.md` milestone. And **you can trigger it yourself any time** with **`/groundrules:checkpoint`**. (There's no "end of session" trigger: an agent can't perceive a session ending — so capture is anchored to events it *can* see. See [ADR 0022](docs/decisions/0022-agent-evals-and-session-close.md).) The same reasoning explains its sibling: an agent can't reliably notice, mid-task, that a line in `PLAN.md` just became false — but that drift *is* computable, so **`/groundrules:close`** checks it, comparing the plan against the diff and proposing the edit for you to confirm. `checkpoint` captures *knowledge*; `close` reconciles *status* ([ADR 0038](docs/decisions/0038-close-reconcile-plan-against-diff.md)).

## What's generated

groundrules gives a project a clear geography.

| Folder | Role |
|---|---|
| **`intake/`** | **Raw upstream inputs**, captured as received: client specs, emails, scoping notes, spreadsheets, brand assets. **Read-only** (don't "fix" inputs — synthesize them into `docs/`), binaries welcome. The draft side. |
| **`docs/`** | The **living, synthesized documentation**: vision, architecture, learnings, specialized docs. Where stable knowledge lives and is kept in sync. |
| **`docs/decisions/`** | The **ADRs**: one file per structural decision — context, decision, alternatives, tradeoffs. The *why*, frozen at decision time. |
| **`docs/prd/`** | Per-feature **PRDs** (problem, success criteria, scope, constraints, build plan, risks): one file per feature, written *before* building. Created on demand by `/groundrules:prd`. |
| **`docs/media/`** | **Visual assets** supporting the docs: mockups, screenshots, diagrams (with their editable sources). |
| **`loop/`** *(opt-in)* | **Autonomous loop scaffolding** — a maker/verifier split, a capped runner, and the loop's own backlog. The loop owns this dir; you own `PLAN.md`. Off by default; offered by `bootstrap`/`adopt`. |

The flow: `intake/` (raw, untouched) → `docs/` (synthesized, living) → `docs/decisions/` (the why, frozen). Root files (`README.md`, `CLAUDE.md`, `PLAN.md`, `CHANGELOG.md`, `RELEASE.md`) are the operational surface.

| File | When created | Content |
|---|---|---|
| `README.md` | Always | Public project presentation: title, description, install, usage, structure, doc links. Skeleton to flesh out per the stack. |
| `CLAUDE.md` | Always | Instructions for Claude Code. Mutable and iterative (target < 200 lines): session-start reading order, Setup/Build/Test commands, conventions, "repo is the only memory". |
| `.gitignore` | Always | Minimal, stack-agnostic list: OS (`.DS_Store`…), editors (`.vscode/`, `.idea/`…), logs, `.env`, and common build folders to adapt. |
| `docs/decisions/README.md` | Always | Explains the ADR format (after Michael Nygard): naming convention `NNNN-kebab-title.md` and when to create an ADR. |
| `docs/decisions/0000-template.md` | Always | ADR template to copy: Context, Decision, Alternatives considered, Consequences, Status. |
| `docs/LEARNINGS.md` | Always | Rules learned from corrections: one entry = an actionable rule with *Why* (the story + cost) and *When to apply* (triggers). Fed by `/groundrules:learn`, re-read at session start. |
| `intake/README.md` | Always | Explains the role of `intake/` and its conventions (read-only, binaries welcome, explicit names). |
| `docs/media/README.md` | Always | Explains the role of `docs/media/` with naming and format conventions. |
| `.groundrules.json` | Always | Plugin manifest (not meant for manual editing): version, chosen options, intent, generated/adopted/migrated files. Used by resume mode and `migrate`/`verify-bootstrap`. |
| `PLAN.md` | On by default | **Active** todo maintained by Claude during work: In progress / Up next / Waiting / Recently done, with the `[~]` in-review status vocabulary. Distinct from the long-term roadmap. |
| `docs/VISION.md` | Intent not skipped | **Structured synthesis** of the intent: Goal, Users/personas, Constraints, V1 non-goals, Acceptance criteria. Required by `/groundrules:apply-best-practices`. |
| `intake/INTENT.md` | Intent captured (paste/file) | **Raw source** of the project intent (paste, email, call transcript, PO doc…) before synthesis. |
| `docs/ARCHITECTURE.md` | Code project | **Living** snapshot of the architecture: overview, stack, components and responsibilities. The *why* goes in `docs/decisions/`. |
| `docs/GLOSSARY.md` | Domain jargon | Domain vocabulary, one entry per term, alphabetical — so a new dev (or Claude) understands the domain language. |
| `CHANGELOG.md` | Versioned releases | Change tracking in [Keep a Changelog](https://keepachangelog.com/) + SemVer format. |
| `docs/DATA_MODEL.md` | The project has a database | Entities/tables and their fields, relationships, row-level access rules (RLS), indexes, migrations. |
| `docs/SECURITY.md` | Sensitive / personal data | Authentication, authorization, personal data & GDPR compliance, secrets, attack surface, incident procedure. |
| `docs/DESIGN_SYSTEM.md` | Project with a UI | Principles, colors (tokens), typography, spacing/grid, components, accessibility, where tokens live in the code. |
| `docs/ROADMAP.md` | Long-term trajectory | Milestone breakdown (goal, scope, exit criteria, status). Distinct from `PLAN.md` (active todo). |
| `docs/I18N.md` | Multilingual project | Supported languages and fallback, translation organization, localized formats, translation process. |
| `docs/PROCESS.md` | Phased way of working | The working-method contract: phases, validation gates, interview style, where artifacts live. Claude follows it and never skips a phase. |
| `RELEASE.md` | Project deploys somewhere | Operational release runbook: TL;DR commands, environments table, pre-release checklist, secrets, rollback, known fragilities. |
| `docs/AGENT-EVALS.md` | Long agent-driven project | A log of the **agent's own** failure modes here (recurring mistakes, hallucinations, drifts) + the guard added for each. Distinct from `LEARNINGS.md` (project/domain). Fed by the checkpoint-capture ritual (before a push/release). |
| `docs/ADOPTION-LOG.md` | `adopt`, opt-in | A dated, frozen record of the adopt run — what was here, what groundrules did (and why) — with a **Remarks** section to annotate and **share back to improve groundrules**. A field → plugin feedback channel. |
| `loop/` + `## Invariants` in `CLAUDE.md` | Opt-in (off by default) | **Loop scaffolding**: `maker.md`/`verifier.md` (an independent verifier that distrusts the maker's report), `LOOP.md`, a capped `run-loop.sh` (hard iteration ceiling), and `backlog.md` (loop-safe tasks only). Adds an `## Invariants` section the verifier enforces each iteration, and a **triage convention** for `loop/blocked.md` (the backward crossing: re-decompose / decide → ADR / fix interactively, with a `Resolution:` audit trail). **Not offered when superpowers is detected** (it defers the realization). |

Every generated file carries a `<!-- generated-by: groundrules -->` signature, which enables **resume mode**: re-run a skill on a non-empty folder with no overwrite risk.

## Already using superpowers?

[superpowers](https://github.com/obra/superpowers) and groundrules work at **different altitudes — they don't overlap.** superpowers owns the *realization* of a feature: it turns a conversation into a technical **spec**, a TDD **implementation plan**, and runs a maker/verifier loop to build it. It's excellent at *how to build* — and groundrules **detects it and defers** that whole pipeline to it.

What superpowers deliberately leaves out is exactly what groundrules adds, **without duplicating a line of its design**:

- **The durable *why*** — ADRs, `LEARNINGS`, `VISION`. superpowers' specs and plans are per-feature and volatile; groundrules keeps the stable, hand-curated memory that survives across features and sessions. It's the antidote to the *comprehension debt* a fast build pipeline creates: **superpowers builds the loop, groundrules keeps you the engineer.**
- **The PRD altitude *above* the spec** — problem framing, measurable success criteria, and **risks**. A superpowers spec covers context, design, and scope, but not these; a short `docs/prd/<feature>.md` sits above its spec (`/groundrules:prd` offers just that thin layer when superpowers is present).
- **The cross-cutting "now"** — `PLAN.md` as the single backlog/in-progress view, pointing to the active superpowers plan instead of restating its tasks.

You keep the build pipeline superpowers is great at; you gain the memory and the high-altitude framing it doesn't provide.

**If you don't use it, you won't see it.** The generated `CLAUDE.md` carries an interop section explaining the altitude split — eight lines that are noise for a project without superpowers, so `bootstrap` and `adopt` **detect** the plugin and leave the section out when it isn't there. No extra interview question: detection first, and if it guesses wrong the final recap tells you in one line how to get the section back ([ADR 0039](docs/decisions/0039-conditional-superpowers-interop.md)).

## Philosophy

- **Template over code** — plain `{{KEY}}` text substitution, never a template engine or application logic ([ADR 0002](docs/decisions/0002-plain-text-placeholder-substitution.md)).
- **The repo is the only memory** — project knowledge lives in the repo docs, never in an agent's machine-local memory or scattered notes ([ADR 0020](docs/decisions/0020-repo-is-the-only-memory.md)).
- **Living docs** — every generated doc is kept in sync *in the same change* that makes it stale; maintenance is part of the task, not a follow-up.
- **Never overwrite without confirmation** — resume mode detects what exists and offers skip / overwrite / save-as-`.new`; your edits are safe.
- **Offline-first** — only `apply-best-practices` needs the network; the rest works offline (the update check fails silent).
- **Posture, not just process** — the generated `CLAUDE.md` tells the agent to *push back* (challenge off-strategy/wrong plans, don't be sycophantic) and *stay reversible* (confirm before hard-to-undo actions).
- **A handoff, not gospel** — a generated `CLAUDE.md` is a starting point you edit and enrich, not absolute truth.

The full reasoning behind every structural choice lives in [`docs/decisions/`](docs/decisions/).

## What the research says

groundrules' core choices aren't aesthetic — they follow published findings from three fields: how **language models** behave under load, **software-engineering economics**, and **usability** research. The receipts:

| Choice | What the research shows | Recorded in |
|---|---|---|
| Keep `CLAUDE.md` small; store exhaustively on disk, **load on demand** | Model accuracy **degrades as input grows** — measured across 18 frontier models, Claude included ([*context rot*](https://www.understandingai.org/p/context-rot-the-emerging-challenge), Chroma 2025) — and the *lost-in-the-middle* effect drops accuracy **~30%** for information buried mid-context ([Liu et al., 2023](https://arxiv.org/abs/2307.03172)). Anthropic's own guidance caps `CLAUDE.md` at **< 200 lines** ("larger files produce lower adherence"). | [ADR 0021](docs/decisions/0021-context-economy-index-over-doc-search.md), [`docs/CONTEXT-ECONOMY.md`](docs/CONTEXT-ECONOMY.md) |
| **Index + native read** over a doc-search/RAG layer (for your own docs) | The cost is in *always-loaded* tokens; reading a file natively is cheaper and lossless. A RAG/graph layer earns its keep only for large *external* corpora you can't fit. | [ADR 0021](docs/decisions/0021-context-economy-index-over-doc-search.md) |
| Make the agent **push back** (don't be sycophantic), and reframe instead of asking for validation | Sycophancy is a **general, measured behavior** of state-of-the-art assistants, driven by preference training that rewards agreement ([Sharma et al., Anthropic, 2023](https://arxiv.org/abs/2310.13548)); a 2026 *Science* study across 11 models found they affirm users' actions **~50% more than humans** ([Cheng et al., 2026](https://arxiv.org/abs/2510.01395)). And the *framing* matters: posing a claim as a **question** rather than a statement sharply lowers sycophancy — more than an explicit "don't agree with me" instruction ([AISI, *Ask Don't Tell*, 2026](https://arxiv.org/pdf/2602.23971)). So groundrules pairs a pushback **posture** with a **premortem** technique (`/groundrules:premortem`). | [ADR 0026](docs/decisions/0026-posture-and-per-feature-prd.md) · [ADR 0032](docs/decisions/0032-premortem-anti-sycophancy.md) |
| **Spec a non-trivial feature before building it** (`/groundrules:prd`) | Software-engineering economics has shown for decades that the cost of fixing a defect rises sharply the later it's caught: a misunderstanding corrected **in the spec** is a sentence; caught after the build it costs far more ([Boehm, *Software Engineering Economics*, 1981](https://www.techwell.com/techwell-insights/2013/10/what-does-it-really-cost-fix-software-defect) — the exact multiplier varies with project size). A PRD surfaces the ambiguity early. | [ADR 0026](docs/decisions/0026-posture-and-per-feature-prd.md) |
| **Stay reversible** — confirm before hard-to-undo actions, keep an escape hatch | "User control and freedom" is one of Nielsen's foundational usability heuristics: people *will* act by mistake and need a clearly-marked exit and undo ([NN/g](https://www.nngroup.com/articles/ten-usability-heuristics/)). For an agent acting on your repo, that exit is git + `/rewind` + confirm-before-destructive. | [ADR 0026](docs/decisions/0026-posture-and-per-feature-prd.md) |

One honest caveat — so this stays evidence, not marketing: the rest of the design — *the repo is the only memory*, living docs, never-overwrite — follows from a plain fact (agents are **stateless** across sessions, and their window degrades *within* one) plus engineering prudence, not a single paper. And some choices aren't lab findings at all but recognized *standards* — those have [their own section below](#established-practices-we-adopt), kept separate on purpose.

The reasoning for every choice is recorded in [`docs/decisions/`](docs/decisions/).

## Established practices we adopt

Not everything here is a research result — and we won't pretend it is. Some choices are recognized engineering **standards**: proven in practice, widely understood, no lab paper needed. We adopt them *because* they're established, and label them as such.

| Practice | Why we adopt it | Reference |
|---|---|---|
| **ADRs** — one short file per structural decision | Captures the *why* of a decision in a durable, greppable form, so the reasoning outlives the people who made it. Michael Nygard's format is the de-facto standard. | [Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) · [`docs/decisions/`](docs/decisions/) |
| **Keep a Changelog** — a curated, human-readable history | `git log` is a transcript, not a summary; a hand-curated changelog tells a *person* what actually changed between versions. The `[Unreleased]` accumulator keeps it current without per-commit churn. | [keepachangelog.com](https://keepachangelog.com/en/1.1.0/) · [`CHANGELOG.md`](CHANGELOG.md) |
| **Conventional Commits** — `feat:` / `fix:` / `docs:` … | A predictable commit grammar makes history scannable for humans and parseable for tooling (automated changelog, version bumps). | [conventionalcommits.org](https://www.conventionalcommits.org/) |
| **Semantic Versioning** — `MAJOR.MINOR.PATCH` | A version number that *means something*: consumers can tell at a glance whether an update is a fix, a feature, or a breaking change. | [semver.org](https://semver.org/) |
| **Test-Driven Development** — a failing test *before* the code (**loop regime only**) | When a task is handed to the autonomous loop (`/groundrules:realize`), a pre-written, currently-**red** acceptance test is the loop's back pressure: the maker makes it green, an independent verifier replays it. Red-first is Kent Beck's discipline; groundrules applies it as the *loop precondition* — **not** a global mandate (interactive work keeps the human as back pressure, handoff-not-gospel). | [Beck, *TDD by Example*](https://www.oreilly.com/library/view/test-driven-development/0321146530/) · [ADR 0027](docs/decisions/0027-reflection-realization-interactive-loop.md) |
| **Reconciliation over reminders** — a doc you can't generate gets *checked* against the code | A rule that asks an agent to remember to update a record relies on attention and fails quietly; comparing the record with the code does not. Martraire calls this a **reconciliation mechanism**: where documentation can't be generated from the source, verify it against the source and report the mismatch. `/groundrules:close` applies it to `PLAN.md` — git says what changed, the plan says what it believes — and leaves the edit to a human. | [Martraire, *Living Documentation*](https://www.oreilly.com/library/view/living-documentation-continuous/9780134689418/) · [ADR 0038](docs/decisions/0038-close-reconcile-plan-against-diff.md) |
| **Small, surgical diffs** — simplicity first, touch only what the task needs | The smallest change that solves the *stated* problem is easier to review, revert, and reason about; speculative abstraction and drive-by refactors are liabilities, not value (the YAGNI / minimal-change craft consensus). groundrules folds it into the generated `CLAUDE.md` **Posture**. | [YAGNI](https://martinfowler.com/bliki/Yagni.html) · [ADR 0034](docs/decisions/0034-posture-keep-the-diff-small.md) |

These aren't dressed up as science — they're conventions we chose deliberately, and the choice itself is recorded where every other one is: [`docs/decisions/`](docs/decisions/).

## Requirements for the remote

- `gh` CLI for GitHub: https://cli.github.com/
- `glab` CLI for GitLab: https://gitlab.com/gitlab-org/cli

If absent, the plugin shows the ready-to-paste commands for manual execution.

## Plugin structure

```
groundrules/
├── .claude-plugin/plugin.json       # manifest
├── .claude-plugin/marketplace.json  # mono-plugin marketplace
└── skills/<name>/SKILL.md           # one slash command per skill
    bootstrap also has templates/    # Markdown templates
```

## Contributing

Issues and pull requests are welcome. A few conventions:

- **Structural changes go through an ADR** — propose one with `/groundrules:add-adr` (or describe the decision in the PR so it can become one).
- **The plugin dogfoods itself** — this repo uses its own generated structure (`docs/`, `intake/`, ADRs, `PLAN.md`), so changes should keep the dogfood coherent.
- **Templates are plain text** — `{{KEY}}` substitution only, no engine.
- **Changing a skill's instructions? there's an eval suite for that** — `evals/` holds regression cases over the agent's own behaviour, one per recorded failure mode ([ADR 0037](docs/decisions/0037-executable-evals-over-agent-config.md)). It is maintainer-side only: nothing is generated into your project and no skill invokes it. It runs on the official `skill-creator` plugin's harness — paired runs, one with the plugin and one without ([ADR 0042](docs/decisions/0042-skill-creator-harness-as-the-runner.md)); `claude plugin eval`, the runner originally chosen, is gated behind early access. Fair warning: the cases are written and have never been run.

## References

The findings behind the design choices above:

- **Context rot** — *Context Rot: How Increasing Input Tokens Impacts LLM Performance*, Chroma (2025). [Summary](https://www.understandingai.org/p/context-rot-the-emerging-challenge)
- **Lost in the middle** — Nelson Liu et al., *Lost in the Middle: How Language Models Use Long Contexts*, TACL 2024. [arXiv:2307.03172](https://arxiv.org/abs/2307.03172)
- **Sycophancy** — Mrinank Sharma et al., *Towards Understanding Sycophancy in Language Models*, Anthropic (2023). [arXiv:2310.13548](https://arxiv.org/abs/2310.13548) · [Anthropic research](https://www.anthropic.com/research/towards-understanding-sycophancy-in-language-models)
- **Sycophancy at scale (2026)** — *Sycophantic AI Decreases Prosocial Intentions and Promotes Dependence*, Science (2026) — 11 models affirm users ~50% more than humans. [arXiv:2510.01395](https://arxiv.org/abs/2510.01395)
- **Framing reduces sycophancy** — UK AI Security Institute, *Ask Don't Tell: Reducing Sycophancy in LLMs* (2026) — a claim posed as a question draws far less sycophancy than as a statement, beating explicit anti-sycophancy instructions. [arXiv:2602.23971](https://arxiv.org/pdf/2602.23971)
- **Premortem** — Gary Klein, *Performing a Project Premortem*, Harvard Business Review (2007) — assume failure, then explain it. [HBR](https://hbr.org/2007/09/performing-a-project-premortem)
- **Cost of a defect rises with time** — Barry Boehm, *Software Engineering Economics* (Prentice Hall, 1981) — the foundation for "spec before you build." [Overview](https://www.techwell.com/techwell-insights/2013/10/what-does-it-really-cost-fix-software-defect)
- **User control and freedom** — Jakob Nielsen, *10 Usability Heuristics for User Interface Design* (NN/g, heuristic #3). [Article](https://www.nngroup.com/articles/ten-usability-heuristics/)
- **CLAUDE.md guidance** (< 200 lines; larger files lower adherence) — Claude Code [memory docs](https://code.claude.com/docs/en/memory)
- **CLAUDE.md best practices** — [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice), [howborisusesclaudecode.com](https://howborisusesclaudecode.com/)
- **ADR format** — Michael Nygard, [*Documenting Architecture Decisions*](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- **Keep a Changelog** — [keepachangelog.com](https://keepachangelog.com/en/1.1.0/)
- **Conventional Commits** — [conventionalcommits.org](https://www.conventionalcommits.org/)
- **Semantic Versioning** — [semver.org](https://semver.org/)
- **Test-Driven Development** — Kent Beck, *Test-Driven Development: By Example* (Addison-Wesley, 2002) — red-first as the loop's back pressure. [O'Reilly](https://www.oreilly.com/library/view/test-driven-development/0321146530/)
- **Reconciliation mechanisms** — Cyrille Martraire, *Living Documentation: Continuous Knowledge Sharing by Design* (Addison-Wesley, 2019) — when a document can't be generated from the code, check it against the code and report the mismatch. [O'Reilly](https://www.oreilly.com/library/view/living-documentation-continuous/9780134689418/)

The complete per-decision history lives in [`docs/decisions/`](docs/decisions/) and [`CHANGELOG.md`](CHANGELOG.md).

## License

[MIT](LICENSE) © 2026 Guillaume Ferrari.
