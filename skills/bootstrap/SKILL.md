---
name: bootstrap
description: Use when starting a new, empty project and you want the full groundrules structure generated interactively (CLAUDE.md, docs/, intent capture, git init, optional remote).
disable-model-invocation: true
allowed-tools: Read, Write, Bash, AskUserQuestion
---

# /groundrules:bootstrap

You will bootstrap a Claude Code project in the **current working directory**. Follow these phases in order, without skipping any. All generated files are in **English** (the plugin is English-only).

## Phase 0 — Plugin update check (best-effort, never blocking)

1. Read `version` from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` → INSTALLED.
2. Run via Bash with a **short timeout (~3s)**: `git ls-remote --tags --refs --sort=-v:refname https://github.com/lozit/groundrules.git 'v*' | head -1`
3. Extract the tag (`refs/tags/vX.Y.Z`). If semver-greater than INSTALLED, show an informational note (don't ask, don't stop):
   > 📦 groundrules vX.Y.Z is available (installed: vINSTALLED). Updating is **two steps** — `/plugin marketplace update claude-code-groundrules` refreshes the catalog but **does not** update the installed plugin; then **reinstall it** (`/plugin install groundrules@claude-code-groundrules`) and **restart Claude Code** (a new skill needs a full restart, not just `/reload-plugins`).
4. **Fail silent**: on timeout, no network, or any error, continue without mentioning the check. This is the only network access in this skill and it is best-effort (cf. ADR 0015).

## Phase 1 — Scan the folder

1. Run `ls -la` on the cwd.
2. Detect the following markers and note what is present:
   - `.git/` (existing git repo)
   - `.groundrules.json` (state from a previous invocation — if present, **load it**; it is what selects `resume` in the mode table at step 4, and this line does not decide the mode on its own); a legacy pre-1.0 `.starter-kit.json` counts the same — load it and recommend `/groundrules:migrate` (V1.0 renamed the plugin and the state file)
   - `CLAUDE.md`, `README.md`, `docs/`, `intake/`, `docs/media/`, `PLAN.md`, `CHANGELOG.md`, `.gitignore`, `docs/VISION.md`, `intake/INTENT.md`
   - optional specialized docs: `docs/DATA_MODEL.md`, `docs/SECURITY.md`, `docs/DESIGN_SYSTEM.md`, `docs/ROADMAP.md`, `docs/I18N.md`, `docs/PROCESS.md`, `RELEASE.md`, `docs/AGENT-EVALS.md`
   - **`PLAN.md` equivalents** (planning aliases, **same altitude**) — detection is **case-insensitive** and **nested** (up to ~3 levels, excluding `node_modules`/`.git`): `plan.md`, `TODO.md`, `todo.md`, `todos.md`, `TASKS.md`, `BACKLOG.md`, including under a path (e.g. `docs/gtd/todos.md`). There may be **several** — report all of them. **Case guard**: **never** generate `PLAN.md` if an equivalent name exists in a different case (collision on a case-sensitive FS).
   - `docs/superpowers/plans/` (superpowers **per-feature** plans — **different altitude**, *not* a `PLAN.md` alias)
   - **superpowers in use** → `HAS_SUPERPOWERS`, which decides whether the generated `CLAUDE.md` carries the interop section (Phase 5). Three signals, in order, **all read-only and best-effort**; the first that fires wins:
     1. `docs/superpowers/plans/` or `docs/superpowers/specs/` present in this folder → `true`. (In a genuinely empty folder this can never fire — hence the others.)
     2. This folder's own `.claude/settings.json`, if present: an `enabledPlugins` key whose **name part** is exactly `superpowers` → `true`. This is where a **project-scope** install is recorded, and it is the signal that is actually about *this* project.
     3. The user's **installed-plugin registry**, if the harness exposes one (at the time of writing `~/.claude/plugins/installed_plugins.json`, whose `plugins` object is keyed `<name>@<marketplace>` and whose values are **arrays of install records**). A key whose name part is exactly `superpowers` counts **only** when one of its records is `"scope": "user"`, or is project-scoped with a `projectPath` equal to this folder. **Do not accept a record project-scoped to some other repository** — that would make every folder on the machine report `true` because one unrelated project installed the plugin.
     4. None → `false`. **`false` is the default**, and it is the common case: the section is eight lines of interop guidance that is noise for a project not using that plugin.

     Match the name part by **exact equality** on the segment before `@` — `superpowers`, not a fork like `superpowers-fork` or `obra-superpowers`, whose interop shape you cannot assume. Unreadable, absent, or a shape you don't recognize → **don't guess and don't fail**: fall through to the next signal.
   - **Never ask about superpowers.** A question costs every user something to spare a minority eight lines; the whole point is to remove that tax, not move it. If the detection is wrong, the recap (Phase 8) says so and says how to fix it.
   - **Global / enterprise CLAUDE.md** (loaded **in addition to** the project CLAUDE.md — NEVER overwrite it): `~/.claude/CLAUDE.md`, and the managed policy if present (`/Library/Application Support/ClaudeCode/CLAUDE.md` on macOS, `/etc/claude-code/CLAUDE.md` on Linux). If at least one exists → `HAS_GLOBAL_CLAUDE=true`, **and read its content** (it's short — our own <200-line doctrine) into `GLOBAL_CLAUDE_CONTENT` for the **content-aware tailoring** in Phase 5 (which sections it already covers).
   - **AI attribution policy**: read (**read-only**) the detected CLAUDE.md files (project + global) for a rule **forbidding** AI attribution — patterns (case-insensitive): `no AI attribution`, `Co-Authored-By`, `Generated with Claude`, `do not add ... attribution`. If found → `NO_AI_ATTRIBUTION=true`. (Read-only: never modify these files.)
   - `package.json` (→ Node stack), `pyproject.toml`/`requirements.txt` (→ Python), `Cargo.toml` (→ Rust), `go.mod` (→ Go)
3. For each file you might create, classify it:
   - **Absent** → to create
   - **Present with a `generated-by: groundrules` signature near the top** → recognized, offer "ignore / regenerate". The signature may be an HTML comment (`<!-- ... -->`, Markdown) or a shell comment (`# generated-by: groundrules`, for `*.sh`/`.gitignore`), and need not be line 1 (e.g. after a shebang or YAML frontmatter — scan the first ~10 lines).
   - **Present without a signature** → foreign file, default "ignore"

4. **Determine the mode.** Three of them, decided by **two questions asked in this order** — is there groundrules state, and only then is the folder empty. Answering them with one word is what made this ambiguous before:

   | State file present? | Anything else in the folder? | Mode |
   |---|---|---|
   | **yes** | — (irrelevant) | **resume** |
   | no | no | **bootstrap** |
   | no | yes | **brownfield** |

   **"Anything else" ignores `.git/` and the state file itself.** A folder holding only a git repository has nothing for groundrules to preserve, so it is `bootstrap`, not `brownfield`. Without this, every `git init && /groundrules:bootstrap` would be misrouted.

   - **bootstrap** — generate everything, no arbitration.
   - **resume** — prior groundrules state exists: load it, skip what is already there, re-ask nothing the state answers (idempotence). This is the only thing the word *resume* now means, and the state file alone decides it: a folder is never "too empty" to resume.
   - **brownfield** — someone else's files, no groundrules history. The term is `adopt`'s own (cf. ADR 0008); **do not call this mode *foreign***, which in this skill is a **file** category (step 3, present without a signature) and would overload one word onto two ideas.

   **In `brownfield`, before Phase 2 begins** — not "at the start of the interview", which would ask whether the user wants a different skill after starting to question them:
   - Name the mode, and say the folder holds files groundrules did not generate and has no state to resume from.
   - **Point at `/groundrules:adopt` first**: it is what maps existing files to groundrules roles, where bootstrap classifies each of them as a foreign file and ignores it — lossy, and the reason `adopt` exists.
   - Then **one `AskUserQuestion`**: `Continue with bootstrap (create only what's missing)` / `Stop — I'll run /groundrules:adopt`. On the second, **stop and say to run `/groundrules:adopt`**: a skill cannot invoke another, so the user types the command.
   - **Never refuse, and never silently proceed as if this were a resume.**

   Announce the mode by name in every case.

## Phase 2 — Base interview

Group questions by theme via `AskUserQuestion` (max 4 questions per call for good UX).

### Call 1 — Project identity
- **Project name**: use the folder name as the default suggestion, ask for confirmation. (1 question)
- **Short description** (1 sentence — the detailed intent is captured in phase 3) (1 question)
- **Project type**: `Code (app, lib, CLI...)` / `Non-code (docs, research, notes...)` (1 question)

### Call 2 — Stack and docs (if code)
If a code project:
- **Main stack**: pre-fill with what you detected (Node, Python, etc.), offer `Other`, `None in particular` (1 question)
- **`docs/ARCHITECTURE.md`**: Yes (recommended for a code project) / No (1 question)
- **`docs/GLOSSARY.md`**: `Yes, domain jargon` / `No` (1 question)
- **`CHANGELOG.md` (Keep-a-Changelog)**: `Yes, versioned releases planned` / `No` (1 question)

If non-code, only ask the last two (GLOSSARY, CHANGELOG).

### Call 2b — Specialized docs (optional, if code)

A single **multiSelect** `AskUserQuestion`: *"Which specialized docs do you want to generate? (all optional, you can check none)"*

- **`docs/DATA_MODEL.md`** — entities, relationships, access rules. Check if the project has a database.
- **`docs/SECURITY.md`** — auth, access control, personal data & GDPR. Check if sensitive data.
- **`docs/DESIGN_SYSTEM.md`** — colors, typography, components. Check if the project has a UI.
- **`docs/I18N.md`** — multilingual strategy. Check if the project is multilingual.
- **`docs/ROADMAP.md`** — long-term milestone breakdown (distinct from `PLAN.md`).
- **`docs/PROCESS.md`** — the working-method contract: phases, validation gates, interview style. Check if the user wants a phased, gated way of working (spec → prototype → build).
- **`RELEASE.md`** — operational release runbook: environments, commands, checklists, rollback, known fragilities. Check **only if the project deploys somewhere** (detected CI config, hosting, or the user says so).
- **`docs/AGENT-EVALS.md`** — a log of the **agent's own** observed failure modes on this project (recurring mistakes, hallucinations, drifts) and the guard added for each. Distinct from `LEARNINGS.md` (which is about the project/domain). Offer it (unchecked by default); useful on long-running agent-driven projects.

Adapt suggestions to context: if the stack/intent suggests a UI, pre-suggest `DESIGN_SYSTEM`; a DB → `DATA_MODEL`; etc. Impose nothing: no check = no file.

Only ask this call for a code project. For a non-code project, only `ROADMAP` may make sense — offer it on its own if relevant.

### Call 2c — Loop scaffolding (opt-in, off by default)

A **dedicated** single `AskUserQuestion` (one question), because the scaffolding is heavier than a doc and deserves its own framing: *"Generate optional **loop scaffolding** — a maker/verifier autonomous loop (`loop/`) that executes loop-safe tasks with built-in back pressure? You can run it later or never; it changes nothing until you do."* Options: `No (recommended — add later if needed)` / `Yes, generate loop/`. Default **No**.

- **Skip this call entirely on resume** when `.groundrules.json` already has `loop.scaffolded: true` — the namespace exists; don't re-ask or regenerate (idempotence).
- **Skip this call entirely** when `HAS_SUPERPOWERS=true` (Phase 1 — any of its three signals, not just `docs/superpowers/plans/`): superpowers already *is* a maker/verifier realization pipeline — groundrules defers the whole realization to it and contributes the memory layer instead. Note this in the Phase 4 recap (do not generate `loop/`).
- **Code projects only** — for a non-code project, don't ask.
- If `Yes` → `HAS_LOOP=true`. This generates the `loop/` namespace (see file mapping) **and** inserts a `## Invariants` section into the generated `CLAUDE.md`. If `No` → `HAS_LOOP=false`, nothing loop-related is generated.
- Brief honesty in the option/recap: the loop is **most useful once `/groundrules:realize` lands** (it will fill `loop/backlog.md`); for now the backlog is hand-filled. See [ADR 0027](../../docs/decisions/0027-reflection-realization-interactive-loop.md) / [ADR 0030](../../docs/decisions/0030-loop-namespace-and-backlog.md).

### Call 3 — Steering and git
- **`PLAN.md` at the root** (active todo maintained by Claude): `Yes (recommended)` / `No` (1 question)
- **Git remote**: `GitHub` / `GitLab` / `None for now` (1 question)
- If remote ≠ "None":
  - **Visibility**: `Private (recommended)` / `Public` (1 question)

#### Reconciliation if a `PLAN.md` equivalent already exists

If Phase 1 detected a **planning alias** (`TODO.md`, `TASKS.md`, `BACKLOG.md`…), **do not ask** the standard yes/no `PLAN.md` question. Ask a reconciliation question instead:

- **Adopt the existing one** → do not create `PLAN.md`; `HAS_PLAN=false`. Record `skippedFiles["PLAN.md"] = "existing equivalent: <name>"` in `.groundrules.json`.
- **Create `PLAN.md` alongside** → `HAS_PLAN=true`, create normally (the user accepts both files).
- **Port the content into `PLAN.md`** → `Read` the alias, create `PLAN.md` from the template carrying over the existing tasks (the "In progress" section), then suggest the user delete the alias. **Never** delete the alias automatically. **Case guard**: if the alias is a `plan.md` (same name, different case), do not create a second file — offer to adopt `plan.md` as-is instead.

If **several** equivalents are detected, list them all and clarify their respective roles (e.g. `plan.md` = active view, `docs/gtd/todos.md` = backlog) in the question. For a more complex project (brownfield, many existing docs), point to `/groundrules:adopt`.

> **superpowers** (`HAS_SUPERPOWERS=true`): if only `docs/superpowers/plans/` is present (no root alias), it is **not** a `PLAN.md` equivalent (different altitude — see the interop note in the `CLAUDE.md` template). Keep the standard `PLAN.md` question, and note in the recap (Phase 4) that `PLAN.md` should **point to** the active superpowers plan rather than duplicate tasks.

## Phase 3 — Project intent

> Before generating project files, capture the intent (goal, users, constraints, non-goals, acceptance criteria). It is the basis for the `/groundrules:apply-best-practices` skill which needs it.

`AskUserQuestion`: *"Do you already have a brief or a vision document for this project?"*
- `Yes, I'll paste it now`
- `Yes, it's in a file (path)`
- `No, ask me the questions`
- `Skip for now`

### If "I'll paste it now"

Ask the user to paste the content (can be long: multiple paragraphs accepted).

Save the raw brief:
1. Read `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/intake-INTENT.md.tpl`
2. Substitute `{{PROJECT_NAME}}` and `{{CONTENT}}` (the brief as-is)
3. Write to `intake/INTENT.md`

Synthesize into a structured vision. Read the brief and extract:
- **Goal**: 1-3 sentences on what success looks like
- **Users**: who uses this
- **Constraints**: deadlines, budget, tech constraints, regulation
- **Non-goals**: what will NOT be done in V1
- **Acceptance criteria**: how we'll know it's done

If some points are ambiguous in the brief, ask **a single** grouped question to clarify the ambiguities.

### If "it's in a file"

Ask for the file path (absolute or relative to the cwd). `Read` that file then treat it like "I'll paste it": copy into `intake/INTENT.md` (via the template), synthesize into `docs/VISION.md`.

### If "No, ask me the questions"

Ask an `AskUserQuestion` with 4-5 questions:
- **Goal**: "What's the goal of the project? What does success look like?" (1-3 sentences)
- **Users / personas**: "Who will use this? (can be 'myself' if solo)"
- **Key constraints**: "What constraints (deadlines, budget, tech, regulation)?"
- **Non-goals**: "What will you **not** do in V1? (useful for scoping)"
- **V1 acceptance criteria**: "How will you know it's done?"

If a question is too broad, the user may answer "skip" or "to be defined later" — don't insist.

In this case, no `intake/INTENT.md` (the answers are already structured). Source = `interview`.

### Generating `docs/VISION.md`

In all cases (except a total Skip), read `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/docs-VISION.md.tpl`. Substitute:
- `{{PROJECT_NAME}}`
- `{{INTENT_SOURCE}}` — `intake/INTENT.md (paste)` / `intake/INTENT.md (file <path>)` / `interview`
- `{{GOAL}}`, `{{USERS}}`, `{{CONSTRAINTS}}`, `{{NONGOALS}}`, `{{ACCEPTANCE}}` — synthesized text

Write to `docs/VISION.md`.

### If "Skip"

Create neither `intake/INTENT.md` nor `docs/VISION.md`. Note in `.groundrules.json` that `intent.source = "skipped"`. `/groundrules:apply-best-practices` will refuse until the vision is created.

## Phase 4 — Recap and confirmation

Show a clear text recap:
- List of files that will be **created** (full path)
- List of files that will be **ignored** — in `resume`, files the state already accounts for; in `brownfield`, the **foreign** files (present without a generated-by signature). Name the mode, so the two reasons are not read as one.
- Planned git actions (`git init` — **only when Phase 1 found no `.git/`**; say *existing repository, no init* when it did — first commit, remote)
- **Notes carried from the interview** — earlier phases route observations here; this is their destination, and without it they have nowhere to land. **The block is open**: any decision or caveat an earlier phase reached that the file lists above do not show belongs here, not only the cases enumerated below. One line each; omit the whole block when there are none. Those that exist today:
  - **a planning alias was reconciled** (Call 3, whenever one was detected): which alias, and what was decided — adopted instead of `PLAN.md`, created alongside, or its content ported. Detecting `TODO.md` and then showing it in the ignored list like any other file hides the one decision the user most needs to see before confirming.
  - **loop scaffolding deferred to superpowers** (Call 2c, when `HAS_SUPERPOWERS=true`): no `loop/` is generated because superpowers already is a maker/verifier pipeline.
  - **`PLAN.md` should point, not duplicate** (Call 3 note, when `HAS_SUPERPOWERS=true`): have it reference the active superpowers plan rather than restate its tasks.
- **In `brownfield` mode, repeat the `adopt` recommendation here** — one line, naming the mode again. This screen is the last thing the user sees before `Confirm and generate`, and an advisory given once before the interview has scrolled away by the time it matters most.

Then a final `AskUserQuestion`: `Confirm and generate` / `Cancel`.

## Phase 5 — File generation

For each file to create:

1. Read the matching template in `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/`.
2. Replace the `{{KEY}}` placeholders with the collected values. Available placeholders:
   - `{{PROJECT_NAME}}` — project name
   - `{{DESCRIPTION}}` — short description (1 sentence, distinct from the vision)
   - `{{STACK}}` — stack or empty string
   - `{{DATE}}` — today's date in ISO (YYYY-MM-DD)
   - `{{HAS_PLAN}}`, `{{HAS_ARCHITECTURE}}`, `{{HAS_GLOSSARY}}`, `{{HAS_CHANGELOG}}` — `true`/`false`
   - `{{HAS_DATA_MODEL}}`, `{{HAS_SECURITY}}`, `{{HAS_DESIGN_SYSTEM}}`, `{{HAS_ROADMAP}}`, `{{HAS_I18N}}`, `{{HAS_PROCESS}}`, `{{HAS_RELEASE}}`, `{{HAS_AGENT_EVALS}}` — `true`/`false` (specialized docs)
   - `{{HAS_LOOP}}` — `true`/`false` (loop scaffolding opted in, Call 2c)
   - `{{HAS_SUPERPOWERS}}` — `true`/`false` (superpowers detected, Phase 1)

   **Only some of these are substituted tokens.** `{{PROJECT_NAME}}`, `{{DESCRIPTION}}`, `{{STACK}}`, `{{DATE}}`, `{{GLOBAL_CLAUDE_NOTE}}`, `{{REMOTE_PROVIDER}}`, `{{REMOTE_VISIBILITY}}`, `{{CONTENT}}`, `{{INTENT_SOURCE}}`, `{{GOAL}}`, `{{USERS}}`, `{{CONSTRAINTS}}`, `{{NONGOALS}}` and `{{ACCEPTANCE}}` appear literally in a template and are replaced. Every `{{HAS_*}}` is a **decision variable, not a token**: it appears in no template and selects which file to write, which section to splice, which section to drop. Searching a template for `{{HAS_LOOP}}` or `{{HAS_SUPERPOWERS}}` finds nothing, and that is correct — do not conclude the condition does not exist.
   - `{{GLOBAL_CLAUDE_NOTE}}` — deference note to the global CLAUDE.md **+ the list of omitted sections** (see "CLAUDE.md generation"), or **empty string** if no global detected
   - `{{REMOTE_PROVIDER}}` — `github` / `gitlab` / empty string
   - `{{REMOTE_VISIBILITY}}` — `private` / `public` / empty string
   - `{{CONTENT}}` (intent brief) — raw brief content
   - `{{INTENT_SOURCE}}` — `intake/INTENT.md (paste)` / `intake/INTENT.md (file ...)` / `interview`
   - `{{GOAL}}`, `{{USERS}}`, `{{CONSTRAINTS}}`, `{{NONGOALS}}`, `{{ACCEPTANCE}}` — synthesized text
3. **Plain text substitution**: no template engine, just `replace` on each placeholder.
4. Write the file to its destination with the `Write` tool.

### CLAUDE.md generation (content-aware tailoring against the global)

There is **one** template (`CLAUDE.md.tpl`). When a global CLAUDE.md exists, a "lean" result **emerges** from omitting only the sections the global *actually* covers — not from a separate template (cf. ADR superseding 0009).

- **Priority case — `CLAUDE.md` project file already present** (resume mode, foreign file without a signature, often tool-managed by an enterprise manager like `claude-manager`): **generate nothing**, never overwrite. Detect a **free zone** (marker `END MANAGED` / `Project-Specific Notes` / "below this line is yours") and offer (opt-in) to **append** a pointer to the groundrules docs (`docs/VISION.md`, `docs/decisions/`, `docs/LEARNINGS.md`, `PLAN.md`) — free zone **only**, never the managed sections. No free zone → skip. (Detailed logic: see `/groundrules:adopt` § "CLAUDE.md project file already present".)
- **No global** (`HAS_GLOBAL_CLAUDE=false`, no existing project CLAUDE.md) → use `CLAUDE.md.tpl` **as-is, all sections**, and substitute `{{GLOBAL_CLAUDE_NOTE}}` with an **empty string**.
- **Global detected** (`HAS_GLOBAL_CLAUDE=true`) → **tailor `CLAUDE.md.tpl` against `GLOBAL_CLAUDE_CONTENT`** (the global's actual content you read during detection — judge *coverage*, not mere presence):
  1. **Collapsible sections** — omit a section **only if the global covers that topic's *primary* directive** (not necessarily every line; partial coverage → **bias to keep**): `### Commits` · `### Permissions and settings` · `## Verifying the work` · `## Claude Code workflow` · `## Git workflow`. `## Don't` is **always kept** (it carries the signature "the repo is the only memory" line).
  2. **Never omit groundrules' signature conventions** even if the global mentions them — Session-start order · Capture-at-checkpoints · When-to-document routing · the-repo-is-the-only-memory · living docs · Posture; nor the project-specific — Description · Setup/Build/Test · Key files · Code/`{{STACK}}` · Updating-this-file · Tech stack · Notes. **Bias to keep on any doubt.**
  3. **Drop** each covered collapsible section entirely (no per-section pointer). If dropping a child `###` empties its parent `##` heading, drop the parent too; if a kept child remains (e.g. `### Code` under `## Conventions`), keep the parent.
  4. Substitute `{{GLOBAL_CLAUDE_NOTE}}` with the deference note + the omission list (label each omitted topic by its **section title**, no `#`):
     > `> **Relationship with the global CLAUDE.md**: this file is loaded **in addition to** the global (\`~/.claude/CLAUDE.md\` + enterprise policy) — on conflict the global/enterprise rule wins. **Omitted here (your global already covers them):** <comma-separated section titles, or "none">.`
  5. **Recap to the user**: list what you omitted and why; they can **veto** (keep any section).
- Net effect: a **thin** global → output ≈ the full template (minus only what it truly covers); a **rich** global → output approaches the old lean. The result **scales with the global's real content**, with no holes.

**`### Interop with superpowers` section (only if `HAS_SUPERPOWERS=true`)**: when `false`, **drop that whole `###` section** from the composed content before writing — from its heading line down to (excluding) the next heading of equal or higher level. Match the heading by **prefix**, `### Interop with superpowers`, and never by a bullet count: the body is free to grow. Its parent `## Key files and folders` keeps its other children, so the parent stays. This is the same drop mechanic as the global tailoring above, on a different trigger: there, a section is dropped because the global already covers it; here, because the plugin it describes is not in play. Keep the inline mention of *"or your superpowers spec"* under `## Claude Code workflow` either way — four words are not worth a second conditional, and they read as an aside rather than a section. The section is **never** dropped when `HAS_SUPERPOWERS=true`, whatever the global says: no global covers a plugin interop.

**`## Invariants` section (only if `HAS_LOOP=true`)**: if loop scaffolding was opted in, read `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/loop/CLAUDE-invariants.md`, strip its leading `<!-- ... -->` comment lines, and **splice its `## Invariants` section into the CLAUDE.md content *before* the single `Write`** — positioned **immediately before the `## Posture` heading** (i.e. after the *last child* of `## Conventions`, never between the `## Conventions` heading and its `###` subsections). Compose-then-write (bootstrap has no `Edit` tool); don't write-then-rewrite. If `HAS_LOOP=false`, do **not** add it (non-loop projects stay lean — the verifier is what gives invariants teeth, cf. ADR 0030). This section is never omitted by the global-tailoring logic above.

### File mapping (always created)

| Template | Destination |
|---|---|
| `README.md.tpl` | `README.md` |
| `CLAUDE.md.tpl` | `CLAUDE.md` |
| `gitignore.minimal` | `.gitignore` |
| `decisions-README.md.tpl` | `docs/decisions/README.md` |
| `adr-template.md` | `docs/decisions/0000-template.md` |
| `LEARNINGS.md.tpl` | `docs/LEARNINGS.md` |
| `intake-README.md.tpl` | `intake/README.md` |
| `media-README.md.tpl` | `docs/media/README.md` |

### File mapping (conditional)

| Condition | Template | Destination |
|---|---|---|
| `HAS_PLAN=true` | `PLAN.md.tpl` | `PLAN.md` |
| `HAS_ARCHITECTURE=true` | `ARCHITECTURE.md.tpl` | `docs/ARCHITECTURE.md` |
| `HAS_GLOSSARY=true` | `GLOSSARY.md.tpl` | `docs/GLOSSARY.md` |
| `HAS_CHANGELOG=true` | `CHANGELOG.md.tpl` | `CHANGELOG.md` |
| `HAS_DATA_MODEL=true` | `DATA_MODEL.md.tpl` | `docs/DATA_MODEL.md` |
| `HAS_SECURITY=true` | `SECURITY.md.tpl` | `docs/SECURITY.md` |
| `HAS_DESIGN_SYSTEM=true` | `DESIGN_SYSTEM.md.tpl` | `docs/DESIGN_SYSTEM.md` |
| `HAS_ROADMAP=true` | `ROADMAP.md.tpl` | `docs/ROADMAP.md` |
| `HAS_I18N=true` | `I18N.md.tpl` | `docs/I18N.md` |
| `HAS_PROCESS=true` | `PROCESS.md.tpl` | `docs/PROCESS.md` |
| `HAS_RELEASE=true` | `RELEASE.md.tpl` | `RELEASE.md` |
| `HAS_AGENT_EVALS=true` | `AGENT-EVALS.md.tpl` | `docs/AGENT-EVALS.md` |
| `intent.source` ∈ `paste`/`file` | `intake-INTENT.md.tpl` | `intake/INTENT.md` |
| `intent.source` ≠ `skipped` | `docs-VISION.md.tpl` | `docs/VISION.md` |
| `HAS_LOOP=true` | `loop/README.md.tpl` | `loop/README.md` |
| `HAS_LOOP=true` | `loop/maker.md` | `loop/maker.md` |
| `HAS_LOOP=true` | `loop/verifier.md` | `loop/verifier.md` |
| `HAS_LOOP=true` | `loop/LOOP.md` | `loop/LOOP.md` |
| `HAS_LOOP=true` | `loop/run-loop.sh` | `loop/run-loop.sh` (mark executable: `chmod +x`) |
| `HAS_LOOP=true` | `loop/backlog.md` | `loop/backlog.md` |
| `HAS_LOOP=true` | `loop/gitignore` | `loop/.gitignore` |

> `loop/maker.md`, `loop/verifier.md`, `loop/LOOP.md`, `loop/run-loop.sh`, `loop/backlog.md`, `loop/gitignore` carry no `{{KEY}}` — copy verbatim (`loop/gitignore` is written to the destination `loop/.gitignore`). Only `loop/README.md.tpl` is substituted (`{{PROJECT_NAME}}`). `loop/CLAUDE-invariants.md` is **not** a generated file — it is the snippet inserted into `CLAUDE.md` (see below). Do **not** create `loop/blocked.md` or `loop/lessons.md` — the loop writes those on demand.

### Persisted state

Write `.groundrules.json` at the root with this schema:

```json
{
  "groundrulesVersion": "<current plugin version>",
  "bootstrappedAt": "YYYY-MM-DD",
  "bootstrappedWithVersion": "<current plugin version>",
  "migrations": [],
  "answers": { ... all interview answers ... },
  "intent": {
    "source": "paste" | "file" | "interview" | "skipped",
    "filePath": "<path if file>",
    "goal": "...",
    "users": "...",
    "constraints": [...],
    "nonGoals": [...],
    "acceptanceCriteria": [...]
  },
  "appliedPractices": [],
  "loop": { "scaffolded": true | false, "at": "YYYY-MM-DD" | null },
  "policies": { "noAiAttribution": true | false },
  "generatedFiles": [ ... relative paths ... ],
  "skippedFiles": { "<path>": "<reason>" }
}
```

`policies.noAiAttribution` reflects the `NO_AI_ATTRIBUTION` detected in phase 1 — it lets other skills (`migrate`, etc.) know the policy without re-scanning.

`superpowers` records the Phase 1 **detection** — `{ "detected": true | false, "via": "docs/superpowers/plans/" | ".claude/settings.json" | "installed-plugin registry" | null }`. It is **top-level, never under `answers`**, for the same reason as `loop` below: `answers` holds what the user *said*, and nothing was ever asked here (Phase 1 forbids it). Recording *which* signal fired is what makes a wrong detection debuggable, and Phase 8 tells the user the detection can be wrong.

`loop.scaffolded` records whether the `loop/` namespace was generated (Call 2c) — it lets `/groundrules:realize` (later) know the scaffolding exists, and keeps the opt-in idempotent (resume mode skips an already-scaffolded `loop/`). `false`/`null` when not opted in. The Call 2c answer lives **only** in this top-level `loop` object, **not** under `answers` (avoid a duplicate `answers.loop` key).

`groundrulesVersion` can evolve (via `/groundrules:migrate`), `bootstrappedWithVersion` stays frozen. `migrations` accumulates `{from, to, at}` entries. `appliedPractices` is filled by `/groundrules:apply-best-practices`. If the intent is skipped, `intent.source = "skipped"` and the other fields are `null`.

## Phase 6 — Git

1. If `.git/` absent in cwd → `git init -b main`.
2. `git add -A`
3. Check there's something to commit: `git diff --cached --quiet` → if nothing, skip the commit.
4. Otherwise: `git commit -m "chore: bootstrap project structure with groundrules"` (no version string — it would drift; the version lives in `.groundrules.json` and the file signatures)

> **AI attribution**: the commit message must **never** contain an AI attribution marker (`Co-Authored-By` trailer, "Generated with Claude Code" mention, etc.). This is the bootstrap default, and it is **mandatory** if `NO_AI_ATTRIBUTION=true` — this rule **overrides any default attribution guidance** of the agent.

## Phase 7 — Remote (if requested)

If `{{REMOTE_PROVIDER}}=github`:
1. `command -v gh` → if absent, show a manual-instruction message and go to phase 8.
2. `gh auth status` → if not authenticated, indicate `gh auth login` and go to phase 8.
3. `gh repo create {{PROJECT_NAME}} --{{REMOTE_VISIBILITY}} --source=. --remote=origin --push`

If `{{REMOTE_PROVIDER}}=gitlab`: same with `glab` instead of `gh`. The command is `glab repo create {{PROJECT_NAME}} --{{REMOTE_VISIBILITY}}` then `git push -u origin main`.

On graceful failure (CLI absent / auth missing): show the ready-to-paste command for manual execution.

## Phase 8 — Final recap

Show the user:
- ✅ List of created files (relative paths)
- ✅ Git actions performed (init, short commit hash, remote URL if created)
- 📋 Suggested next steps:
  1. **If the intent was captured**: run `/groundrules:apply-best-practices` to fetch shanraisshan and apply the relevant practices to your vision.
  2. Fill `intake/` with other upstream notes if relevant
  3. Flesh out `CLAUDE.md` (Setup/Build/Test, project-specific sections)
  4. If `PLAN.md` was created: add the first tasks
  5. Read `docs/VISION.md` and amend it if the synthesis missed something
  6. If the intent was skipped and you still want tailored practices: fill `docs/VISION.md` by hand then run `apply-best-practices`

If `HAS_SUPERPOWERS=false`, add **one** line — never a paragraph, and never a question:
> *The `CLAUDE.md` interop section for [superpowers](https://github.com/obra/superpowers) was left out (not detected). If you do use it — its artifacts can live outside `docs/superpowers/` — add the section by hand: it is the `### Interop with superpowers` block of `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/CLAUDE.md.tpl`.*

Do **not** point at `/groundrules:migrate` here: it has no superpowers awareness and would only surface the block as a generic diff to accept or reject.

Say nothing at all when `HAS_SUPERPOWERS=true`: a section that is present needs no explanation.

### Team-sharing tip (project-scope install)

The generated `CLAUDE.md` references `/groundrules:*` commands — but the **plugin doesn't travel with `git clone`**: a collaborator who only clones the repo won't have those commands (the model sees the instruction, the command fails). If this repo will be **shared / cloned by others**, suggest installing groundrules at **Project scope** so it's committed to `.claude/settings.json` and collaborators are prompted to install it on clone:

> Run `/plugin install groundrules@claude-code-groundrules` and choose **Project** scope (not User). This commits the plugin reference to `.claude/settings.json` — anyone who clones and trusts the repo is then prompted to install it, so the `/groundrules:*` commands work for the whole team. (Cf. ADR 0023.)

Only surface this if `.claude/settings.json` doesn't already carry a project-scope groundrules entry, and don't block on it — the project's docs are plain markdown and remain readable without the plugin; only the slash-command ergonomics need it.

## Important rules

- **NEVER overwrite a file without explicit confirmation** (see phase 4).
- **Always** add `<!-- generated-by: groundrules v1.10.0 -->` at the top of each generated file (the templates already contain it).
- **Idempotence**: if the user re-runs the skill, resume mode detects already-up-to-date files and does nothing.
- **Surface errors**: if a step fails (e.g. `gh repo create` returns an error), don't pretend it worked. Show the error, propose an action.
- **Keep `.groundrules.json`**: it's the source of truth for resume mode and for `apply-best-practices`.
- For intent synthesis: be faithful to the source text, don't invent. If the source is thin, the `docs/VISION.md` sections may contain "To be defined" rather than fabricated content.
