<!-- generated-by: groundrules v1.11.0 -->
# 0021 — Context economy: index over doc-search for a project's own docs

**Date**: 2026-06-08
**Status**: Accepted

## Context

A recurring debate: to make a project's documentation available to a coding agent
(Claude Code) without burning tokens, should you connect a **documentation-search / RAG
plugin** (an MCP server that semantically searches docs) or keep a simple **index** (a
short always-loaded `CLAUDE.md` pointing to docs the agent reads on demand)? A related
worry: "too much context is counterproductive" — is that real?

Research (2026-06): it is real and measured. Chroma's 2025 *context rot* study found all
18 frontier models tested (incl. Claude Opus 4) degrade as input grows; the
*lost-in-the-middle* effect drops mid-context accuracy 30%+. Anthropic's own docs reflect
it — keep `CLAUDE.md` < 200 lines, "larger files produce lower adherence" — and a big
always-loaded file also busts the prompt cache on every edit. Full write-up:
[`docs/CONTEXT-ECONOMY.md`](../CONTEXT-ECONOMY.md).

## Decision

groundrules makes project documentation available through an **index + on-demand reads**,
not a RAG/doc-search layer:

- The generated `CLAUDE.md` stays a **map** (< 200 lines): a session-start read order + a
  file index. The exhaustive content lives in `docs/`, read when a task needs it (native
  `Read`/`grep`, cached).
- **A doc-search MCP server is reserved for large *external* corpora** the repo can't hold
  (a framework's full docs, an SDK) — a different problem from "my own project docs".
- The principle propagates to every bootstrapped project via a self-contained note in the
  `CLAUDE.md` template ("keep this file a map, not the territory; doc-search tools are for
  external corpora").

## Alternatives considered

- **RAG/doc-search over the project's own repo** — rejected: adds an MCP server (schema +
  infra overhead) and a fuzzy retrieval step to do worse than native `Read`/`grep`, which
  is free and cached. The "fewer tokens" claim only holds versus dumping a whole external
  doc set into context, not versus a good index.
- **Everything in `CLAUDE.md`** ("so the agent always has it") — rejected: dilutes
  attention (context rot), lowers adherence, and busts the prompt cache on every edit.
- **No guidance at all** (keep generating the index pattern silently) — rejected: a
  documentation tool should *explain* the discipline so users don't bloat `CLAUDE.md` or
  add a needless RAG layer.

## Consequences

### Positive
- Confirms and documents the pattern groundrules already generates; users get the *why*.
- Cheapest and simplest option for the common case (own docs), with a clear signpost for
  the rare case that justifies doc-search (external corpora).

### Negative / Tradeoffs
- The index must be **kept current** — a stale "read first" list or file map misleads. The
  "living docs" convention already covers this.
- Discipline required: the value depends on people not pasting doc content into `CLAUDE.md`
  "to be safe". The template note makes the agent enforce it.

## Notes

- Full guide: [`docs/CONTEXT-ECONOMY.md`](../CONTEXT-ECONOMY.md).
- Builds on ADR 0020 (the repo is the only memory) — knowledge on disk is what makes
  selective loading possible.
