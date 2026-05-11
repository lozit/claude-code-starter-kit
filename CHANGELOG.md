<!-- generated-by: starter-kit v0.4.0 -->
# Changelog

All notable changes to this project are documented in this file.

Format inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased — 0.4.0]

### Added
- New skill `/starter-kit:migrate` — upgrades a starter-kit-bootstrapped project to the current plugin version:
  - Reads `OLD` from `.starter-kit.json`, `NEW` from `plugin.json`
  - For each tracked file: regenerates content with original answers, compares to disk, classifies as identical / content-differs
  - Detects new templates introduced in newer versions (proposes optional creation)
  - Per-file decision via `AskUserQuestion`: show diff / overwrite / keep mine / save as `.new` (for manual merge)
  - Updates `.starter-kit.json` with new version + migration entry
  - Supports `--dry-run` via `$ARGUMENTS` (reports without writing)
  - Refuses downgrade if project version > plugin version
  - Never commits automatically

### Changed
- `.starter-kit.json` schema extended:
  - `bootstrappedWithVersion` — frozen at first bootstrap (does NOT change on migration)
  - `migrations` — array of `{from, to, at}` entries, appended on each migration
  - `starterKitVersion` remains the "current effective" version (mutable)
  - Backward-compatible: migrate handles missing fields with sensible defaults
- `bootstrap/SKILL.md` phase 4: documents the new `.starter-kit.json` schema explicitly
- Plugin version bumped 0.3.0 → 0.4.0

## [0.3.0] — internal, never released

### Added
- New skill `/starter-kit:add-adr` — creates a new ADR in `docs/decisions/` with auto-incremented number, language inferred from `.starter-kit.json`, slugified filename, and automatic index update in `decisions/README.md`. Accepts `$ARGUMENTS` for the title.
- New skill `/starter-kit:learn` — prepends a dated entry to `docs/LEARNINGS.md`. Short by design (title + 1-line context + 1-line lesson). Accepts `$ARGUMENTS` for the title.
- First two real ADRs documenting the project's lived experience:
  - `0001-marketplace-json-location.md`
  - `0002-plain-text-placeholder-substitution.md`

## [0.2.0] — internal, never released

### Added
- `CLAUDE.md.{fr,en}.tpl` restructured to integrate best practices from `shanraisshan/claude-code-best-practice` and `howborisusesclaudecode.com`:
  - "Setup / Build / Test" section at the top
  - "Mettre à jour ce fichier" philosophy (Boris Cherny)
  - References to `.claude/settings.json`, `.claude/rules/*.md`, `<important if="...">` tags
  - "Vérifier le travail" / "Prove to me this works" section
  - "Workflow Claude Code" section: plan mode, `/compact`, `/clear`, git worktrees, delegation model
- EN variants for all previously FR-only templates
- `adr-template.md` split into `adr-template.{fr,en}.md`

### Fixed
- `marketplace.json` moved from repo root into `.claude-plugin/`
- V0.1 gap: LANG=en producing FR-content files for non-CLAUDE templates

## [0.1.0] — internal, never released

### Added
- Initial scaffolding: `.claude-plugin/plugin.json`, `marketplace.json`, `skills/bootstrap/SKILL.md` with 7-phase interactive workflow, 15 templates covering CLAUDE.md, README, ADR, LEARNINGS, brief, media, ARCHITECTURE, GLOSSARY, CHANGELOG, PLAN.
- Two-layer architecture (plugin sources vs project docs), dogfood applied to the repo itself.
