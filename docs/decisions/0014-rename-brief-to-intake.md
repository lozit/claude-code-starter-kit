<!-- generated-by: groundrules v1.11.0 -->
# 0014 — Rename the brief/ folder to intake/

**Date**: 2026-06-06
**Status**: Accepted

## Context

Since V0.1, `bootstrap` generated a top-level `brief/` folder for raw upstream material (client specs, brainstorms, email excerpts, scoping notes) — the draft layer, as opposed to `docs/` which holds the synthesized, stable version.

The name "brief" was unsatisfying: in product/agency jargon a *brief* is a single document (the creative brief), not a folder of heterogeneous raw inputs. Candidates considered for "raw material received before the project starts": `intake/`, `inbox/`, `intent/`, `upstream/`, `discovery/`, `inputs/`, `requirements/`.

## Decision

Rename the generated folder **`brief/` → `intake/`**. "Intake" is the established term for what arrives as input before processing (intake form, intake meeting), which matches the folder's role exactly: unstructured upstream material awaiting synthesis into `docs/`.

- Template renames: `brief-INTENT.md.tpl` → `intake-INTENT.md.tpl`, `brief-README.md.tpl` → `intake-README.md.tpl`. Generated paths become `intake/INTENT.md`, `intake/README.md`.
- `{{INTENT_SOURCE}}` values become `intake/INTENT.md (paste)` / `intake/INTENT.md (file <path>)`.
- Updated everywhere the path is referenced: `bootstrap` (scan list, Phase 3, Phase 5 mapping), `adopt`, the `CLAUDE.md`/`CLAUDE.lean.md`/`README`/`docs-VISION` templates, the public `README.md`, and the dogfood layer B (`git mv brief intake` + reference sweep).
- `migrate` learns the rename (Phase 2): detect a `brief/` folder on disk, offer `git mv brief intake`, fix the paths in `.starter-kit.json` (`generatedFiles`), and flag stale `brief/` references in the project's own docs. Renames chain: a pre-V0.7 `brief/00-INTENT.md` lands directly at `intake/INTENT.md`.
- The word "brief" survives in prose where it denotes the *document* a user pastes (e.g. "Do you already have a brief...?") — only the folder/path naming changes.

## Alternatives considered

- **Keep `brief/`** — rejected: the name suggests a single document, not a folder of raw inputs.
- **`intent/`** — appealing (matches `INTENT.md`) but conflates the folder (raw, heterogeneous) with the one synthesized intent file it happens to contain.
- **`inbox/`** — good draft connotation, but suggests ongoing incoming flow rather than project-start material; also clashes with GTD-style inboxes some users keep.
- **`requirements/`** — rejected: connotes formal, structured specs, contradicting the "no imposed structure" convention.
- **`upstream/`** — rejected: collides mentally with the git meaning of upstream.
- **`discovery/` / `inputs/`** — reasonable, but "intake" is more precise about the *received-before-processing* nature.

## Consequences

### Positive
- The folder name says what it is: raw incoming material awaiting synthesis.
- No collision with common project conventions (`brief/` was harmless but vague; `intake/` is rarely taken).

### Negative / Tradeoffs
- **Path change** for projects bootstrapped before this version — the third one (after ADR 0007 and ADR 0013), mitigated by the same `migrate` rename pattern. Nothing breaks if a project keeps its old `brief/`; it's just no longer the starter-kit-tracked path.

### Neutral
- The dogfood repo's `brief/` moved to `intake/` via `git mv` (history preserved).

## Notes

- `.starter-kit.json` `generatedFiles` now lists `intake/README.md` and `intake/INTENT.md`.
- See ADR 0007 and ADR 0013 for the previous applications of the migrate-rename pattern.
