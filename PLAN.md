<!-- generated-by: starter-kit v0.5.0 -->
# PLAN — Starting-Claude

**Active** plan/todo for the project. Maintained by Claude during work.

This file differs from the long-term roadmap: it describes what is happening **now**.

## In progress

- [ ] End-to-end real-world test on a **fresh project** (not the dogfood): bootstrap V0.5 in `/tmp` to validate the intent capture flow on a from-scratch dossier (already validated on the dogfood via the V0.5 commit + the apply-best-practices run)

## Up next

- [ ] Optional V0.6 — hook (pre-commit?) that auto-bumps `<!-- generated-by -->` signatures when migrating

## Waiting / blocked

- [ ] ...

## Recently done

- [x] First real-world run of `/starter-kit:apply-best-practices` on the dogfood: 12 recommendations fetched, 6 truly new (4 applied, 2 deferred), `.claude/rules/plugin-meta.md` + `.claude/settings.json` + meta CLAUDE.md "Plugin workflow" section + `docs/best-practices-pending.md` created (2026-05-11)
- [x] ADR 0005 — Intent capture in bootstrap + separate apply-best-practices skill (2026-05-11)
- [x] V0.5 — intent capture in `bootstrap` (Phase 3) + new skill `/starter-kit:apply-best-practices` + dogfood backfill of `brief/00-INTENT.md` + `docs/00-VISION.md` (2026-05-11)
- [x] Published to GitHub: https://github.com/lozit/claude-code-starter-kit (public marketplace) (2026-05-11)
- [x] ADR 0003 — multi-skill architecture rationale (2026-05-11)
- [x] ADR 0004 — `.starter-kit.json` schema with `bootstrappedWithVersion` and `migrations` (2026-05-11)
- [x] V0.4 — skill `/starter-kit:migrate` with diff-per-file + `.new` fallback + `--dry-run` (2026-05-11)
- [x] V0.3 — skills `/starter-kit:add-adr` and `/starter-kit:learn` (2026-05-11)
- [x] First two ADRs written: `0001-marketplace-json-location.md`, `0002-plain-text-placeholder-substitution.md` (2026-05-11)
- [x] V0.2 — `CLAUDE.md.{fr,en}.tpl` restructured with Boris Cherny / shanraisshan best practices (2026-05-11)
- [x] V0.1.1 — EN variants for all FR-only templates (2026-05-11)
- [x] V0.1 — Project bootstrapped, skill + 15 templates + dogfood (2026-05-11)

---

**Convention**: Claude updates this file at the start/end of each session. Completed tasks stay in "Recently done" for ~1 week then are archived (deleted or moved to CHANGELOG).
