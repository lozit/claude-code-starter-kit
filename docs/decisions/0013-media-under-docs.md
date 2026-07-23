<!-- generated-by: groundrules v1.10.0 -->
# 0013 — Move media under docs/ (docs/media/ instead of top-level media/)

**Date**: 2026-06-04
**Status**: Accepted

## Context

Since V0.1, `bootstrap` created a top-level `media/` folder (with an explanatory README) for visual/binary assets. Many real projects **already have** a top-level `media/` or `public/` directory (frameworks like Nuxt/Next/Vite, static sites, etc.). Generating a starter-kit `media/` at the root either collides with the project's own folder or adds a second asset location at the same level — confusing and, in `adopt`/resume mode, risky.

The starter-kit asset folder is documentation-adjacent (mockups, diagrams, screenshots that support the docs), so it belongs under the docs tree, not at the project root competing with build/asset conventions.

## Decision

Generate the asset folder at **`docs/media/`** instead of `media/`.

- Template destination changes: `media-README.md.tpl` → `docs/media/README.md` (the template filename is unchanged; only the output path moves).
- Updated everywhere the path is referenced: `bootstrap` (scan list + mapping), `adopt`, the `CLAUDE.md`/`README` templates' "key files" sections, and the dogfood layer B (the repo's own `media/` → `docs/media/`).
- `migrate` learns the move: for a pre-0.9 project, detect a top-level `media/` and offer to `git mv` it to `docs/media/` — but only if it's the starter-kit one; a project's own unrelated `media/`/`public/` is left untouched and `docs/media/` is simply created.

## Alternatives considered

- **Keep `media/` at the root** — rejected: the collision with existing `media/`/`public/` is the whole problem the user hit.
- **Use `assets/` at the root** — rejected: same collision class (build tools use `assets/` too), and it's not clearly docs-related.
- **Drop the media folder entirely** — rejected: a documented place for mockups/diagrams is useful; only its location was wrong.
- **Make the location configurable** — rejected: adds an interview question and a placeholder for a marginal gain; a sensible fixed default under `docs/` is enough (the user can move it later).

## Consequences

### Positive
- No collision with a project's top-level `media/` or `public/`.
- Asset folder sits with the documentation it supports; the root tree stays cleaner.

### Negative / Tradeoffs
- **Path change** for projects bootstrapped before V0.9. Mitigated by the `migrate` move logic above; nothing breaks if the old `media/` is simply left in place (it's just not the starter-kit-tracked path anymore).
- One more thing under `docs/`. Acceptable — it's conceptually documentation support.

### Neutral
- The dogfood repo's `media/README.md` moved to `docs/media/README.md` via `git mv` (history preserved).

## Notes

- `.starter-kit.json` `generatedFiles` now lists `docs/media/README.md`.
- See ADR 0007 (the previous path change, VISION/INTENT de-numbering) for the same migrate-rename pattern.
