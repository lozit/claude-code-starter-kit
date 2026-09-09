<!-- generated-by: groundrules v1.11.0 -->
# 0009 — Global / enterprise CLAUDE.md awareness + lean project CLAUDE.md

**Date**: 2026-06-03
**Status**: **Superseded by [ADR 0029](0029-content-aware-claude-md-tailoring.md)** (2026-06-14) — the lean template and existence-only detection are replaced by content-aware tailoring of a single template. The global-awareness *intent* of this ADR stands; its *mechanism* (a separate lean template, presence-based) does not.

## Context

Many organizations ship a **global `~/.claude/CLAUDE.md`** to every employee (e.g. a workflow classifier, superpowers override, mandatory MCP/tool preferences, git/GitLab rules, verification policy, output style). Claude Code **loads and concatenates** the memory hierarchy — managed-enterprise, project, user/global — into context; none overwrites another **on disk**, and the more-specific (project) file tends to weigh heavily when reconciling conflicts.

The user asked: does our generated project `CLAUDE.md` risk clobbering enterprise directives?

- **File level**: No. `bootstrap`/`adopt` only ever write `<repo>/CLAUDE.md`; they never touch `~/.claude/CLAUDE.md`. Different paths, both loaded together.
- **Directive level**: Yes — the real risk. Our default template restates generic rules (commit conventions, "verify the work", Claude Code workflow, output style, "don't do X") that the enterprise global already owns, often **more strictly or differently**. Because the project file is more specific, these generic restatements can **dilute or contradict** enterprise intent even without a file overwrite. Concretely against a typical enterprise global: our generic "Conventional Commits" vs a mandatory MR skill + a GitLab MCP; our generic "Workflow Claude Code" vs the org's own task-complexity classifier + workflow skills.

## Decision

Make the generated project `CLAUDE.md` **defer to and not duplicate** a detected global.

1. **Detection** (Phase 1 of `bootstrap` and `adopt`): set `HAS_GLOBAL_CLAUDE=true` if any of `~/.claude/CLAUDE.md`, `/Library/Application Support/ClaudeCode/CLAUDE.md` (macOS managed), `/etc/claude-code/CLAUDE.md` (Linux managed) exists. The global is **never read for modification** — only its existence matters.

2. **Lean variant** (chosen default when a global is detected): new templates `CLAUDE.lean.md.{fr,en}.tpl` that keep only **project-specific** sections (Description, Setup/Build/Test, key files, project-specific conventions, when-to-document, update-this-file, notes) and bake in a deference header: *"loaded in addition to the global; holds project-specific content only; on conflict the global/enterprise rule wins."* Generic sections (commits, workflow, verification, output, generic don'ts) are dropped because the global owns them.

3. **Full variant with deference note**: the full `CLAUDE.md.{fr,en}.tpl` gains a `{{GLOBAL_CLAUDE_NOTE}}` placeholder — substituted with the deference note when a global is detected and the user opts for the full template, or with the **empty string** otherwise (no global → no note, zero noise).

When `HAS_GLOBAL_CLAUDE=true`, the skill asks one question: lean (recommended) vs full-with-note.

## Alternatives considered

- **Unconditional note in the template (no detection)** — rejected as primary: adds noise to projects with no global. The placeholder approach gives the note only when relevant.
- **Do nothing (no overwrite anyway)** — rejected: misses the real (directive-level) risk; users would silently get a project file that fights their enterprise rules.
- **Auto-slim by parsing the global and removing overlapping sections** — rejected: too clever, fragile, and against the template-over-code constraint (ADR 0002). A curated lean template is predictable.
- **Always generate lean when a global exists (no choice)** — rejected: some teams *want* the full generic scaffold even with a global. Offer, don't impose.

## Consequences

### Positive
- No enterprise directive is overwritten (file) **or** silently diluted (content).
- In enterprise contexts (the common `adopt` case), the project file is a clean complement, not a competitor.
- The empty-string default keeps non-enterprise projects unchanged.

### Negative / Tradeoffs
- A second pair of CLAUDE templates (lean FR/EN) to keep roughly in sync with the full ones. Mitigated: lean is intentionally minimal, so drift pressure is low.
- Detection is existence-only; it can't know whether the global *actually* covers a given topic. The lean template therefore states the principle ("don't restate global rules") rather than enumerating exact overlaps.
- `{{GLOBAL_CLAUDE_NOTE}}` is a placeholder that must be substituted (added to the `verify-bootstrap` whitelist so a leftover is caught).

### Neutral
- Detected enterprise tooling overlap (e.g. an org's own project-bootstrap skill that also creates a project CLAUDE.md) is out of scope here — the deference note simply makes coexistence safe.

## Notes

- Templates added: `CLAUDE.lean.md.{fr,en}.tpl`. Placeholder added: `{{GLOBAL_CLAUDE_NOTE}}` (full template).
- See [ADR 0002](0002-plain-text-placeholder-substitution.md) (template-over-code) and [ADR 0008](0008-adopt-brownfield-projects.md) (adopt — the main enterprise entry point).
