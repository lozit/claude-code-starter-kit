<!-- generated-by: starter-kit v0.4.0 -->
# 0001 — `marketplace.json` lives in `.claude-plugin/`, not at the repo root

**Date**: 2026-05-11
**Status**: Accepted

## Context

A Claude Code plugin distributed via a marketplace needs two manifest files:
- `.claude-plugin/plugin.json` — declares the plugin itself
- `marketplace.json` — declares the marketplace catalog (which can list one or more plugins, possibly the same repo as the plugin)

The Claude Code plugin documentation does not state explicitly where `marketplace.json` should live. Conventional intuition (and several third-party plugin examples) places it at the repo root, alongside `README.md`. Our V0.1 initial scaffolding followed that intuition.

When the user attempted `/plugin marketplace add /Users/guillaumeferrari/Projets/Starting-Claude`, Claude Code returned: *"Marketplace file not found at /Users/guillaumeferrari/Projets/Starting-Claude/.claude-plugin/marketplace.json"*.

So Claude Code's resolver looks for the marketplace manifest at the **exact path** `.claude-plugin/marketplace.json` — root placement is not supported.

## Decision

`marketplace.json` is stored at `.claude-plugin/marketplace.json`, alongside `plugin.json`. This is the only location recognized by `/plugin marketplace add <repo>`.

## Alternatives considered

- **Root placement** (initial V0.1 attempt) — rejected: not recognized by the resolver. Returns explicit "file not found at .claude-plugin/marketplace.json" error.
- **Dedicated `marketplace/` folder** — rejected: not a Claude Code convention, no documentation suggests this works.

## Consequences

### Positive
- Aligned with the only path Claude Code's resolver checks.
- Manifest files (`plugin.json`, `marketplace.json`) are grouped in the same hidden folder, keeping the repo root clean.

### Negative / Tradeoffs
- The `source: "./"` field in `marketplace.json` must be carefully understood: it points to the plugin location relative to the marketplace, which in our single-plugin case is the repo root (one level up from `.claude-plugin/`). Confusing but functional.
- Anyone migrating a plugin from third-party guides that put `marketplace.json` at root will hit this same error.

### Neutral
- Updating the location in V0.2.0 was a one-line `git mv` with no other code impact.

## Notes

- Commit that fixed the bug: `0fe5ed8 fix: move marketplace.json into .claude-plugin/`
- This learning was added to the CLAUDE.md meta convention (`Conventions de templates` section mentions the path).
- If future Claude Code versions support root placement, this ADR can be revisited.
