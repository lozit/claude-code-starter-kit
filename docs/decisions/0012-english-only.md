<!-- generated-by: groundrules v1.11.0 -->
# 0012 — English-only (drop bilingual FR/EN templates)

**Date**: 2026-06-04
**Status**: Accepted

## Context

From V0.1, the plugin shipped **bilingual FR/EN** templates: a French variant and an English variant of nearly every template (`*.fr.tpl`/`*.en.tpl`, plus base-FR `.tpl` for some), selected at generation time by a `{{LANG}}` value (`fr` / `en` / `mix`) captured by a dedicated interview question. Resume/migrate carried matching per-language selection logic, and several skills branched on `answers.lang`.

In practice, all projects are bootstrapped in **English**. The French variants were dead weight: every template change had to be made twice and kept in sync, the interview had an extra question, and the SKILL logic carried a `{{LANG}}` branch and `{lang}` template-path interpolation everywhere. That's maintenance cost for no realized benefit.

## Decision

Make the plugin **English-only**.

- Delete all `*.fr.tpl` and `*.fr.md` templates. English becomes the single set: one `.tpl` per file with **no language suffix** (e.g. `CLAUDE.md.tpl`, `README.md.tpl`, `CLAUDE.lean.md.tpl`), and `adr-template.md`.
- Remove the `{{LANG}}` placeholder, the "language" interview question, and all per-language template selection in `bootstrap`, `adopt`, `migrate`, `add-adr`, `learn`.
- Translate the plugin's own sources and dogfood to English: the 7 `SKILL.md` files, the root `CLAUDE.md`, `README.md`, `docs/VISION.md`, `brief/INTENT.md`, `.claude/rules/plugin-meta.md`, `docs/best-practices-pending.md`. (ADRs and CHANGELOG were already English.)
- Drop the obsolete `answers.lang` from `.starter-kit.json`.

## Alternatives considered

- **Keep bilingual** — rejected: the stated reason for the whole feature (projects in both languages) doesn't hold; it's pure overhead.
- **Keep FR templates but stop advertising them** — rejected: dormant duplicates still rot and still get half-maintained. Delete cleanly.
- **Make language a per-file override instead of global** — rejected: more complexity, not less. The goal is to remove the axis entirely.
- **Auto-translate at generation via the model** — rejected: violates template-over-code (ADR 0002) and makes output nondeterministic.

## Consequences

### Positive
- Half as many templates; one place to edit each.
- Simpler interview (one fewer question) and simpler SKILL logic (no `{{LANG}}`, no `{lang}` paths).
- Consistent English repo, friendlier to the public English-speaking audience.

### Negative / Tradeoffs
- **Breaking** for any project bootstrapped with a pre-0.8 plugin in French: `migrate` can no longer diff against a FR template. Mitigation: `migrate` reports such files as "language change — manual review" and offers the English template as `<file>.new` rather than overwriting French content.
- Non-English users lose first-class FR output. Accepted given the actual usage (solo author + English community).
- `brief/INTENT.md` (the original French prompt) was translated; the French original is preserved only in git history.

### Neutral
- This is the inverse of an earlier constraint ("Bilingual FR/EN on all user templates") stated in `docs/VISION.md`; the vision was updated accordingly.

## Notes

- Supersedes the bilingual constraint from V0.1. The language-suffix convention described in earlier docs (`*.fr.tpl`, `*.en.tpl`) no longer applies.
- See [ADR 0002](0002-plain-text-placeholder-substitution.md) (template-over-code) — still holds; this ADR only removes the language axis.
