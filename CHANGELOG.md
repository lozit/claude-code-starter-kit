<!-- generated-by: starter-kit v0.3.0 -->
# Changelog

All notable changes to this project are documented in this file.

Format inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased — 0.3.0]

### Added
- New skill `/starter-kit:add-adr` — creates a new ADR in `docs/decisions/` with auto-incremented number, language inferred from `.starter-kit.json`, slugified filename, and automatic index update in `decisions/README.md`. Accepts `$ARGUMENTS` for the title.
- New skill `/starter-kit:learn` — prepends a dated entry to `docs/LEARNINGS.md`. Short by design (title + 1-line context + 1-line lesson). Accepts `$ARGUMENTS` for the title.
- First two real ADRs documenting the project's lived experience:
  - `0001-marketplace-json-location.md`
  - `0002-plain-text-placeholder-substitution.md`

### Changed
- Plugin version bumped 0.2.0 → 0.3.0 in `.claude-plugin/plugin.json`, `marketplace.json`, all template signatures, `.starter-kit.json`.

## [0.2.0] — internal, never released

### Added
- `CLAUDE.md.{fr,en}.tpl` restructured to integrate best practices from `shanraisshan/claude-code-best-practice` and `howborisusesclaudecode.com`:
  - "Setup / Build / Test" section at the top (executable commands first)
  - "Mettre à jour ce fichier" philosophy: CLAUDE.md is mutable, update it after every Claude mistake (Boris Cherny)
  - References to `.claude/settings.json`, `.claude/rules/*.md` (`paths:` scoping), `<important if="...">` tags
  - "Vérifier le travail" section ("Prove to me this works", behavior diff requirement)
  - "Workflow Claude Code" section: plan mode, `/compact`, `/clear`, git worktrees, delegation model (Opus 4.6+)
- EN variants for all previously FR-only templates (LEARNINGS, brief, media, PLAN, ARCHITECTURE, CHANGELOG, GLOSSARY, adr-template)
- `adr-template.md` split into `adr-template.fr.md` and `adr-template.en.md`; SKILL.md mapping updated to `adr-template.{lang}.md`

### Changed
- `PLAN.md.tpl` (FR and EN): replaced project-specific placeholder tasks with a neutral "(add the first active tasks here)"

### Fixed
- `marketplace.json` moved from repo root into `.claude-plugin/` (Claude Code expects this exact path)
- V0.1 gap: choosing LANG=en used to produce FR-content files for everything except CLAUDE.md/README.md/decisions-README

## [0.1.0] — internal, never released

### Added
- Initial scaffolding of the plugin: `.claude-plugin/plugin.json`, `marketplace.json`, `skills/bootstrap/SKILL.md` with 7-phase interactive workflow, 15 templates (`.tpl`) covering CLAUDE.md, README, ADR, LEARNINGS, brief, media, ARCHITECTURE, GLOSSARY, CHANGELOG, PLAN, etc.
- Root `CLAUDE.md` explaining the two-layer architecture (plugin sources vs project docs).
- Dogfood: the repo applied `/starter-kit:bootstrap` on itself.
