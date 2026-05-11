<!-- generated-by: starter-kit v0.4.0 -->
# 0002 — Plain text placeholder substitution, no templating engine

**Date**: 2026-05-11
**Status**: Accepted

## Context

The plugin generates project files from templates stored in `skills/bootstrap/templates/*.tpl`. Each template contains placeholders like `{{PROJECT_NAME}}`, `{{DESCRIPTION}}`, `{{STACK}}`, `{{DATE}}`, `{{HAS_PLAN}}`, etc. The skill must substitute these placeholders with values collected during the interview.

A natural reflex is to reach for a templating engine (Jinja2, Handlebars, Mustache) — they handle escaping, conditionals, loops, partials.

But the plugin's actual substitution needs are small:
- 10 placeholders total, all string-typed
- No conditionals required *inside* a template (conditional inclusion is handled at the file-mapping level: `HAS_PLAN=true` → write `PLAN.md`, otherwise skip — decision made by the skill, not the template)
- No loops needed
- No partials needed (no template references another)

And the plugin runtime is Claude itself reading SKILL.md instructions — there is no Python/Node process available without external dependencies, and pulling in a templating dep would require shipping it inside the plugin.

## Decision

Use plain text find-and-replace for `{{KEY}}` placeholders. Claude reads the template file, performs `replace("{{KEY}}", value)` for each known placeholder (per the list documented in SKILL.md phase 4), and writes the result.

## Alternatives considered

- **Jinja2** (or any Python templating engine) — rejected. Adds runtime dependency; requires Python invocation; conditionals/loops not needed.
- **Mustache / Handlebars** — rejected. Same reasoning, plus less ubiquitous.
- **Custom mini-language** with `{{if HAS_PLAN}}…{{/if}}` blocks — rejected. Increases template complexity for no real gain since conditional inclusion is decided file-by-file at the skill level.

## Consequences

### Positive
- Templates are readable as-is — no syntax to learn beyond `{{KEY}}`.
- No external dependency to ship with the plugin.
- Trivial to debug: a "missing" placeholder shows up literally as `{{KEY}}` in the output.
- Claude can do the substitution naturally inside its workflow without invoking any tool beyond `Read` and `Write`.

### Negative / Tradeoffs
- If a placeholder is genuinely needed inside a template (e.g., `{{` in literal CSS or Vue templates), we'd need an escape mechanism. Not a problem today; would force an ADR-amend if it becomes one.
- All placeholders must be documented in SKILL.md phase 4. Adding one means updating SKILL.md and possibly every template — minor maintenance cost.

### Neutral
- Conditional file *inclusion* (write PLAN.md or not?) is handled in SKILL.md phase 4 logic, not in the template — keeps the two concerns separate.

## Notes

- Documented in `CLAUDE.md` (root, meta) section "Conventions de templates": *"Placeholders au format `{{KEY}}` (substitution texte simple, pas de moteur de template)."*
- Placeholder list canonicalized in `skills/bootstrap/SKILL.md` phase 4.
