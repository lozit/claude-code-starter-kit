---
name: adopt
description: "Use when bringing an existing (brownfield) project under groundrules: it scans, maps existing files to groundrules roles, captures intent from existing docs, and generates only what's missing. Never overwrites."
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# /groundrules:adopt

You will bring an **existing project** (already has code, docs, a git repo) under groundrules management, **without breaking anything**. Different from `bootstrap` (from-scratch) and `migrate` (updating an already-managed project). All generated files are in **English** (the plugin is English-only).

If `$ARGUMENTS` contains `--dry-run` (or `dry-run`): run all analysis phases but **write no file**; end with a "would have done" report.

If `$ARGUMENTS` contains `--full` (or `full`): select the **Full adoption** strategy without asking the Call 1 strategy question (cf. ADR 0033) — set `adoptionMode = "full"` and skip straight to it. `--full` and `--dry-run` compose: full plan, no writes. Full mode is the aggressive lane for a project you fully own — it consolidates **and reformats** by default and removes merged sources, behind a **single grouped confirmation** (Phase 3), never per-file and never silent.

## Phase 0 — Guardrails

1. If `.groundrules.json` (or a legacy pre-1.0 `.starter-kit.json`) exists in the cwd → *"This project is already managed by groundrules. Use `/groundrules:migrate` to update it."* Stop.
2. If the folder is **empty** (excluding `.git`) → *"Empty folder: use `/groundrules:bootstrap`."* Stop.
3. Otherwise → this is indeed a brownfield case, continue.
4. **Plugin update check (best-effort, never blocking)**: read `version` from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` → INSTALLED, then run via Bash with a **short timeout (~3s)** `git ls-remote --tags --refs --sort=-v:refname https://github.com/lozit/groundrules.git 'v*' | head -1`. If the latest tag is semver-greater than INSTALLED, show an informational note: *"📦 groundrules vX.Y.Z is available (installed: vINSTALLED). Two steps: `/plugin marketplace update claude-code-groundrules` (catalog only — does **not** update the installed plugin), then **reinstall** (`/plugin install groundrules@claude-code-groundrules`) and **restart Claude Code**."* **Fail silent** on timeout / no network / any error — this is the only network access in this skill and it is best-effort (cf. ADR 0015).

## Phase 1 — Scan & classification (role mapping)

1. `ls -la` + stack detection: `package.json` (Node/Nuxt/Vite…), `pyproject.toml`/`requirements.txt`, `Cargo.toml`, `go.mod`, etc. Also note: `.git/` + `git remote -v` (GitHub/GitLab), `.env`/`.env.*` (secrets), `i18n/`/`locales/` (multilingual), a data ORM/SDK (Prisma, Supabase, Drizzle…), a UI folder (`components/`, `app.vue`…).
   - **Global / enterprise CLAUDE.md**: `~/.claude/CLAUDE.md` + managed policy (`/Library/Application Support/ClaudeCode/CLAUDE.md` macOS, `/etc/claude-code/CLAUDE.md` Linux). If present → `HAS_GLOBAL_CLAUDE=true` (never overwrite it). Very common in enterprise contexts — precisely where the project CLAUDE.md must **defer**.
   - **AI attribution policy**: **read-only**, look in the detected CLAUDE.md files (project + global) for a rule forbidding AI attribution (`no AI attribution`, `Co-Authored-By`, `Generated with Claude`…). If found → `NO_AI_ATTRIBUTION=true`. Common in enterprise (some managed CLAUDE.md files forbid it explicitly).
2. **Detect superpowers**: presence of `docs/superpowers/plans/` or `specs/`. If so → different altitude, **do not** treat as root planning (see interop in the `CLAUDE.md` template).
3. **Detect `PLAN.md` equivalents** (see "Planning detection" below) — there may be **several**, possibly nested.
4. **Classify each existing item** into a groundrules role. Build a table:

| Existing | groundrules role | Proposed action |
|---|---|---|
| `README.md` | README | adopt as-is; if **boilerplate** (GitHub/GitLab "Getting started…" template) → offer to regenerate |
| `plan.md` / `TODO.md` / … | PLAN (active view) | reconciliation (Phase 2) — **never** create a `PLAN.md` that collides in case |
| `docs/**/todos.md` | backlog | adopt; document the role in `CLAUDE.md` |
| business doc (`*business-rules*`, `CR-*`, specs…) | intent source | offer as source for `intake/INTENT.md` / `docs/VISION.md` |
| `docs/superpowers/**` | per-feature artifacts | don't touch; note the interop |
| `docs/ARCHITECTURE.md`, `GLOSSARY.md`… already present | project doc | adopt as-is (don't regenerate) |
| `CLAUDE.md` present? | instructions | **absent** → to generate (see Call 3); **present** → never overwrite, see "CLAUDE.md project file already present" |

> **Large unfamiliar codebase (optional, no dependency)**: if the project is too big to read comfortably (hundreds of files / large LOC) and you'll need to synthesize `docs/ARCHITECTURE.md`, you may suggest the user run an external **knowledge-graph / GraphRAG** tool (e.g. [graphify](https://github.com/safishamsi/graphify)) first to *comprehend* the code. This is **upstream comprehension only** — its derived/inferred graph is not a groundrules artifact and creates no dependency; the curated docs you write stay the source of truth. Purely a pointer (like the superpowers interop note); never install or require anything.

### CLAUDE.md project file already present (often tool-managed)

If a `CLAUDE.md` already exists at the root (without a groundrules/starter-kit signature):

1. **Never generate or overwrite it.** There can't be two CLAUDE.md; theirs is authoritative.
2. **Detect whether it's tool-managed**: look for markers like `Auto-managed`, `Do not edit`, an enterprise manager name (e.g. `claude-manager`), managed-section fences, or an explicit **free zone** (marker like `END MANAGED` / `below this line is yours` / a `## Project-Specific Notes` heading).
3. **Gap-driven additions (opt-in, free zone only)**: if a free zone is detected, **read the existing file** and identify which groundrules **signature conventions are missing** from it — then offer (`AskUserQuestion`, multiSelect) to **append only the missing ones** (via `Edit`, append-only). Candidates: the **docs pointer** (below); the **capture-at-checkpoints** ritual; the **when-to-document** routing (ADR / LEARNINGS / PLAN); **the repo is the only memory**; **Posture** (push back / stay reversible). **Never restate what's already there; NEVER write into the managed sections.** The docs pointer:

   ```
   ### Project docs (groundrules)
   - Vision: `docs/VISION.md` · Decisions: `docs/decisions/` · Learnings: `docs/LEARNINGS.md` · Active plan: `PLAN.md`
   ```

4. If **no** free zone is detected (fully managed file with no editable section) → **skip** (write nothing), and report it in the recap.
5. Record in `.groundrules.json` `adoptedFiles["CLAUDE.md"] = "instructions (managed by <tool if known>)"`.

> In a heavily-managed context (the CLAUDE.md already covers commits, security, CHANGELOG, stack…), groundrules' value concentrates on `docs/` (VISION, decisions, LEARNINGS, intake) and `PLAN.md` — not the CLAUDE.md. Don't reintroduce duplicates. **Surface any conflict** spotted between a managed-CLAUDE.md rule and a groundrules convention (e.g. commit attribution), without resolving it yourself.

### Planning detection (broadened)

Search, excluding `node_modules`/`.git`, **case-insensitive**, up to ~3 levels deep:

```bash
find . -path ./node_modules -prune -o -path ./.git -prune -o \
  \( -iname 'plan.md' -o -iname 'todo.md' -o -iname 'todos.md' \
     -o -iname 'tasks.md' -o -iname 'backlog.md' \) -maxdepth 3 -print
```

- Report **all** results (not just the first).
- **Case guard**: **never** generate `PLAN.md` if an equivalent name exists in a different case (e.g. `plan.md`). On a case-sensitive FS (Linux/CI) this would create two files `plan.md`/`PLAN.md` → collision on checkout on macOS/Windows.

## Phase 2 — Brownfield interview (grouped questions, 4 max/call)

### Call 1 — Base
- **Confirm the project name** (suggest the `name` from `package.json` or the folder).
- **Adoption strategy** (1 question — this drives the whole run). Skip this question if `--full` was passed (strategy already fixed to Full):
  - `Map in place (default)` — existing files keep their current paths; groundrules only records their roles (`adoptedFiles`) and generates what's missing. Zero file moves. Duplicates with the canonical layout are tolerated and documented.
  - `Consolidate into the groundrules layout` — existing equivalents are **migrated** to the canonical paths (e.g. `tasks/todo.md` → `PLAN.md`, `tasks/lessons.md` → `docs/LEARNINGS.md`, business specs → `intake/`), with **per-file** confirmation and **optional** reformat. See Phase 4b.
  - `Full adoption` — for a project you fully own: like Consolidate but goes all the way (cf. ADR 0033). Reformat is the **default** (sources are transformed into the groundrules template structure), merged sources are **removed** (`git rm`) for a clean canonical layout, and Call 3b pre-checks **every applicable** doc for completeness. Everything lands behind a **single grouped confirmation** (Phase 3) — informed and reversible (git history preserved), never per-file, never silent. Sets `adoptionMode = "full"`.

### Call 2 — Intent
*"Which source for the project vision?"* — offer the **detected business docs** first:
- `Use <detected doc>` (e.g. `CR-business-rules.md`) → `Read` then synthesize into `docs/VISION.md` (and copy the source into `intake/INTENT.md`).
- `I'll paste the content` / `Another file (path)` / `Ask me the questions` / `Skip`.

Reuse `bootstrap`'s intent logic (Phase 3) for the synthesis.

### Call 3a — Core docs to generate (multiSelect, missing only)
Pre-check based on the scan. Only offer what **doesn't already exist**:
- `CLAUDE.md` **only if absent** (if it already exists → see "CLAUDE.md project file already present", no generation). If absent and **`HAS_GLOBAL_CLAUDE=true`**: generate `CLAUDE.md.tpl` with **content-aware tailoring** — read the global's content and omit only the sections it actually covers, keeping groundrules' signature conventions (deference note + omission list via `{{GLOBAL_CLAUDE_NOTE}}`). Same logic as `bootstrap` Phase 5 "CLAUDE.md generation".
- `docs/decisions/` (ADR) + `docs/LEARNINGS.md`
- `intake/` + `docs/media/` (explanatory READMEs)

### Call 3b — Optional / specialized docs (multiSelect — ALWAYS ask)

**This question is mandatory and must always be asked** (unless every option already exists on disk). Present a multiSelect listing **all** optional docs below — never silently skip it, and never gate the *list* on detection. Detection only decides what's **pre-checked**; every not-yet-existing option is still offered so the user can pick any of them.

> **Full mode (completeness pass):** when `adoptionMode = "full"`, **pre-check every applicable** option (not just the detected ones), framed as *"to be a complete groundrules project, these are still missing"*. It stays a multiSelect — the user unchecks what they don't want; nothing is generated silently (cf. ADR 0033).

- `docs/ARCHITECTURE.md` — pre-check if a code project
- `docs/GLOSSARY.md` — pre-check if domain jargon detected
- `CHANGELOG.md` — pre-check if releases/versioning detected (or a standard requires it)
- `docs/DATA_MODEL.md` — pre-check if an ORM/SDK/DB is detected
- `docs/SECURITY.md` — pre-check if `.env`/secrets/external APIs detected
- `docs/DESIGN_SYSTEM.md` — pre-check if a UI is detected
- `docs/I18N.md` — pre-check if i18n/locales detected
- `docs/ROADMAP.md` — offered (unchecked by default)
- `docs/PROCESS.md` — pre-check if a process/method doc is detected (phased workflow, validation gates)
- `RELEASE.md` — pre-check if CI/CD or hosting config is detected (`.gitlab-ci.yml`, `.github/workflows/`, `netlify.toml`, `vercel.json`…)
- `docs/AGENT-EVALS.md` — offered (unchecked by default): a log of the agent's observed failure modes (mistakes, hallucinations, drifts) + the guard added. Distinct from `LEARNINGS.md`.

Skip an individual option only if that exact file already exists (then list it under "adopted", not here). If **none** of these exist yet, the full list is shown with the detected ones pre-checked.

### Call 3c — Loop scaffolding (opt-in, off by default)

A **dedicated** single `AskUserQuestion`, same as `bootstrap` Call 2c: *"Generate optional **loop scaffolding** (`loop/`) — a maker/verifier autonomous loop for loop-safe tasks? Off by default; changes nothing until you run it."* Options: `No (recommended — add later)` / `Yes, generate loop/`. Default **No**.

- **Skip entirely** when superpowers is detected (`docs/superpowers/plans/`) — defer the whole realization to it; note in the recap.
- **Skip** if `loop/` already exists on disk (resume-safety) — list it under "adopted/left as-is", don't regenerate.
- Code projects only. If `Yes` → `HAS_LOOP=true`.
- **`## Invariants`**: if adopt is **generating** `CLAUDE.md` (absent case, Call 3a) → insert the section like `bootstrap` (after `## Conventions`). If `CLAUDE.md` **already exists** → do **not** edit it beyond the free zone; instead offer to add a `## Invariants` section to the **free zone** (gap-driven, opt-in), else note in the recap that the user should add one (the verifier reads it).
> If the strategy is **Consolidate**, default to the `Consolidate` option below (the user already opted into migration) — still confirm the canonical target.

If **one or more** equivalents found:
- **Adopt the existing one** → no `PLAN.md`; record the file(s) with the PLAN role in `.groundrules.json`.
- **Generate `PLAN.md` separately** → only if **no** case collision; the user accepts the coexistence.
- **Consolidate** → carry the existing tasks into the file chosen as canonical; suggest (without doing it) deleting the duplicates.
If several equivalents: clarify their roles (e.g. `plan.md` = active view, `docs/gtd/todos.md` = backlog) and document them in `CLAUDE.md`. If superpowers present: `PLAN.md`/`plan.md` should **point to** the active superpowers plan.

## Phase 3 — Recap & confirmation

Show, in clear text:
- 🆕 Files that will be **created** (missing)
- 🔗 Files **adopted** (existing, mapped to a role, unmodified) — map-in-place strategy
- 🚚 Files that will be **migrated** to a canonical path (consolidate strategy): `old path → new path`, with the migration mode (`git mv` / merge)
- ⏭️ Files **left as-is** (foreign, unmapped)
- ❗ Warnings (case collision avoided, README boilerplate, fragmented planning)

Then `AskUserQuestion`: `Confirm` / `Cancel`. (In `--dry-run`, stop here with the report.)

> **Full mode — this recap is the single confirmation gate** (cf. ADR 0033). Because Phase 4b will **not** re-prompt per file in Full mode, this recap must enumerate **every** action it will take: each `🚚` migrate/merge, each file that will be **reformatted** into the template structure, and each merged source that will be **removed** (`git rm`). The one `Confirm` here authorizes all of it. If the list is too long to be a meaningful single decision, say so and offer to fall back to Consolidate (per-file) instead.

## Phase 4 — Generation (missing only)

For each file to create: same mechanics as `bootstrap` Phase 5 (read the template `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/<tpl>`, substitute `{{KEY}}`, `Write`). **Never overwrite** an existing file; **never delete**.

If `HAS_LOOP=true`: generate the `loop/` namespace exactly as `bootstrap` (same file-mapping rows — `README.md.tpl` substituted, the rest verbatim, `run-loop.sh` made executable, `gitignore` → `loop/.gitignore`; do not create `blocked.md`/`lessons.md`). Skip any `loop/*` file that already exists (missing-only). Record the created files in `generatedFiles`.

## Phase 4b — Consolidation (only if strategy = Consolidate or Full)

> **Full vs Consolidate.** In **Consolidate**, every step below is **per-file confirmed** (3–4 at a time) and reformat is **offered**. In **Full** mode (cf. ADR 0033), the **Phase 3 recap already authorized everything** — so here you **do not re-prompt**: reformat is **applied by default** (step 3), and merged sources are **removed** (`git rm`, step 2) by default. Execute the recap; don't ask again.

For each adopted file whose role has a **canonical groundrules path** (PLAN → `PLAN.md`, learnings → `docs/LEARNINGS.md`, design system → `docs/DESIGN_SYSTEM.md`, data model → `docs/DATA_MODEL.md`, release runbook → `RELEASE.md`, upstream specs/raw inputs → `intake/`, glossary → `docs/GLOSSARY.md`…), migrate it — in Consolidate, **each file individually confirmed** (group the questions 3-4 at a time); in Full, per the authorized recap:

1. **1:1 move** (the source IS the artifact, target doesn't exist): `git mv <old> <new>` — preserves history. Binary inputs (Excel, images…) going to `intake/` are plain `git mv` too.
2. **Merge** (target already exists or was just generated, or several sources feed one target): `Read` the source(s), integrate the content into the target's structure (e.g. existing lessons become LEARNINGS entries; existing tasks land in the PLAN sections), `Write` the target. Then the source file's fate: in **Consolidate**, ask — `Remove it (git rm)` / `Keep it with a pointer line` ("→ migrated to <new path>") / `Keep as-is` (default keep-with-pointer). In **Full**, default to `Remove it (git rm)` for a clean canonical layout — no prompt (it was listed in the Phase 3 recap).
3. **Reformat**: when the source format differs from the groundrules template (e.g. raw lessons → rule format with Why / When to apply) — in **Consolidate**, offer `Migrate as-is` / `Migrate and reformat`; in **Full**, **reformat by default** (no prompt).
4. After all moves: **sweep internal references** — update paths that pointed to the old locations in `CLAUDE.md`, `README.md` and the migrated docs themselves (show what changed). **Exclude historical records**: past CHANGELOG entries, migration notes and dated logs describe the old paths *truthfully* — rewriting them falsifies history.

Never migrate: code, configs, CI files, anything not mapped to a groundrules doc role. When in doubt, leave it and report.

In `--dry-run`: list every planned move/merge without touching anything.

## Phase 5 — Backfill `.groundrules.json`

Write `.groundrules.json` (bootstrap schema, see ADR 0004) with the adoption markers:

```json
{
  "groundrulesVersion": "<current version>",
  "adopted": true,
  "adoptedAt": "YYYY-MM-DD",
  "bootstrappedWithVersion": null,
  "migrations": [],
  "answers": { ... interview ... },
  "intent": { "source": "file|paste|interview|skipped", ... },
  "appliedPractices": [],
  "loop": { "scaffolded": true | false, "at": "YYYY-MM-DD" | null },
  "policies": { "noAiAttribution": true | false },
  "generatedFiles": [ ... files CREATED by adopt ... ],
  "adoptedFiles": { "<path>": "<role: README|PLAN|backlog|intent-source|...>" },
  "adoptionMode": "map" | "consolidate" | "full",
  "migratedFiles": { "<old path>": "<new path>" },
  "skippedFiles": { "<path>": "<reason>" }
}
```

`adoptionMode` records the strategy (`map` / `consolidate` / `full`). `migratedFiles` (consolidate **and** full) maps old → new paths so `migrate`/`verify-bootstrap` know the provenance; migrated targets also join `generatedFiles` (they are now canonical, template-diffable files).

`adopted: true` + `bootstrappedWithVersion: null` distinguish an adopted project from a bootstrapped one. `adoptedFiles` maps the existing files to roles (info for `migrate`/`verify-bootstrap`).

## Phase 5b — Adoption log (opt-in)

After the backfill, **offer** (one `AskUserQuestion`) to write a human-readable **`docs/ADOPTION-LOG.md`** — a dated, frozen record of this run, designed so the maintainer can annotate it and **share it back to improve groundrules** (a field → plugin feedback channel; distinct from `docs/AGENT-EVALS.md` and `apply-best-practices`). Skip if declined.

If accepted:
1. Read `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/ADOPTION-LOG.md.tpl`.
2. Substitute `{{PROJECT_NAME}}`, `{{DATE}}` (`date +%F`), and:
   - `{{DETECTED}}` — from the **Phase 1 scan**: structure, docs present/absent, detected stack, planning files, existing project CLAUDE.md (managed?), global CLAUDE.md presence + what it covers.
   - `{{ACTIONS}}` — from the run + `.groundrules.json`: files **generated** / **adopted (mapped)** / **skipped** / **migrated**, the `adoptionMode`, and the **key decisions, each with a one-line *why*** (e.g. content-aware CLAUDE.md omissions, consolidate vs map-in-place, deferral to a managed CLAUDE.md, planning reconciliation). **Be honest** — record skips/deferrals and their reasons, not a success-only story (Posture).
3. Write `docs/ADOPTION-LOG.md`. **Resume-safe**: if it already exists, never overwrite silently — skip / overwrite / write `docs/ADOPTION-LOG.md.new` instead. Leave the **Remarks** section as the template's prompts (the user fills it).
4. **Only if you wrote the canonical `docs/ADOPTION-LOG.md`** (not on a skip or a `.new`): append `"docs/ADOPTION-LOG.md"` to `generatedFiles` in `.groundrules.json`.

(Source of truth: `{{DETECTED}}` comes from the **Phase 1 scan**; `{{ACTIONS}}` from `.groundrules.json` + the run — if the two ever disagree, the recorded `.groundrules.json` wins for the actions.)

## Phase 6 — Final recap

- ✅ Created / 🔗 Adopted / ⏭️ Left as-is
- 📝 If opted in: `docs/ADOPTION-LOG.md` — **annotate it and share it back** to improve groundrules.
- 📋 Next steps:
  1. Flesh out `CLAUDE.md` (Setup/Build/Test from the project scripts, stack, gotchas)
  2. If intent captured: `/groundrules:apply-best-practices`
  3. Re-read `docs/VISION.md`; amend if the synthesis missed something
  4. Decide the fate of fragmented planning (consolidate if relevant)
  5. Commit when ready — **if `NO_AI_ATTRIBUTION=true`**, the commit message must contain **no** AI attribution marker (`Co-Authored-By`, "Generated with Claude Code"…), even if a default agent guideline would add it. adopt **does not commit** itself; it only provides a compliant suggested message.
  6. **Team-sharing**: an adopted repo is, by definition, already shared. The generated docs reference `/groundrules:*` commands, but the **plugin doesn't travel with `git clone`** — collaborators who only clone won't have them. Suggest installing groundrules at **Project scope** so it's committed to `.claude/settings.json` and collaborators are prompted to install on clone: *"Run `/plugin install groundrules@claude-code-groundrules` and choose **Project** scope."* Only surface this if `.claude/settings.json` doesn't already carry a project-scope groundrules entry; don't block on it (the docs are plain markdown, readable without the plugin — only the slash-command ergonomics need it). Cf. ADR 0023.

**No `git init`** (the project already has git) nor remote creation. If `.git/` is absent: report it and suggest `git init`, without imposing it.

## Important rules

- **Never overwrite or delete** without explicit action. In map-in-place mode adopt never deletes — it suggests. In consolidate mode, removals of migrated sources happen only via the per-file `git rm` confirmation of Phase 4b (default remains keep-with-pointer). In **full** mode, removals (`git rm`) and reformats are the default but happen only after the **single grouped confirmation** of Phase 3 enumerated them — informed and reversible (git history), never silent (cf. ADR 0033).
- **Case guard**: never create a file that collides in case with an existing one.
- **superpowers**: `docs/superpowers/**` is not root planning — different altitude, don't touch it.
- **Faithfulness to the source** for intent synthesis: don't invent; "To be defined" if the source is thin.
- `--dry-run`: no writes, just the report.
- **Never commit automatically.**
