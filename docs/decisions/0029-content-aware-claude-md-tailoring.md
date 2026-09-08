<!-- generated-by: groundrules v1.11.0 -->
# 0029 — Content-aware CLAUDE.md tailoring (retire the lean template)

**Date**: 2026-06-14
**Status**: Accepted — **supersedes [ADR 0009](0009-global-claude-md-awareness.md)**

## Context

ADR 0009 made the project CLAUDE.md **defer** to a global one by a **boolean of presence**: if any
global `~/.claude/CLAUDE.md` exists → use a static `CLAUDE.lean.md.tpl` with all cross-cutting
sections pre-removed. The assumption: the global covers commits/git/verification/tools.

That assumption breaks the moment the global is **thin**. A global that only says *"always write in
English"* still triggered the full strip → the generated project CLAUDE.md lost its
git/commits/verification guidance entirely. **Holes.** The decision was presence-based, never
content-based.

ADR 0009 itself **explicitly rejected** the fix now adopted ("auto-slim by parsing the global —
too clever, fragile, against template-over-code") and **accepted** existence-only detection as a
known limitation. The reversal is justified: (1) judging coverage on a <200-line file is a solid
use of a current model; (2) **template-over-code (ADR 0002) is preserved** — templates stay plain
text, only the SKILL's *assembly logic* changes; (3) the "known limitation" is precisely the bug
users hit. So this **supersedes** 0009 the disciplined way (recorded, not silently).

## Decision

**One template (`CLAUDE.md.tpl`); the "lean" outcome emerges from omitting only what the global
actually covers.** `CLAUDE.lean.md.tpl` is **deleted**.

At generation (`bootstrap`/`adopt`), when a global is detected, **read its content** (it's short —
our own <200-line doctrine) and tailor:

- **Collapsible** sections — omit **only if the global covers that topic's *primary* directive**
  (judge coverage, not presence; partial → keep): `### Commits` · `### Permissions and settings` ·
  `## Verifying the work` · `## Claude Code workflow` · `## Git workflow`. `## Don't` is **always
  kept** (it carries the signature "the repo is the only memory" line — the E2E showed a
  generic-Don'ts omission could never fire).
- **Always keep** groundrules' **signature conventions** even if the global mentions them
  (Session-start order, Capture-at-checkpoints, When-to-document routing, the-repo-is-the-only-memory,
  living docs, Posture) and all **project-specific** sections. **Bias to keep on any doubt.**
- **Omission style**: **drop** the covered section and **list the omitted topics** in the deference
  note (`{{GLOBAL_CLAUDE_NOTE}}`) — most economical and auditable. **Recap to the user, who can veto.**
- Net effect: a thin global → output ≈ full template; a rich global → output ≈ the old lean. The
  result **scales with the global's real content, with no holes.**

For **`adopt` with an existing (managed) CLAUDE.md**: the free-zone additions become **gap-driven**
— offer only the signature conventions the file is **missing**, never a fixed blob, never the
managed sections (ADR 0010 deference still wins first).

## Alternatives considered

- **Keep the binary lean/full (status quo, ADR 0009)** — rejected: presence-based → holes on a thin
  global; the lean was a second template prone to drift from the full one.
- **Keep the lean as a floor, add back uncovered sections** — rejected: still two templates to keep
  in sync.
- **A smarter binary threshold** (global covers ≥N topics → lean) — rejected: still coarse, no
  per-section accuracy.
- **Aggressive tailoring** (also omit signature conventions when covered) — rejected by the
  maintainer: groundrules' signature value (Posture, capture ritual, repo-is-memory) should land
  even when a global's version is thinner/different. Conservative split + bias-to-keep chosen.

## Consequences

### Positive
- No holes: a thin global no longer strips git/commits/verification.
- One template to maintain; the full/lean drift risk disappears.
- Genuine context economy: omit only the *truly redundant*, transparently (the omission list).
- `adopt`'s existing-file additions are now gap-driven, not a fixed pointer blob.

### Negative / Tradeoffs
- Generation now requires **agent judgment** ("does the global cover commits?") instead of a file
  pick — less deterministic. Mitigated by: bias-to-keep, the user-facing omission recap + veto, and
  verify-bootstrap checks being section-agnostic (signature + no-bare-placeholder).
- "Coverage" is a judgement call; a misread could omit a section the global doesn't truly cover →
  the recap/veto is the safety net.

## Notes

- Spec: `docs/prd/content-aware-claude-md-tailoring.md`.
- Template-over-code (ADR 0002) intact: `CLAUDE.md.tpl` stays plain `{{KEY}}` text; the tailoring
  lives in `bootstrap`/`adopt` SKILL instructions, not a template engine.
