<!-- generated-by: groundrules v1.10.0 -->
# 0024 — `/groundrules:slim` — operationalize the CLAUDE.md budget

**Date**: 2026-06-08
**Status**: Accepted

## Context

ADR 0021 (context economy) and the generated `CLAUDE.md` both set a **~200-line budget** (an always-loaded file that grows dilutes attention and lowers adherence). `verify-bootstrap` already *measures* the file and warns past 200 — but it only flags the problem; it offers no way to *fix* it. The generated `CLAUDE.md` says "extract to `docs/` or `.claude/rules/`" but nobody operationalizes it. The user wanted groundrules to actively **propose optimizations** to stay under budget.

## Decision

Add a dedicated skill **`/groundrules:slim`** that analyzes `CLAUDE.md`, **proposes** concrete reductions, and applies the chosen ones by **moving** content (never deleting):

- Extract a bulky *documentation* section to the matching `docs/` file, leaving a one-line pointer ("map, not territory").
- Move file-type-specific rules to `.claude/rules/<topic>.md` with `paths:` frontmatter, so they load **on demand** — off the always-on budget.
- De-duplicate (vs the index / the global CLAUDE.md), compress prose, cut pasted doc content.

**`verify-bootstrap` points to `slim`** when it flags `CLAUDE.md > 200` — check stays where it is, the fix is one command away. The generated `CLAUDE.md` template is **left untouched** (no pointer added) to honor the no-bloat principle the skill itself serves; discoverability comes from the README and verify-bootstrap.

Safety rules: propose don't impose (every change opt-in), move never delete (content lands somewhere before it leaves `CLAUDE.md`), preserve `<important>` rules / managed sections / signatures, never auto-commit.

## Alternatives considered

- **Extend `verify-bootstrap`** instead of a new skill — rejected: verify is a fast read-only coherence check; interactive content surgery muddies its purpose. Cleaner to keep verify as the detector and `slim` as the operator (verify links to it).
- **A pointer to `slim` in the generated `CLAUDE.md`** — rejected: adding lines to `CLAUDE.md` to explain how to keep `CLAUDE.md` short is self-defeating; the user was explicit about no bloat. Discoverability lives in the README + verify-bootstrap warning.
- **Auto-slim (proactive, no ask)** — rejected: extraction is a judgment call; it must be proposed and chosen, never silent.

## Consequences

### Positive
- The 200-line budget becomes enforceable, not just aspirational. Extracted content stays fully available (read on demand) — fewer always-loaded tokens, not fewer docs.
- Ninth skill, but cross-cutting maintenance (like `checkpoint`) — not lifecycle surface.

### Negative / Tradeoffs
- Extraction quality is a judgment call by the agent; mitigated by propose-don't-impose, move-never-delete, and per-change confirmation.
