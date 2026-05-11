<!-- generated-by: starter-kit v0.4.0 -->
# CLAUDE.md — {{PROJECT_NAME}}

> This file is **mutable and iterative**. Update it after every Claude mistake or newly discovered convention. Target: < 200 lines.

## Description

{{DESCRIPTION}}

## Setup / Build / Test

> **Critical test**: a new dev (or Claude) should be able to run the project and its tests **first try** using the commands below. If that's not the case, fill this section before anything else.

- Install deps: `<to fill>`
- Run dev: `<to fill>`
- Test: `<to fill>`
- Lint: `<to fill>`
- Build: `<to fill>`

## Key files and folders

- `README.md` — public presentation
- `CLAUDE.md` — this file
- `PLAN.md` — active todo (if present), maintained during work
- `docs/` — project documentation
  - `docs/decisions/` — ADRs (one file per structural decision)
  - `docs/LEARNINGS.md` — learnings throughout the project (reverse-chronological)
  - `docs/ARCHITECTURE.md` — architecture snapshot (if present)
  - `docs/GLOSSARY.md` — domain vocabulary (if present)
- `brief/` — upstream notes (read this folder for domain context at session start)
- `media/` — visual assets
- `.claude/` — Claude Code config
  - `.claude/settings.json` — team config, checked into git
  - `.claude/rules/*.md` — auto-loaded rules (`paths:` frontmatter for scoping)
  - `.claude/commands/`, `.claude/skills/`, `.claude/agents/`, `.claude/hooks/` — automations

## Conventions

### Commits

Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`. Small and atomic. Don't mix refactor and feature.

### Code

{{STACK}}

Readability > cleverness. No premature abstractions. No comments paraphrasing code — reserve them for non-obvious "why".

### Permissions and settings

- Pre-allow safe permissions via `/permissions` (e.g., `"Bash(npm run *)"`, `"Bash(git status)"`)
- Team config in `.claude/settings.json`, checked into git
- For subfolder-specific rules: `.claude/rules/<topic>.md` with `paths:` frontmatter rather than bloating this file

## Verifying the work

Before declaring a task done:

- Run the test command above
- For UI: actually use the feature in a browser, not just compile
- For data: check the actual data, not just the absence of error
- Produce a **behavior diff** (before/after) — not just "I ran the tests"

> *"Prove to me this works"* — if you can't prove it, it's not done.

## When to document

### ADR — `docs/decisions/`

When a **structural decision** is made (tech, pattern, tradeoff), propose an ADR. Copy `0000-template.md` → `NNNN-title-kebab.md`. Keep it < 1 page.

### LEARNINGS — `docs/LEARNINGS.md`

When a **non-trivial learning** emerges (pitfall avoided, subtle bug, discovered convention), add a dated entry at the top.

### PLAN.md

Keep current: check off done, add emerging tasks, note blockers.

## Updating this file

This file is alive.

- When Claude makes a mistake: add a rule so it doesn't recur
- When you spot an unwritten convention: codify it here
- For a rule that **must absolutely survive** file growth: `<important if="situation">rule</important>`
- If the file exceeds 200 lines or a section swells: extract to `docs/` or `.claude/rules/`
- For rules applicable to a certain type of file: prefer `.claude/rules/` with `paths:` rather than putting everything here

> *"Anytime we see Claude do something incorrectly we add it to the CLAUDE.md"* — iterate until the error rate is acceptable.

## Claude Code workflow

- **Plan mode** (`shift+tab`) before any non-trivial task
- **`/compact [hint]`** mid-task to compress context; **`/clear`** when switching tasks
- **Git worktrees** for parallel sessions: `claude --worktree <name>`
- **Custom skills/commands** in `.claude/` — if you do something more than once a day, automate it
- **Delegation > pair-programming**: with Opus 4.6+, give **goal**, **constraints**, and **acceptance criteria** in the first message, rather than guiding line by line

## Git workflow

- Only commit on explicit request (never auto-commit at end of task)
- Verify no secrets or debug files are included
- Feature branch for non-trivial changes

## Don't

- Don't add dependencies without confirming
- Don't commit without explicit request
- Don't create new doc files without need (prefer enriching existing)
- Don't do opportunistic refactoring mid-feature
- Don't ignore a rule in this file — if it doesn't fit, **modify it**, don't bypass it

## Tech stack

{{STACK}}

## Notes

Project bootstrapped with [starter-kit](https://github.com/guillaumeferrari/starter-kit) on {{DATE}}.
