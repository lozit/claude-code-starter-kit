<!-- generated-by: groundrules v1.11.0 -->
# 0018 — adopt: map-in-place vs consolidate strategies

**Date**: 2026-06-06
**Status**: Accepted

## Context

`/groundrules:adopt` (ADR 0008) maps existing files to groundrules roles and leaves them where they are — safe, but a brownfield project ends up with a **dual layout**: its historical organization (e.g. `tasks/todo.md`, `tasks/lessons.md`, `specifications/`) *and* the groundrules canonical paths for whatever was missing. Real-world case: the crm-heyjoe repo, whose organization is excellent but entirely parallel to the canonical layout. The user wanted the choice: keep the duplicates documented, or move everything onto the canonical files.

## Decision

Add an **adoption strategy** question to `adopt` (Call 1):

- **Map in place** (default — previous behavior): zero file moves; roles recorded in `adoptedFiles`; duplicates tolerated and documented.
- **Consolidate**: a new **Phase 4b** migrates each role-mapped file to its canonical path — `git mv` for 1:1 moves (history preserved), content **merge** when the target exists (with per-file fate for the source: `git rm` / keep with pointer / keep as-is), optional **reformat** to the template structure (e.g. raw lessons → rule format), and a final internal-reference sweep. Everything per-file confirmed, `--dry-run` honored.

`.groundrules.json` gains `adoptionMode` and `migratedFiles` (old → new map) so `migrate`/`verify-bootstrap` know the provenance.

## Alternatives considered

- **Consolidate-only** — rejected: map-in-place is the safe default and some teams keep their layout on purpose.
- **A separate `/groundrules:consolidate` skill** — rejected: the decision belongs at adoption time; a later consolidation can still be done by re-running `adopt` logic manually, and a dedicated skill can be added later if demand appears.
- **Automatic consolidation without per-file confirmation** — rejected: violates the never-overwrite/never-delete-silently rule.

## Consequences

### Positive
- Brownfield projects can land on a clean canonical layout in one pass, with history preserved (`git mv`).
- The default stays the safe one; no behavior change for users who ignore the new question.

### Negative / Tradeoffs
- Consolidate mode relaxes "adopt never deletes" to "deletes only via explicit per-file confirmation" — documented in the skill rules.
- Merges (existing content into template structure) are judgment calls executed by Claude; the per-file confirmation and dry-run mitigate.
