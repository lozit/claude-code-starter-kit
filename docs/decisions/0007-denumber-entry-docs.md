<!-- generated-by: groundrules v1.11.0 -->
# 0007 — Drop the numeric prefix on entry docs (VISION / INTENT)

**Date**: 2026-06-03
**Status**: Accepted

## Context

`bootstrap` generated two docs with a `00-` prefix: `docs/00-VISION.md` and `brief/00-INTENT.md`. The prefix was inherited from the peer's reference structure quoted in `brief/INTENT.md`, where **every** doc was numbered (`00-VISION`, `01-ARCHITECTURE`, … `10-PROPERTIES`). The intent of that scheme: give docs an explicit reading order and make them sort alphanumerically.

The plugin only adopted the prefix for the **entry doc**, never for the rest: `ARCHITECTURE.md`, `GLOSSARY.md`, `CHANGELOG.md`, and the V0.7 specialized docs (`DATA_MODEL`, `SECURITY`, …) carry no number. So the numbering was applied **partially** — a vestige of the peer scheme. With only one numbered file, the sort/ordering benefit is null; the `00-` just adds friction to the path without conveying anything the filename doesn't already.

## Decision

Drop the prefix on the two entry docs:

- `brief/00-INTENT.md` → `brief/INTENT.md`
- `docs/00-VISION.md` → `docs/VISION.md`

No other doc is renamed (none was numbered). The repo standard is now: **docs are not numbered** (the only zero-padded prefix that remains is `docs/decisions/NNNN-*.md`, which is a genuine incremental sequence — see ADR 0001/0003 lineage).

## Alternatives considered

### Number all docs (`01-ARCHITECTURE.md`, `02-DATA_MODEL.md`, …)
- Rejected. Faithful to the peer structure and gives a reading order, but: breaks "speaking" paths, forces a number choice on every new doc, and renumbering on insertion is churn. The reading order is better expressed by `docs/VISION.md` being the obvious starting point and by `README.md` linking docs explicitly.

### Keep `00-` only on VISION/INTENT and document it as intentional
- Rejected. Documenting a half-applied convention legitimizes an inconsistency. A single numbered file sorts/orders nothing.

### Leave as-is, do nothing
- Rejected. The user explicitly asked why the prefix exists; the honest answer was "vestige, no longer useful". Fixing beats grandfathering accidental conventions.

## Consequences

### Positive
- Consistent doc naming across the whole tree (nothing numbered except ADRs, which have a real sequence).
- Cleaner paths; no number to bikeshed when adding docs.

### Negative / Tradeoffs
- Existing user projects bootstrapped at ≤ 0.6.0 still have `00-VISION.md` / `00-INTENT.md`. `/starter-kit:migrate` should handle the rename, or the old names keep working (nothing hard-codes that they *must* be absent). Until migrate learns the rename, mixed naming can exist in the wild.
- Historical references to the old names (CHANGELOG `[0.5.0]`, ADR 0005, the `.starter-kit.json` migration `note`, the quoted peer structure) are kept verbatim as historical record — a reader of those docs sees the old path. Acceptable: they describe past states.

### Neutral
- The dogfood repo's files were renamed via `git mv` so history is preserved.

## Notes

- Operational references updated in: `bootstrap/SKILL.md`, `apply-best-practices/SKILL.md`, `verify-bootstrap/SKILL.md`, `brief-INTENT.md.{fr,en}.tpl`, `README.md`, `.starter-kit.json` (`generatedFiles`), and the renamed files' own cross-links.
- Follow-up: extend `/starter-kit:migrate` to rename `00-VISION.md`/`00-INTENT.md` on upgrade (tracked in `PLAN.md`).
- See [ADR 0006](0006-optional-specialized-docs.md) which surfaced the partial-numbering inconsistency.
