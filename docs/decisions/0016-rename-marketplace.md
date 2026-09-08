<!-- generated-by: groundrules v1.11.0 -->
# 0016 — Rename the marketplace starter-kit-local → claude-code-starter-kit

**Date**: 2026-06-06
**Status**: Accepted

## Context

The marketplace `name` in `.claude-plugin/marketplace.json` dates from the very first local test (`starter-kit-local`). Since the marketplace went public on GitHub, the name is misleading: a user installing from `https://github.com/lozit/claude-code-starter-kit` ends up with a marketplace called "local", and that name is what `/plugin marketplace update <name>` expects — including in the update notices the skills now print (ADR 0015).

## Decision

Rename the marketplace to **`claude-code-starter-kit`**, matching the GitHub repository name. Install spec becomes `/plugin install starter-kit@claude-code-starter-kit`.

- Updated: `marketplace.json` (`name` + English description), the Phase 0 update notices in `bootstrap`/`adopt`/`migrate`, the README (install + updating sections, with a note for users on the old name), the root `CLAUDE.md` test instructions.

## Alternatives considered

- **`lozit`** (owner-scoped, like `anthropics`) — scales to future plugins under one marketplace; rejected by the user in favor of matching the repo name.
- **`starter-kit`** — rejected: `starter-kit@starter-kit` is redundant, and it freezes the marketplace name to the plugin name (awkward if the plugin is renamed at V1.0.0, cf. ADR 0017).
- **Keep `starter-kit-local`** — rejected: misleading for every public user.

## Consequences

### Positive
- The marketplace name matches the repo users actually add; update commands are self-explanatory.

### Negative / Tradeoffs
- **Users who added the marketplace under the old name** keep their add-time name locally: `/plugin marketplace update starter-kit-local` keeps working for them, but the commands suggested in the skills/README reference the new name. Mitigation: README note (check `/plugin` → Marketplaces, or remove/re-add the marketplace).

### Neutral
- The plugin name (`starter-kit`, slash-command prefix) is unchanged — see ADR 0017 for that discussion.
