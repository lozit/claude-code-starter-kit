<!-- generated-by: starter-kit v0.4.0 -->
# 0003 — Multi-skill architecture with `disable-model-invocation: true`

**Date**: 2026-05-11
**Status**: Accepted

## Context

V0.1 shipped with one skill: `bootstrap`. Through V0.2 → V0.4 the plugin grew to four user-facing operations: bootstrapping, adding an ADR, recording a learning, and migrating between versions. We had two structural choices:

- **One mega-skill** with a subcommand router: `/starter-kit do bootstrap`, `/starter-kit do add-adr`, etc.
- **One skill per concern**, each invoked directly: `/starter-kit:bootstrap`, `/starter-kit:add-adr`, etc.

Parallel question: should these skills be **auto-invokable** by Claude (model decides when to fire them, based on context) or **manual only** (the user types the slash command)?

Both bootstrap and migrate have side effects (file writes, git operations, ADR/learning entries persisted on disk). add-adr and learn ask the user for content. In every case, the user is the right initiator — there's no scenario where Claude should silently run `bootstrap` because it inferred the user "probably wanted that".

## Decision

- **One skill per concern**, four entries in slash autocomplete: `bootstrap`, `add-adr`, `learn`, `migrate`.
- All four skills declare `disable-model-invocation: true` in their frontmatter — they are exposed **only** as slash commands. Claude cannot auto-fire them.

The `.starter-kit.json` file (cf. [ADR 0004](0004-starter-kit-json-schema.md)) is the shared state that binds the skills together — every skill reads it, migrate writes it.

## Alternatives considered

- **One mega-skill with subcommand argument** (`/starter-kit do <subcommand>`) — rejected:
  - Worse discoverability (autocomplete shows one entry, user must remember subcommand names)
  - Argument parsing overhead inside SKILL.md (Claude has to validate, dispatch, error on unknown subcommand)
  - Mega-SKILL.md becomes long and hard to maintain
- **Auto-invocation enabled** (no `disable-model-invocation`) — rejected:
  - bootstrap creates files and runs `git init` — should never fire on Claude's hunch
  - migrate overwrites or creates `.new` files — definitely user-triggered
  - add-adr / learn prompt for content — silent invocation makes no sense
  - The "compounding engineering" pattern (Boris Cherny: update CLAUDE.md from PR reviews) is the right model for **automatic** updates, and that's a different mechanism (GitHub Action, not a Claude Code skill)
- **Hybrid: bootstrap manual, add-adr/learn auto** — rejected for now:
  - Inconsistent UX
  - add-adr could in theory be auto-fired when Claude notices a decision was made, but this opens "did the user actually want an ADR or just a discussion?" which is hard to judge. Better to teach the user via CLAUDE.md to ask for it.

## Consequences

### Positive
- Each skill is self-contained, ~100-150 lines max, easy to read and modify in isolation.
- Adding a 5th, 6th skill (e.g., `/starter-kit:add-glossary-term`) costs one new file in `skills/<name>/SKILL.md` — no central dispatcher to touch.
- Predictable safety: the user knows nothing happens without an explicit slash command.
- The plugin name in autocomplete (`starter-kit:`) groups everything visually.

### Negative / Tradeoffs
- Shared logic is duplicated across SKILL.md files:
  - Reading `.starter-kit.json`
  - Language detection (`answers.lang` → template suffix)
  - "If not bootstrapped, refuse and suggest bootstrap"
  - Slug/kebab-case conversion (add-adr only, for now)
  - If this duplication becomes painful, the mitigation is to extract a `skills/shared/HELPERS.md` reference document that all SKILL.md files instruct Claude to read — not a code library (no runtime in plugins), just shared natural-language conventions.
- The four skills must agree on conventions and keep them in sync: `<!-- generated-by -->` signature format, placeholder list (`{{KEY}}`), `.starter-kit.json` schema. Any change to these is a coordinated edit across files.

### Neutral
- `disable-model-invocation: true` means the skills don't appear when Claude is browsing skills it could auto-fire — only the autocomplete shows them. Documented in the README so users know.

## Notes

- See [ADR 0004](0004-starter-kit-json-schema.md) for the `.starter-kit.json` schema that all skills share.
- See `CLAUDE.md` (root, meta) section "À ne pas faire" — it specifically reminds: *"Ne pas oublier que `disable-model-invocation: true` cache le skill à l'autocomplétion : seul le slash command marche"*.
- Reference: shanraisshan recommendation that skills with side effects use `disable-model-invocation: true` was followed here.
