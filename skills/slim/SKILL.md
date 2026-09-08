---
name: slim
description: "Use when CLAUDE.md approaches or exceeds the ~200-line budget: proposes concrete optimizations (extract to docs/ or .claude/rules/, compress, de-duplicate) without ever losing content."
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# /groundrules:slim

You will analyze the project's `CLAUDE.md` and **propose** concrete ways to keep it under the **~200-line** budget (the context-economy discipline, cf. ADR 0021 — an always-loaded file that grows dilutes attention and lowers adherence). You **propose**, the user **chooses**, and you apply by **moving** content (never deleting it). All output is in **English**.

## Phase 1 — Measure

1. `CLAUDE.md` must exist in the cwd. Otherwise: warn and suggest `/groundrules:bootstrap`. Stop.
2. `wc -l CLAUDE.md` → current size. Split on `##` / `###` headings and note each section's line count.
3. Report: `CLAUDE.md is X/200 lines`. If **≤ 200**, say it's healthy — offer optimizations only if the user explicitly wants to slim further; otherwise stop here. If **> 200** (or **> ~170**, approaching), continue to propose.

## Phase 2 — Analyze & propose

Scan for these opportunities, biggest-win first, and estimate lines saved for each:

1. **Extract a bulky section to `docs/`** — a long block that is really *documentation* (architecture prose, data-model detail, a process description…) belongs in the matching `docs/` file (`docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, `docs/PROCESS.md`…), with a **one-line pointer** left in `CLAUDE.md`. This is the "map, not territory" fix.
2. **Move file-type rules to `.claude/rules/<topic>.md`** — rules that only apply to a certain kind of file (a language, a folder) belong in `.claude/rules/` with `paths:` frontmatter, so they **load on demand** instead of every session. Off the always-on budget entirely.
3. **De-duplicate** — content that repeats the "Key files" index, restates the global CLAUDE.md, or says the same thing twice → keep one copy.
4. **Compress prose** — verbose bullets, hedging, examples that can be a phrase. Tighten in place.
5. **Cut pasted doc content** — anything pasted "to be safe" that duplicates a `docs/` file → replace with a pointer.

Do **not** touch: `<important if=...>` rules (must survive growth), managed/foreign sections (no groundrules signature, often tool-managed), or the user's deliberate project-specific conventions — flag those as "keep".

## Phase 3 — Choose

Present the proposals as a short table (what / where it goes / ~lines saved / running projected total), then ask via `AskUserQuestion` (group 3-4) which to apply. Each is opt-in. Show the projected final line count for the selected set.

## Phase 4 — Apply (move, never delete)

For each chosen optimization:

- **Extract to `docs/<file>`**: if the target exists, **append** the content under a suitable heading; if not, create it (carry the `<!-- generated-by: groundrules … -->` signature for a known doc). Then **replace** the block in `CLAUDE.md` with a one-line pointer (e.g. `- Architecture detail → \`docs/ARCHITECTURE.md\``). Show the before/after.
- **Move to `.claude/rules/<topic>.md`**: create the rule file with `paths:` frontmatter (+ signature line after the closing `---`), move the rules in, remove them from `CLAUDE.md`.
- **Compress / de-duplicate**: rewrite tighter in place; show the diff.

**Never lose content** — every extraction is a *move*: the content lands somewhere before it leaves `CLAUDE.md`. Confirm each write.

## Phase 5 — Recap

- 📏 `CLAUDE.md`: was X lines → now Y/200
- 📂 What moved where (per optimization)
- ⏭️ Suggestions the user declined (so they can revisit)

If still over 200 after the chosen set, say so and point to the remaining proposals.

**NEVER commit automatically.**

## Important rules

- **Propose, don't impose**: every change is the user's choice; apply only what's selected.
- **Move, never delete**: content is relocated with a pointer, never dropped.
- **Preserve** `<important>` rules, managed sections, and signatures.
- The goal is *fewer always-loaded tokens*, not fewer docs — extracted content stays fully available, just read on demand (cf. `docs/CONTEXT-ECONOMY.md` thinking, ADR 0021).
