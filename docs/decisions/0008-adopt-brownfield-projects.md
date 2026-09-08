<!-- generated-by: groundrules v1.11.0 -->
# 0008 — Adopt existing (brownfield) projects via a dedicated skill

**Date**: 2026-06-03
**Status**: Accepted

## Context

Analyzing a real-world app (a Nuxt 3 internal tool, ~30 top-level entries, GitLab remote, already using [superpowers](https://github.com/obra/superpowers)) surfaced that starter-kit has **no path to onboard an existing project**:

- `/starter-kit:migrate` refuses anything without `.starter-kit.json` ("rien à migrer") — by design, it updates *already-managed* projects.
- `/starter-kit:bootstrap` resume mode runs on a non-empty dir, but treats every pre-existing file as a "foreign file to ignore". It does not **map** existing artifacts to starter-kit roles (e.g. a root `plan.md` is the PLAN, a `CR-regles-metier.md` is intent material, `docs/gtd/todos.md` is a backlog, `docs/superpowers/**` is per-feature) — so adoption is lossy and semantically odd ("bootstrap" a mature app).

The same analysis exposed that planning detection (added in V0.7) was too narrow: it missed case variants (`plan.md` vs `PLAN.md`), nested files (`docs/gtd/todos.md`), and the case where **several** planning surfaces coexist.

## Decision

### 1. New skill `/starter-kit:adopt`

A dedicated brownfield-onboarding skill, distinct from bootstrap (from-scratch) and migrate (version update), consistent with ADR 0003 (one skill = one concern):

- Refuses if `.starter-kit.json` exists (→ migrate) or the dir is empty (→ bootstrap).
- Scans, detects stack/remote/secrets/i18n/data-layer/UI/superpowers, and **maps existing files to starter-kit roles** (README, PLAN, backlog, intent-source, superpowers-interop, already-present docs).
- Captures intent **from existing docs** when possible (offers detected business/spec docs as the source).
- Generates **only what's missing**; never overwrites, never deletes.
- Backfills `.starter-kit.json` with `adopted: true`, `bootstrappedWithVersion: null`, a `generatedFiles` list (created) **and** a new `adoptedFiles` map (existing → role).
- No `git init` / no remote creation (the project already has both). Supports `--dry-run`.

### 2. Broaden planning detection (shared by bootstrap and adopt)

- Case-insensitive name match (`plan.md`, `todo.md`, `todos.md`, `tasks.md`, `backlog.md`).
- Nested paths up to ~3 levels (excluding `node_modules`/`.git`), e.g. `docs/gtd/todos.md`.
- Report **all** equivalents; clarify their roles when several coexist.
- **Case-collision guard**: never generate `PLAN.md` when a case-variant exists — on a case-sensitive FS (Linux/CI) this would create two files differing only by case, colliding on checkout to macOS/Windows.

## Alternatives considered

### Enhance bootstrap resume mode instead of a new skill
- Rejected as primary. Bootstrap is semantically "start/continue a starter-kit project"; telling a user to "bootstrap" a mature app is confusing, and bootstrap's git-init/remote-creation phases are irrelevant for brownfield. Keeping concerns separate (ADR 0003) wins. Bootstrap still keeps its broadened detection and points complex cases to `adopt`.

### Make migrate accept brownfield (backfill then migrate)
- Rejected. Conflates two concerns (adoption vs version update) in one skill. Migrate stays strictly "update an already-managed project".

### Do nothing (let users hand-create `.starter-kit.json`)
- Rejected. Too high a barrier and error-prone; the whole point is to lower the cost of bringing existing repos under the convention.

## Consequences

### Positive
- Existing repos can be onboarded losslessly: their docs are recognized, not ignored or clobbered.
- The `adopted`/`adoptedFiles` markers give `migrate`/`verify-bootstrap` enough context to reason about a project they didn't create.
- Planning detection now matches real-world fragmentation (multiple, nested, mixed-case) and avoids a genuine cross-platform git hazard.

### Negative / Tradeoffs
- A 7th skill increases surface to maintain and version-align. Mitigated by reusing bootstrap's template-generation and intent logic rather than duplicating it.
- Role-mapping is heuristic (filename/content guesses). The skill must *propose* mappings and let the user confirm, never assume.
- `.starter-kit.json` now has two shapes (bootstrapped vs adopted). `verify-bootstrap` must tolerate `bootstrappedWithVersion: null` and the `adoptedFiles` key.

### Neutral
- The motivating app is left untouched (analysis only); the fix lands in the plugin, not the app.

## Notes

- Schema extension (`adopted`, `adoptedAt`, `adoptedFiles`) builds on [ADR 0004](0004-starter-kit-json-schema.md).
- See [ADR 0003](0003-multi-skill-architecture.md) for the one-skill-per-concern rationale.
- Follow-up: teach `verify-bootstrap` about adopted projects (tolerate null `bootstrappedWithVersion`, validate `adoptedFiles` paths exist) — tracked in `PLAN.md`.
