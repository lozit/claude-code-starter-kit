<!-- generated-by: groundrules v1.10.0 -->
# 0023 — Recommend project-scope install for team portability (no CLAUDE.md bloat, no vendoring)

**Date**: 2026-06-08
**Status**: Accepted

## Context

A groundrules-bootstrapped repo's `CLAUDE.md` references `/groundrules:*` commands. But a Claude Code **plugin is installed per-user (or per-machine), not in the repo** — it does **not** travel with `git clone`. A collaborator who clones the project without installing groundrules has no `/groundrules:*` commands: the model reads the instruction in `CLAUDE.md` and the command fails ("not found"). (Verified against the Claude Code docs, 2026-06-08.)

The *capability* isn't lost — every artifact is plain markdown, readable by any agent, and the manual procedures (ADR template, LEARNINGS format) are documented — but the slash-command **ergonomics** are unavailable.

Two ways to close the gap were considered against groundrules' principles (context economy / ADR 0021: keep `CLAUDE.md` small; template-over-code / ADR 0002).

## Decision

**Recommend installing groundrules at *Project scope*** for shared repos. A project-scope install commits the plugin reference to `.claude/settings.json` (which *does* travel with the clone), so collaborators are **prompted to install** it when they trust the cloned folder — the commands then work for the whole team.

groundrules acts on this **at creation/adoption time, not in the generated files**:
- `bootstrap` (Phase 8) and `adopt` (Phase 6) **suggest** the project-scope install in their next-steps — only if `.claude/settings.json` doesn't already carry a project-scope groundrules entry, and never blocking.
- The README Installation section documents it for teams.
- The generated `CLAUDE.md` is **left untouched** (no manual-fallback prose) — that would bloat the always-loaded file against ADR 0021.

## Alternatives considered

- **Explain the no-plugin manual procedures in the generated `CLAUDE.md`** — rejected: bloats the always-loaded file (ADR 0021). The advice belongs in the skill's one-time output, not in a file loaded every session.
- **Vendor the skills into the repo's `.claude/skills/`** (so `/add-adr` etc. travel with the clone, no install, offline) — rejected for now: frozen copies that don't get plugin updates (must re-vendor on `migrate`), duplication in every project (fights template-over-code), and a namespace fork (`/groundrules:add-adr` → `/add-adr`) that would force the generated `CLAUDE.md` to pick one form. Project scope keeps a single source of truth with propagating updates. (A "split meta-vs-capture skills" variant of vendoring was considered and parked — it's a larger architecture change worth its own ADR if ever pursued.)
- **Do nothing** — rejected: silent dead-end commands for collaborators is a real UX trap worth a one-line suggestion at creation time.

## Consequences

### Positive
- Collaborators get the commands with a single prompt-to-install on clone; no duplication; plugin updates propagate; zero `CLAUDE.md` bloat.
- The suggestion fires exactly when it's actionable (bootstrap/adopt), not as permanent doc weight.

### Negative / Tradeoffs
- Project scope still isn't zero-effort: the collaborator gets a **prompt** and needs the **network** once to fetch the marketplace/plugin. True offline/zero-action sharing would require vendoring (rejected above).
- The recommendation depends on the user choosing Project (not User) scope at install time — groundrules can suggest but not force it.

## Notes

- The capability (read/write the docs, follow the conventions by hand) survives without any plugin — only ergonomics need it. groundrules' plain-markdown, template-over-code design is what makes this graceful.
