<!-- generated-by: groundrules v1.11.0 -->
# 0035 — Considered an auto-capture memory layer (claude-mem class); declined

**Date**: 2026-06-29
**Status**: Accepted

## Context

"How does the agent *remember* across sessions?" is one of the most common questions about
groundrules. A popular class of tool answers it differently than we do:
[claude-mem](https://github.com/thedotmack/claude-mem) and similar systems **automatically
capture** everything the agent does via lifecycle hooks, AI-compress it into a **machine-local
store** (SQLite + a vector DB behind a background worker on a local port), and **re-inject**
relevant snippets into future sessions through a SessionStart hook.

It's worth a recorded decision rather than leaving the answer implicit, because the tool is
popular and the question recurs. This ADR doesn't introduce a new position — it **reaffirms**
three existing ones against a concrete, named exemplar.

## Decision

**Do not add, bundle, or depend on an auto-capture persistent-memory layer.** It contradicts
three load-bearing decisions:

- **[ADR 0020](0020-repo-is-the-only-memory.md) — the repo is the only memory.** Such stores
  live machine-local (`~/.claude-mem/…`); they die on `git clone` and don't reach teammates.
  groundrules' knowledge lives in the repo, versioned and shared.
- **[ADR 0021](0021-context-economy-index-over-doc-search.md) — index over doc-search.** These
  systems *are* a RAG layer (vector + FTS) over the agent's own history; we argued a curated
  index beats RAG for your own corpus.
- **[ADR 0025](0025-no-runtime-hook-no-watch.md) — no runtime hook, no watch.** They require an
  always-on daemon + hooks; groundrules is plain files, no runtime.

There's also a capture-philosophy fork: automatic capture is high-recall / low-signal, whereas
groundrules bets on **deliberate curation** (LEARNINGS, ADRs) — high-signal, human-readable.

**One point of agreement, recorded honestly:** claude-mem's *progressive disclosure* (compact
index first, full detail fetched only for filtered IDs) is the **same instinct** as our context
ladder (ADR 0021). Two traditions — RAG and curation — converging on "index first, detail on
demand" is evidence *for* the principle. Documented in `docs/CONTEXT-ECONOMY.md` ("What about an
auto-capture memory layer?") and surfaced in the README "leaves out" framing.

## Alternatives considered

- **Bundle/recommend a memory tool** — rejected: contradicts ADR 0020/0021/0025; adds a runtime
  dependency and machine-local state for knowledge we deliberately keep in the repo.
- **Build a groundrules-native memory store** — rejected for the same reasons, plus it fights
  the "template over code, no runtime" nature of the plugin.
- **Stay silent (the ADRs already imply it)** — rejected: the question recurs and deserves a
  single citable answer naming the exemplar; a curious user shouldn't have to infer it from
  three separate ADRs.

## Consequences

### Positive
- A clear, citable answer to a recurring question; the positioning is sharper (README +
  `CONTEXT-ECONOMY.md`) without any code or dependency.
- Honest: credits the one place the other approach converges with ours.

### Negative / Tradeoffs
- Users who want automatic cross-session recall must reach for an external tool; groundrules
  points to the class as **complementary but out-of-repo**, and takes no dependency on it.
- If agent memory tooling matures into a versioned, repo-local, no-daemon form, this decision
  is worth revisiting — it rejects the *current* machine-local-daemon shape, not the goal.
