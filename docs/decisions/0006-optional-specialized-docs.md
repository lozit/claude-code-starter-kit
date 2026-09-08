<!-- generated-by: groundrules v1.11.0 -->
# 0006 — Optional specialized docs in bootstrap

**Date**: 2026-06-03
**Status**: Accepted

## Context

The project's own `brief/INTENT.md` cites a reference structure used by a peer, with ~11 numbered docs under `docs/`:

```
00-VISION  01-ARCHITECTURE  02-DATA_MODEL  03-MODULES  04-I18N
05-SALESFORCE  06-DESIGN_SYSTEM  07-SECURITY_RGPD  08-NOTIFICATIONS
09-ROADMAP  10-PROPERTIES  tickets/
```

`bootstrap` already generated `VISION`, `ARCHITECTURE`, `GLOSSARY`, `CHANGELOG`, `PLAN` (the last four conditionally). The question: which of the remaining docs are generic enough to ship as reusable templates, and which are project-specific noise?

The guiding constraints (cf. root `CLAUDE.md` and ADR 0002): **template-over-code**, **minimal by default**, **offline-first**, and **user handoff** (templates are starting points, structure provided + content fillable).

## Decision

Add **five** new docs as **opt-in conditional templates**, selected via a single multiSelect interview call ("Appel 2b") so we don't bloat the question count (cf. the "no giga-question" rule):

| Doc | Trigger | Why generic |
|---|---|---|
| `docs/DATA_MODEL.md` | has a database | every data-backed project needs an entity/relations reference |
| `docs/SECURITY.md` | sensitive/personal data | auth + access control + GDPR is broadly applicable |
| `docs/DESIGN_SYSTEM.md` | has a UI | colors/typo/components/tokens generalize across frontends |
| `docs/ROADMAP.md` | long-term trajectory | milestone planning is universal; fills a gap `PLAN.md` doesn't |
| `docs/I18N.md` | multilingual | translation strategy generalizes |

Each ships FR + EN, carries the `<!-- generated-by -->` signature, and uses fillable placeholders (`<à compléter>` / `<fill in>`) — never fabricated content.

New placeholders: `{{HAS_DATA_MODEL}}`, `{{HAS_SECURITY}}`, `{{HAS_DESIGN_SYSTEM}}`, `{{HAS_ROADMAP}}`, `{{HAS_I18N}}`.

## Alternatives considered

### Add `tickets/` (one `.md` per work item)
- Rejected. The plugin already creates a **remote repo via `gh`/`glab`**, whose native **issues** cover the exact niche of `tickets/` (stable IDs, status, parallelism, references). `tickets/` would largely duplicate issues while adding ceremony, against "minimal by default".
- `PLAN.md` keeps the complementary "now, in-repo, offline, Claude-maintained" view that issues don't provide. Issues + `PLAN.md` ≥ `tickets/`.
- May revisit as an opt-in convention for no-remote projects.

### Add `MODULES.md` / `NOTIFICATIONS.md`
- Deferred. `MODULES` overlaps with feature specs that often live closer to code or in `ARCHITECTURE`; `NOTIFICATIONS` is more niche (push/email matrix). Not worth a template yet.

### Ship `SALESFORCE.md`, `PROPERTIES.md` (the peer's project-specific docs)
- Rejected. These describe one specific project (a CRM integration, reference data). A frozen template would carry no transferable value; users create such docs by hand when needed.

### One yes/no question per doc
- Rejected. Five extra yes/no calls bloat the interview. A single multiSelect call groups them and respects the "group questions by theme" rule.

### Make them always-created
- Rejected. A backend-only CLI doesn't want `DESIGN_SYSTEM.md`; a single-language tool doesn't want `I18N.md`. Empty placeholder files are noise. Opt-in keeps the default tree minimal.

## Consequences

### Positive
- Richer scaffolding available without forcing it — the default tree stays minimal.
- Consistent with the existing conditional-doc pattern (ARCHITECTURE/GLOSSARY/CHANGELOG).
- The interview adapts: stack/intent hints can pre-suggest relevant docs (UI → DESIGN_SYSTEM, DB → DATA_MODEL).

### Negative / Tradeoffs
- More templates to keep version-aligned (10 new files) at each release signature bump.
- Some overlap risk: `DATA_MODEL` access-rules vs `SECURITY` authorization, `ROADMAP` vs `PLAN`. Mitigated by cross-references inside each template.
- `verify-bootstrap` now has more optional files to reason about, but its logic is data-driven from `.starter-kit.json.generatedFiles`, so no code change needed.

### Neutral
- The dogfood repo (this plugin) doesn't generate these docs for itself — it has no DB/UI/i18n. They remain available, unused here. Honest: opt-in means opt-out is the default.

## Notes

- Templates added: `DATA_MODEL`, `SECURITY`, `DESIGN_SYSTEM`, `ROADMAP`, `I18N` (each `.tpl` FR + `.en.tpl` EN).
- See [ADR 0002](0002-plain-text-placeholder-substitution.md) for the template-over-code constraint these follow.
- See [ADR 0004](0004-starter-kit-json-schema.md) for `.starter-kit.json` — the `HAS_*` answers persist under `answers`.
