<!-- generated-by: starter-kit v0.3.0 -->
# PLAN — Starting-Claude

**Active** plan/todo for the project. Maintained by Claude during work.

This file differs from the long-term roadmap: it describes what is happening **now**.

## In progress

- [ ] End-to-end validation in a fresh Claude session: run `/starter-kit:add-adr` and `/starter-kit:learn` on a real project to confirm the prompts work (smoke test only validates that SKILL.md instructions parse)

## Up next

- [ ] V0.4 — `/starter-kit:migrate` skill (upgrade projects bootstrapped with older versions, e.g., re-apply newer CLAUDE.md template structure while preserving user edits)
- [ ] Publish marketplace on GitHub for shareable distribution (`gh repo create`, push, share `/plugin marketplace add` URL)
- [ ] ADR 0003 — three-skill architecture (bootstrap + add-adr + learn) and disable-model-invocation policy

## Waiting / blocked

- [ ] ...

## Recently done

- [x] V0.3 — skills `/starter-kit:add-adr` and `/starter-kit:learn` (2026-05-11)
- [x] First two ADRs written: `0001-marketplace-json-location.md`, `0002-plain-text-placeholder-substitution.md` (2026-05-11)
- [x] Smoke test of V0.2 CLAUDE.md template in `/tmp/starter-kit-v02-smoke/` — 0 placeholder leftover, all sections render (2026-05-11)
- [x] V0.2 — `CLAUDE.md.{fr,en}.tpl` restructured to integrate best practices from shanraisshan/howborisusesclaudecode (Setup/Build/Test, mutable file philosophy, settings/rules, verification, plan mode, worktrees) (2026-05-11)
- [x] V0.1.1 — EN variants for LEARNINGS, brief, media, PLAN, ARCHITECTURE, CHANGELOG, GLOSSARY, adr-template (2026-05-11)
- [x] V0.1 — Project bootstrapped, skill + 15 templates + dogfood (2026-05-11)

---

**Convention**: Claude updates this file at the start/end of each session. Completed tasks stay in "Recently done" for ~1 week then are archived (deleted or moved to CHANGELOG).
