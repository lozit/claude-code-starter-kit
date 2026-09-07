---
name: idea
description: "Use when a forward idea surfaces that you don't want to lose: parks it as a one-line entry in PLAN.md's \"Ideas - to triage\" inbox. The prospective complement to /groundrules:checkpoint (retrospective)."
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Bash
---

# /groundrules:idea

You will **park a raw idea** in the project's `PLAN.md` backlog inbox — fast, before it evaporates. This is *prospective* capture (a forward idea), complementing `/groundrules:checkpoint` (retrospective capture of what happened). All output is in **English**.

> The repo is the only memory: an idea kept in the conversation is already half-lost. The point is **capture, not triage** — drop it in the inbox now; deciding what to do with it comes later.

## Phase 1 — Locate `PLAN.md`

Find `PLAN.md` at the project root.
- **Absent** → `PLAN.md` is optional. Tell the user, and offer to create a minimal one (header + the `## Ideas — to triage` section) rather than fabricating a full plan. If they decline, stop.

## Phase 2 — Get the idea

- If `$ARGUMENTS` is non-empty → that's the idea. Otherwise ask the user for it (one line).
- Keep it to **one line**. If the user gives a paragraph, condense to a crisp one-liner that **preserves their intent** — don't editorialize, don't expand, don't solve it.
- Derive a short bold **title** (3-6 words) + the one-line description.
- A light triage hint in italics is optional, only if obvious (e.g. *(build)* / *(decision)* / *(milestone?)*). When unsure, add nothing — triage happens later.

## Phase 3 — Append to the inbox

Read `PLAN.md`, then:
- **`## Ideas — to triage` present** → append the new bullet at the **end of that section's list** (after existing ideas, before the next `##` heading).
- **Absent** → create the section **right after `## Up next`** (or after `## In progress` if there is no `## Up next`), with this intro line, then the bullet:
  > `Raw ideas, captured before they're lost. Not yet vetted. Each gets triaged later → a **decision** (ADR), a **build** (PRD), a **milestone** (ROADMAP), or dropped.`

Bullet format:
```
- [ ] **<short title>** — <one-line idea>. *(<triage hint, optional>)*
```

**Append-only**: never reorder, rewrite, or touch any other section or existing idea. Preserve the file's `generated-by` signature.

## Phase 4 — Recap

- ✅ Idea parked in `PLAN.md` → "Ideas — to triage".
- 📋 It'll be triaged later → ADR (decision) · PRD (build) · ROADMAP (milestone) · or dropped.

**NEVER commit automatically.**

## Important rules

- **Capture, don't triage** — one line, no deep-dive; resist solving or scoping the idea here.
- **Append-only** — never overwrite or reorder existing content; the section is created once, then only grown.
- **Idempotent** — safe to run repeatedly; creates the section if missing, appends if present.
- This skill writes `PLAN.md` only; it never commits, tags, or pushes.
