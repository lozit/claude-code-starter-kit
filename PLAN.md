<!-- generated-by: starter-kit v0.4.0 -->
# PLAN — Starting-Claude

**Active** plan/todo for the project. Maintained by Claude during work.

This file differs from the long-term roadmap: it describes what is happening **now**.

## In progress

- [ ] End-to-end validation: bootstrap a fresh project at V0.4, then artificially "downgrade" `.starter-kit.json` to "0.1.0" and run `/starter-kit:migrate --dry-run` to verify diff logic, then re-run without dry-run to verify writes

## Up next

- [ ] Publish marketplace on GitHub for shareable distribution (`gh repo create`, push, share `/plugin marketplace add` URL)
- [ ] Optional V0.5 — hook (pre-commit?) that auto-bumps `<!-- generated-by -->` signatures when migrating, instead of relying on full-file rewrite

## Waiting / blocked

- [ ] ...

## Recently done

- [x] ADR 0003 — multi-skill architecture rationale (2026-05-11)
- [x] ADR 0004 — `.starter-kit.json` schema with `bootstrappedWithVersion` and `migrations` (2026-05-11)
- [x] V0.4 — skill `/starter-kit:migrate` with diff-per-file + `.new` fallback + `--dry-run` (2026-05-11)
- [x] V0.3 — skills `/starter-kit:add-adr` and `/starter-kit:learn` (2026-05-11)
- [x] First two ADRs written: `0001-marketplace-json-location.md`, `0002-plain-text-placeholder-substitution.md` (2026-05-11)
- [x] Smoke test of V0.2 CLAUDE.md template in `/tmp/starter-kit-v02-smoke/` — 0 placeholder leftover (2026-05-11)
- [x] V0.2 — `CLAUDE.md.{fr,en}.tpl` restructured with Boris Cherny / shanraisshan best practices (2026-05-11)
- [x] V0.1.1 — EN variants for all FR-only templates (2026-05-11)
- [x] V0.1 — Project bootstrapped, skill + 15 templates + dogfood (2026-05-11)

---

**Convention**: Claude updates this file at the start/end of each session. Completed tasks stay in "Recently done" for ~1 week then are archived (deleted or moved to CHANGELOG).
