<!-- generated-by: groundrules v1.11.0 -->
# Architecture Decisions (ADR)

This folder contains the project's **Architecture Decision Records**: each structural decision made during the project is recorded in a file.

## Format

Inspired by [Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions). See `0000-template.md`.

## Naming convention

`NNNN-title-kebab.md` where NNNN is a 4-digit incremental integer.

Examples:
- `0001-database-choice.md`
- `0002-auth-pattern.md`

## When to create an ADR

When a decision:
- has a **long-term impact** on the architecture
- is **hard to reverse**
- has **explicit tradeoffs** worth documenting
- might be **revisited later** (better to freeze the context now)

No ADR needed for trivial choices or implementation details.

## Index

| # | Title | Status | Date |
|---|---|---|---|
| 0000 | Template | — | — |
| [0001](0001-marketplace-json-location.md) | `marketplace.json` lives in `.claude-plugin/`, not at the repo root | Accepted | 2026-05-11 |
| [0002](0002-plain-text-placeholder-substitution.md) | Plain text placeholder substitution, no templating engine | Accepted | 2026-05-11 |
| [0003](0003-multi-skill-architecture.md) | Multi-skill architecture with `disable-model-invocation: true` | Accepted | 2026-05-11 |
| [0004](0004-starter-kit-json-schema.md) | `.starter-kit.json` schema with `bootstrappedWithVersion` and `migrations` | Accepted | 2026-05-11 |
| [0005](0005-intent-capture-and-apply-best-practices.md) | Intent capture in bootstrap + separate `apply-best-practices` skill | Accepted | 2026-05-11 |
| [0006](0006-optional-specialized-docs.md) | Optional specialized docs in bootstrap (DATA_MODEL, SECURITY, DESIGN_SYSTEM, ROADMAP, I18N) | Accepted | 2026-06-03 |
| [0007](0007-denumber-entry-docs.md) | Drop the numeric prefix on entry docs (VISION / INTENT) | Accepted | 2026-06-03 |
| [0008](0008-adopt-brownfield-projects.md) | Adopt existing (brownfield) projects via a dedicated `/starter-kit:adopt` skill | Accepted | 2026-06-03 |
| [0009](0009-global-claude-md-awareness.md) | Global/enterprise CLAUDE.md awareness + lean project CLAUDE.md | Superseded by 0029 | 2026-06-03 |
| [0010](0010-managed-project-claude-md-deference.md) | Defer to an existing tool-managed project CLAUDE.md (no generation, opt-in docs pointer) | Accepted | 2026-06-03 |
| [0011](0011-detect-no-ai-attribution-policy.md) | Detect a "no AI attribution" policy and adapt suggested commits | Accepted | 2026-06-03 |
| [0012](0012-english-only.md) | English-only (drop bilingual FR/EN templates) | Accepted | 2026-06-04 |
| [0013](0013-media-under-docs.md) | Move media under docs/ (docs/media/) | Accepted | 2026-06-04 |
| [0014](0014-rename-brief-to-intake.md) | Rename the brief/ folder to intake/ | Accepted | 2026-06-06 |
| [0015](0015-best-effort-update-check.md) | Best-effort plugin update check in skills (Phase 0) | Accepted | 2026-06-06 |
| [0016](0016-rename-marketplace.md) | Rename the marketplace starter-kit-local → claude-code-starter-kit | Accepted | 2026-06-06 |
| [0017](0017-plugin-rename-at-v1.md) | Rename the plugin to groundrules at V1.0.0 | Accepted | 2026-06-06 |
| [0018](0018-adopt-consolidation-mode.md) | adopt: map-in-place vs consolidate strategies | Accepted | 2026-06-06 |
| [0019](0019-heyjoe-inspired-doc-improvements.md) | Doc improvements harvested from a real project (crm-heyjoe) | Accepted | 2026-06-06 |
| [0020](0020-repo-is-the-only-memory.md) | The repo is the only memory (no project knowledge in agent-local state) | Accepted | 2026-06-07 |
| [0021](0021-context-economy-index-over-doc-search.md) | Context economy: index over doc-search for a project's own docs | Accepted | 2026-06-08 |
| [0022](0022-agent-evals-and-session-close.md) | Session-close ritual + optional agent-evals log | Accepted | 2026-06-08 |
| [0023](0023-project-scope-for-team-portability.md) | Recommend project-scope install for team portability | Accepted | 2026-06-08 |
| [0024](0024-slim-skill-claude-md-budget.md) | `/groundrules:slim` — operationalize the CLAUDE.md budget | Accepted | 2026-06-08 |
| [0025](0025-no-runtime-hook-no-watch.md) | Won't-do: PreToolUse `{{KEY}}` hook and `/watch-bootstrap` | Accepted | 2026-06-08 |
| [0026](0026-posture-and-per-feature-prd.md) | Posture section + per-feature PRD (superpowers-aware) | Accepted | 2026-06-13 |
| [0027](0027-reflection-realization-interactive-loop.md) | Reflection/realization phases; interactive/loop regimes; loop-readiness direction | Accepted | 2026-06-13 |
| [0028](0028-git-workflow-conventions.md) | Git workflow: neutral branching, boundary commits, AI attribution-unless-forbidden | Superseded by 0036 | 2026-06-13 |
| [0029](0029-content-aware-claude-md-tailoring.md) | Content-aware CLAUDE.md tailoring; retire the lean template (supersedes 0009) | Accepted | 2026-06-14 |
| [0030](0030-loop-namespace-and-backlog.md) | `loop/` is the loop's namespace; the loop reads `loop/backlog.md`, `PLAN.md` only points to it | Accepted | 2026-06-14 |
| [0031](0031-goal-interop-swappable-loop-executor.md) | `/goal` interop: the loop executor is swappable (`/goal` = light loop, groundrules loop = high-fidelity); reposition `run-loop.sh` | Accepted | 2026-06-17 |
| [0032](0032-premortem-anti-sycophancy.md) | Adopt the premortem as a reflection-phase adversarial technique (anti-sycophancy): PRD-Risks hint + Posture pointer + `/groundrules:premortem` skill | Accepted | 2026-06-20 |
| [0033](0033-adopt-full-mode.md) | adopt: "Full adoption" mode (consolidate + reformat, single grouped confirmation, `--full`) | Accepted | 2026-06-26 |
| [0034](0034-posture-keep-the-diff-small.md) | Posture: a "keep the diff small" axis (simplicity + surgical changes), harvested from karpathy-skills | Accepted | 2026-06-29 |
| [0035](0035-no-auto-capture-memory-layer.md) | Considered an auto-capture memory layer (claude-mem class); declined — reaffirms ADR 0020/0021/0025 | Accepted | 2026-06-29 |
| [0036](0036-git-workflow-corrected.md) | Git workflow corrected: PR on protected `main`, no AI attribution (supersedes 0028) | Accepted | 2026-09-02 |
| [0037](0037-executable-evals-over-agent-config.md) | An executable eval suite over the agent's configuration (`evals/`), native format, out of band | Accepted | 2026-09-02 |
| [0038](0038-close-reconcile-plan-against-diff.md) | `/groundrules:close`: reconcile `PLAN.md` against the diff — proposes, never auto-writes; a check, not a reminder | Accepted | 2026-09-08 |
| [0039](0039-conditional-superpowers-interop.md) | The superpowers interop section is conditional (`{{HAS_SUPERPOWERS}}`), detected rather than asked | Accepted | 2026-09-08 |
| [0040](0040-three-bootstrap-modes.md) | Three bootstrap modes: prior state then emptiness, two questions in that order (bootstrap / resume / brownfield) | Accepted | 2026-09-08 |
| [0041](0041-a-migration-never-damages-a-correct-file.md) | A migration never damages a correct file: no bare `{{KEY}}` written, no `Overwrite` on an accumulator, and a comparison text matching what `bootstrap` would produce | Accepted | 2026-09-08 |
| [0042](0042-skill-creator-harness-as-the-runner.md) | The eval suite runs on `skill-creator`'s harness, the runner ADR 0037 chose being gated (amends 0037) | Accepted | 2026-09-09 |
| [0043](0043-probed-not-validated.md) | `validated` retired: a case makes an entry `probed` on one instance, never the class (amends 0037) | Accepted | 2026-09-09 |
| [0044](0044-runner-enforces-verifier-isolation.md) | The runner spawns the verifier separately; the loop's isolation becomes a fact rather than a request | Accepted | 2026-09-09 |
