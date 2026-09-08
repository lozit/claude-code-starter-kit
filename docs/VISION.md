<!-- generated-by: groundrules v1.11.0 -->
# Vision — groundrules

> Synthesis of the project intent. Source: `intake/INTENT.md` (retroactive paste of the original prompt). Update when the intent evolves (rare; tactical decisions go in `docs/decisions/`).

## Goal

Build a shareable Claude Code plugin that standardizes the bootstrapping of new projects via an interactive slash command. The plugin must generate a coherent documentation structure (CLAUDE.md aligned with best practices, docs/, ADR, learnings, intake, media, vision/intent), initialize git, and optionally create the GitHub/GitLab remote. Bonus: dynamically apply best practices fetched online, tailored to each project's vision.

## Users / personas

- **Guillaume Ferrari** (solo) — uses the tool to start his own Claude Code projects quickly and with consistent documentation discipline.
- **Claude Code community** (secondary) — anyone installing the plugin via the public marketplace on GitHub (`lozit/claude-code-groundrules`).

## Constraints

- Must be a **native Claude Code plugin** (`.claude-plugin/plugin.json` + `marketplace.json` + `skills/`) — no external runtime.
- **No template engine** (Jinja, Handlebars) — plain text substitution on `{{KEY}}` (cf. ADR 0002).
- **English-only** for all user templates (cf. ADR 0012) — the bilingual FR/EN support was dropped in V0.8 (maintenance for no benefit; all projects are done in English).
- **Stack-agnostic**: no strong opinion on Node, Python, etc. — minimal `.gitignore` by default.
- Must work **mostly offline**: `apply-best-practices` is the only skill that requires the internet (WebFetch); `bootstrap`/`adopt`/`migrate` only attempt a best-effort update check that fails silent offline (ADR 0015).
- **Generated CLAUDE.md under 200 lines** (shanraisshan target) to stay usable.

## V1 non-goals

- **Does not replace writing CLAUDE.md** — it's a starter, not a smart generator. The user edits and enriches the generated CLAUDE.md.
- **No CI/CD management** — no GitHub Actions or GitLab CI templates by default. That's the project's responsibility, not the starter's.
- **No support for non-Claude-Code tooling in V1** — Cursor, Continue, other assistants are not targeted yet. Extending groundrules to other harnesses is an explicit **post-1.0 direction** (the repo is named `groundrules`, harness-neutral, for that reason).
- **No application-code generation** — no React/Python/etc. skeleton. The plugin produces docs + structure, not code.
- **No proprietary agentic AI for intent synthesis** — simply use Claude (the plugin runtime) to synthesize brief → vision.

## V1 acceptance criteria

- A user can bootstrap a new project in < 5 minutes: `mkdir foo && cd foo && claude` → `/groundrules:bootstrap` → interview answers → generated files + git initialized.
- 7 operational skills: `bootstrap`, `adopt`, `add-adr`, `learn`, `migrate`, `apply-best-practices`, `verify-bootstrap`.
- Generated structure: `README.md`, `CLAUDE.md` (with Setup/Build/Test, Verifying the work, Updating this file, Claude Code workflow sections, etc.), `docs/decisions/`, `docs/LEARNINGS.md`, `intake/`, `docs/media/`, optionally `PLAN.md` / `ARCHITECTURE.md` / `GLOSSARY.md` / `CHANGELOG.md` / `VISION.md` / specialized docs (`DATA_MODEL` / `SECURITY` / `DESIGN_SYSTEM` / `ROADMAP` / `I18N`).
- Intent capturable at bootstrap (brief paste / brief file / interview / skip).
- `apply-best-practices` fetches shanraisshan, filters by the project vision, proposes a multi-select, applies the safe items automatically.
- Plugin published on GitHub with a public marketplace: installable via `/plugin marketplace add https://github.com/lozit/groundrules`.
- Dogfood: the `groundrules` repo itself uses its own structure and its own vision (this file).

---

To go further:
- `intake/` — raw upstream notes (specs, emails, brainstorms) — see `intake/INTENT.md` for the original prompt
- `docs/decisions/` — structural decisions (12 ADRs to date)
- `docs/LEARNINGS.md` — non-trivial learnings
- `docs/ARCHITECTURE.md` — architecture snapshot (two layers: plugin sources / dogfood project)
