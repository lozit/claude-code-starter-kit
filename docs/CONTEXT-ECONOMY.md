<!-- generated-by: groundrules v1.11.0 -->
# Context economy — how groundrules keeps docs exhaustive *and* cheap

> Why groundrules generates an **index + on-demand docs** instead of dumping everything
> into `CLAUDE.md` or bolting on a documentation-search plugin. The short version:
> **separate storage from loading.**

## The principle: storage ≠ loading

Two things people conflate:

- **Storage** — how much documentation the project *has*. Should be **exhaustive**. Lives
  on disk (`docs/`, ADRs, `intake/`). Costs nothing to keep; unlimited.
- **Loading** — how much of it sits in the model's context *for the current task*. Should
  be **minimal** — only what this task needs.

"Exhaustive" and "token-efficient" only seem to conflict if you fuse these. Keep them
separate and there is no tradeoff: write everything down, load almost none of it.

## Yes, too much context is counterproductive — it's measured

This isn't folklore. It's true on two independent grounds:

- **Empirically.** Chroma's 2025 *context rot* study tested 18 frontier models (including
  Claude Opus 4): **every one degrades as input grows**, at every length increment — not
  just on needle-in-a-haystack but on real tasks. The classic **"lost in the middle"**
  effect: models attend well to the **start and end** of the window and accuracy drops
  **30%+** for information in the middle (when the window is <50% full; past 50% it shifts
  to favoring the most recent tokens). Attention is a **finite budget** — every token you
  add depletes what's left for the tokens that matter.
- **Anthropic says so too.** The Claude Code docs recommend keeping `CLAUDE.md`
  **under 200 lines** and state that **"larger files produce lower adherence."** Same
  phenomenon, acknowledged by the vendor. (Bonus: editing a big always-loaded file
  **busts the prompt cache**, so every edit re-bills the whole file.)

So "put everything in `CLAUDE.md` so Claude has it" actively *hurts* — it dilutes
attention and costs more.

## Is the agent still reading it? The canary probe

The budget (< 200 lines) is **preventive**. But adherence is never guaranteed 100%, and you
get no alarm when it slips — so pair the budget with a cheap **detective** signal: a *canary*.

A canary is one trivial, glance-checkable instruction whose **only** job is to report whether
the file is still being read — e.g. *"always greet me as `<name>`"*. While the greeting holds,
the agent is reading and honoring the file; when it silently lapses, adherence is decaying
(usually **context saturation** late in a long session, or too many competing instructions).

Three things to keep straight:

- **It's a passive probe, not a guard.** `CLAUDE.md` is **context, not enforced config** — to
  *block* an action no matter what, you need a `PreToolUse` hook, not a line of Markdown. This
  is exactly why groundrules keeps enforcement out of the generated file
  ([ADR 0025](decisions/0025-no-runtime-hook-no-watch.md)).
- **A root canary tests saturation, not compaction.** The project-root `CLAUDE.md` **survives
  `/compact`** — Claude re-reads it from disk and re-injects it. So a root canary mostly
  surfaces in-session context saturation, not post-compaction loss (a common misconception).
- **It's a global witness, not a diagnostic.** It tells you attention is slipping, *not which
  rule* fell.

groundrules **doesn't generate a canary**: a gimmick line costs the very budget it watches and
adds one more competing instruction (the noise it's meant to detect). It's an **opt-in
technique** you add yourself when you want the signal. (Origin:
[HN](https://news.ycombinator.com/item?id=46098838); see also the official
[memory docs](https://code.claude.com/docs/en/memory).)

## Index vs documentation-search plugin: settle the debate

A common online claim: a **doc-search / RAG plugin** (an MCP server that semantically
searches docs) "uses fewer tokens." Half-true — it depends entirely on *whose* docs:

| | **Your own project docs** (in your repo) | **A large external corpus** (a framework's full docs, an SDK — thousands of pages you don't own) |
|---|---|---|
| **Best tool** | **Index in `CLAUDE.md` + on-demand `Read`/`grep`** | A **doc-search / RAG MCP server** (Context7, devdocs…) |
| **Why** | The agent reads your repo *natively*. A file is exactly as long as you wrote it, read once when needed, and **cached**. Zero server overhead. | You can't (and shouldn't) load whole doc sets; semantic search returns just the relevant paragraph. |
| **Token cost** | ~the few lines of the index at startup; a file's tokens only when actually read | ~120 tokens for tool *names* at startup (schemas are *deferred* by default), then the schema (100–500 tok) + the returned snippet on use |

The "fewer tokens" claim is true **relative to dumping an entire external doc set into
context** — but **not** relative to a good index over your own repo, which is even cheaper
*and* native. Worse, the "50k tokens burned before you type" horror stories come from MCP
servers that inject full schemas **every turn**. Adding a RAG layer over *your own* repo
buys fuzzy retrieval and infrastructure for **zero benefit** — Claude already `grep`s and
`Read`s your files.

**Verdict:** for the project's own documentation, **the index wins** — and that's what
groundrules generates. A doc-search plugin solves a *different* problem (huge external
reference you can't fit), not this one.

**Reaching for the external-corpus tool when you do need it.** For that case — a large,
heterogeneous body you don't own and can't read whole (a framework's docs, a big unfamiliar
codebase, a pile of papers) — the right fit is a **doc-search MCP** (Context7, devdocs…) or
a **GraphRAG / knowledge-graph** tool such as [graphify](https://github.com/safishamsi/graphify)
(it parses code/docs/media into a queryable graph). These live **outside** groundrules — it
takes no dependency on them; this guide only tells you *when* to reach for one. A caveat that
keeps them in their lane: their output is *derived and probabilistic* (inferred edges, fuzzy
retrieval), so use them to **comprehend** a corpus, not as the source of truth — the curated,
exact docs stay in the repo.

## The full ladder: progressive disclosure

Best practice is to layer the project so each piece loads only when relevant. From
cheapest-always-on to loaded-only-on-need:

| Layer | What it holds | When it enters context |
|---|---|---|
| **`CLAUDE.md` (< 200 lines)** | Durable rules + the **index** (session-start read order + file map) | Every session start (re-injected after compaction). Keep it a map. |
| **`docs/` files** | The exhaustive content (vision, architecture, learnings, ADRs…) | **On demand**, when a task needs a specific file (cached). |
| **`.claude/rules/*.md` with `paths:`** | Domain rules scoped to file types | Only when a matching file is read. |
| **Skills (`SKILL.md`)** | Specialized procedures | Name+description in the index; **body on invoke**. `disable-model-invocation: true` keeps even the description out until called. |
| **Subagents** | Heavy reading / research | File reads happen in the *subagent's* window; only the summary returns to yours. |
| **MCP servers** | External tools / corpora | Tool names at startup; **schemas deferred** until a tool is called. Only for what your repo can't provide natively. |

The rule of thumb: **`CLAUDE.md` is a map, not the territory.** It points; the territory is
read on demand.

## How groundrules embodies this

A groundrules-generated project is already built on this ladder:

- The generated **`CLAUDE.md`** opens with **"Session start — read first, in order"** (an
  ordered pointer list) and a **"Key files and folders"** map — an index, not a dump.
- The exhaustive content lives in **`docs/`** (VISION, ARCHITECTURE, DATA_MODEL, LEARNINGS,
  decisions/…) and **`intake/`**, read when a task needs them.
- The CLAUDE.md template points at **`.claude/rules/*.md`** with `paths:` frontmatter for
  scoped rules.
- The **"repo is the only memory"** convention (ADR 0020) keeps knowledge on disk, where it
  can be loaded selectively — not in an agent's volatile, always-on memory.

The decision to keep it this way (index over RAG for own docs) is recorded in
[ADR 0021](decisions/0021-context-economy-index-over-doc-search.md).

## What about an auto-capture memory layer?

A third class of tool is worth naming, because it's the most common "but how does the agent
*remember*?" ask: a **persistent-memory system** (e.g.
[claude-mem](https://github.com/thedotmack/claude-mem)) that **automatically captures**
everything the agent does via lifecycle hooks, AI-compresses it into a **machine-local store**
(SQLite + a vector DB behind a background worker), and **re-injects** relevant snippets into
future sessions. It's the opposite bet to groundrules' on three axes:

| | Auto-capture memory (claude-mem class) | groundrules |
|---|---|---|
| **Where it lives** | Machine-local (`~/.claude-mem/…`) — **dies on `git clone` / new machine**, doesn't travel to teammates | In the **repo** — versioned, shared, survives a clone ([ADR 0020](decisions/0020-repo-is-the-only-memory.md)) |
| **How it's written** | **Automatic** capture of everything (high recall, low signal) | **Curated** — LEARNINGS/ADRs are deliberate, high-signal, human-readable |
| **What it needs** | A **runtime daemon** + hooks always on | Plain files; **no runtime** ([ADR 0025](decisions/0025-no-runtime-hook-no-watch.md)) |

One honest point of **agreement**: claude-mem's *progressive disclosure* (a compact index
first, full detail fetched only for the IDs you filter to) is the **same instinct** as the
ladder above — filter before you fetch. We arrive at it by **curation**, they by **RAG**; that
two traditions converge on "index first, detail on demand" is a point *for* the principle, not
against it. groundrules takes **no dependency** on such a tool and doesn't bundle one; if you
genuinely want automatic cross-session recall *on top of* curated repo memory, these exist and
are complementary — just know the recall lives **outside** your repo and your version history.

## Sources

- Chroma, *Context Rot: How Increasing Input Tokens Impacts LLM Performance* (2025) — 18
  models, degradation at every length. Summary: <https://www.understandingai.org/p/context-rot-the-emerging-challenge>, <https://www.morphllm.com/context-rot>
- *Lost in the Middle: How Language Models Use Long Contexts* — U-shaped positional bias,
  30%+ mid-context accuracy drop.
- Claude Code docs — context window, memory (`CLAUDE.md` < 200 lines, lower adherence for
  larger files), skills lifecycle, MCP tool-search (deferred schemas), costs: <https://code.claude.com/docs/en/context-window>, <https://code.claude.com/docs/en/costs>
