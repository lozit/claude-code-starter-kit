---
name: migrate
description: Use when the plugin has a new version and a project (groundrules, or a legacy starter-kit one) needs to catch up — per-file diff, never overwrites without explicit confirmation.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# /groundrules:migrate

You will update a groundrules-bootstrapped project (including projects bootstrapped by the pre-1.0 plugin, named starter-kit) to the current plugin version.

If `$ARGUMENTS` contains `--dry-run` (or `dry-run`), run all analysis phases but **write no file**: end with a report only.

## Phase 0 — Plugin update check (best-effort, never blocking)

1. Read `version` from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` → INSTALLED.
2. Run via Bash with a **short timeout (~3s)**: `git ls-remote --tags --refs --sort=-v:refname https://github.com/lozit/groundrules.git 'v*' | head -1`
3. Extract the tag (`refs/tags/vX.Y.Z`). If semver-greater than INSTALLED, warn (informational, don't stop):
   > 📦 groundrules vX.Y.Z is available but vINSTALLED is installed — migrating now will only bring the project up to vINSTALLED. Recommended: update the plugin first — `/plugin marketplace update claude-code-groundrules` (catalog only), then **reinstall** (`/plugin install groundrules@claude-code-groundrules`) and **restart Claude Code** — then re-run `/groundrules:migrate`. (Marketplace update alone doesn't update the installed plugin.) Continuing with vINSTALLED is fine too.
4. **Fail silent**: on timeout, no network, or any error, continue without mentioning the check. This is the only network access in this skill and it is best-effort (cf. ADR 0015).

## Phase 1 — Version detection

1. `.groundrules.json` must exist in the cwd. **Legacy**: if only a pre-1.0 `.starter-kit.json` exists, read that instead (version key `starterKitVersion`) — the V1.0 rename below will move it. If neither exists: *"This project was not bootstrapped with groundrules, nothing to migrate."* Stop.
2. Read the state file → extract:
   - `groundrulesVersion` (legacy file: `starterKitVersion`) → **OLD**
   - `answers` → original interview answers
   - `generatedFiles` → list of files generated at bootstrap
3. Read `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` → extract `version` → **NEW**.
4. Compare:
   - **OLD == NEW** → *"Project up to date at version NEW. Nothing to migrate."* Stop.
   - **OLD > NEW** (semver) → *"Project version (OLD) is newer than the installed plugin (NEW). Refusing to downgrade."* Stop.
   - **OLD < NEW** → continue.

## Phase 2 — Show what changes

Read `${CLAUDE_PLUGIN_ROOT}/CHANGELOG.md`. Extract and show the entries between OLD and NEW so the user understands what they'll get.

> **Migrations that rename/move files**: some versions rename or relocate generated files — e.g. V0.7 renamed `docs/00-VISION.md` → `docs/VISION.md` and `brief/00-INTENT.md` → `brief/INTENT.md`; V0.9 moved `media/` → `docs/media/`; V0.11 renamed the `brief/` folder → `intake/` (ADR 0014). When migrating across such a version, detect the old path on disk and offer to `git mv` it to the new path (never duplicate; never delete without confirmation). Renames **chain**: a pre-V0.7 `brief/00-INTENT.md` migrating past V0.11 lands directly at `intake/INTENT.md` (one `git mv` to the final path). For `media/` → `docs/media/`: if a top-level `media/` exists and was the starter-kit one, offer the move; if the project has its own unrelated `media/`/`public/`, leave it and just create `docs/media/`. For `brief/` → `intake/`: offer `git mv brief intake` (whole folder), then fix the paths in `generatedFiles` and any `intent.source`-style references in `.groundrules.json`; also flag stale `brief/` references in the project's own `CLAUDE.md`/`README.md`/docs for the user to update (or offer to update them if they carry the starter-kit signature).

### The superpowers interop section became conditional (ADR 0039)

The generated `CLAUDE.md` carries its `### Interop with superpowers` section **only** when superpowers is in use. A project generated before that change carries it unconditionally — eight lines that are noise if the project does not use that plugin, and the point of the change is that existing projects get the benefit too, not only new ones.

**Trigger on the state, not on a version number.** Run this pass when `.groundrules.json` has **no top-level `superpowers` key** — that key is written the first time this detection runs, so its absence *is* "this project predates the change", whatever the version numbers say. Do not key it on OLD or NEW: the change ships in whatever release it ships in, and a hard-coded number is wrong before that release and stale after it.

Then **determine `HAS_SUPERPOWERS` exactly as `bootstrap` Phase 1** (its signals in order, including the scope filter on the plugin registry), and:

- **`false` and the section is present** → offer to **remove** it. One question; `Keep it` is a legitimate answer, since a user may know they are about to adopt the plugin.
- **`true` and the section is absent** → offer to **add** it from `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/CLAUDE.md.tpl`, after the existing content of `## Key files and folders` (where the template puts it), not straight under that heading. **If that heading is absent** from the project's file, do not guess a location: say the section could not be placed and leave the file alone.
- **Otherwise** → nothing to offer, and say nothing to the user. The state key below is still written; it is bookkeeping, not an event.

**Delimiting the block, for the removal.** From its heading line down to (excluding) the next heading of **equal or higher level**; if there is none, to the **end of the file**. Match the heading by **prefix**, `### Interop with superpowers` — the template's heading has changed before and an exact match would silently fail. Never match by counting bullets: the body is free to grow. Leave exactly **one** blank line where the block was, so the following heading keeps its separation and a preceding bullet is never glued to it.

**Phase 3 must drop the same section before diffing** when `HAS_SUPERPOWERS=false`. The template is the *full* source — it carries the section unconditionally, because the gating lives here and not in the template — so a project file that legitimately lacks the section would otherwise show it as a difference, and a user answering `Overwrite with the new template` in Phase 5 would **silently re-add the very block this pass just removed**. Drop it from the comparison text, then diff.

**Where the question goes.** Ask it in **Phase 5, after the per-file arbitration**, as its own question — never folded into the whole-file `CLAUDE.md` row: *overwrite this file* and *drop eight lines from it* are not the same question, and answering the first must not decide the second. Show the outcome in the Phase 8 recap, and record it in Phase 7.

### V1.0 — the plugin was renamed starter-kit → groundrules (ADR 0017)

When OLD < 1.0.0, the project was generated by the plugin under its former name **starter-kit**. After the regular per-file arbitration (phases 3-6), apply the **rename pass** (each step after confirmation, `git mv` for tracked files):

1. **State file**: `git mv .starter-kit.json .groundrules.json`, then rename the key `starterKitVersion` → `groundrulesVersion` inside it (all other keys unchanged).
2. **Signatures**: in every file of `generatedFiles` that carries `<!-- generated-by: starter-kit vX.Y.Z -->`, rewrite the signature line to `<!-- generated-by: groundrules vNEW -->`. One grouped confirmation for all files ("rewrite N legacy signatures?"), not one question per file. Files the user chose to keep untouched in phase 5 still get the signature rewrite offer — it's a one-line change, not a content overwrite.
3. **Command prefix**: inform the user that all slash commands changed: `/starter-kit:<skill>` → `/groundrules:<skill>`. If the project's own `CLAUDE.md`/docs mention `/starter-kit:` commands (grep them), offer to update those mentions.
4. **Stale name references**: flag remaining "starter-kit" mentions in the project's generated docs (`README.md` structure section, notes "bootstrapped with starter-kit"...) and offer to update them to groundrules + the new repo URL (`https://github.com/lozit/groundrules`).
5. **Plugin reinstall reminder** (recap): the marketplace is now `claude-code-groundrules` and the plugin `groundrules` — the user should `/plugin marketplace add https://github.com/lozit/groundrules` + `/plugin install groundrules`, and may remove the old `starter-kit` plugin/marketplace entries.

## Phase 3 — Analyze tracked files

For each file listed in `generatedFiles`:

1. Identify the template that produced it. Use the same mapping as `skills/bootstrap/SKILL.md` Phase 5. Templates are English-only with a single `.tpl` per file (no language variants).
2. Read `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/<template>` (current version).
3. **Read the file on disk.** Do this *before* substituting: the resolution ladder below reads it as its strongest source.
4. **Substitute the placeholders.** `answers` alone is **not** enough and assuming it is corrupts files: a project bootstrapped by an older version can carry an `answers` object holding little more than `projectName`, while the template needs `{{DESCRIPTION}}`, `{{STACK}}`, `{{DATE}}`, `{{GLOBAL_CLAUDE_NOTE}}` and more. Resolve each placeholder through this ladder, first hit wins:
   1. **`.groundrules.json`** — `answers`, and also `intent` (its `goal` / `users` / `constraints` / `nonGoals` / `acceptanceCriteria` are what `{{GOAL}}`, `{{USERS}}`, `{{CONSTRAINTS}}`, `{{NONGOALS}}`, `{{ACCEPTANCE}}` were written from) and the top-level keys.
   2. **The file on disk** — the strongest source, and the one `bootstrap` never has: a previous generation already substituted these, so the current file *is* the record of the values. Recover one by anchoring on the template's literal text on either side of the placeholder (`# {{PROJECT_NAME}}` against the file's own heading, and so on). Recover, never guess: if the surrounding text has been hand-edited past recognition, treat it as unresolved.
   3. **Re-derive the non-interactive ones exactly as `bootstrap`** does: `{{STACK}}` from the folder's stack markers, `{{GLOBAL_CLAUDE_NOTE}}` by reading the global `CLAUDE.md`, `{{REMOTE_PROVIDER}}` / `{{REMOTE_VISIBILITY}}` from `git remote -v`. **A derivation that legitimately finds nothing resolves to the empty string** — `bootstrap` defines `{{STACK}}` as *"stack or empty string"*, and the same holds for the note and the remote pair. A stack-less project is a resolved project, not a blocked one; rung 2 runs first, so a real value already on disk is never overwritten by an empty one.
   4. **Unresolved** → leave it unresolved. This is only for placeholders with **no defined empty form** — `{{PROJECT_NAME}}`, `{{DESCRIPTION}}`, and the `VISION` fields. **Never fabricate a value, and never ask**: `migrate` is not an interview, and a plausible invented `{{DESCRIPTION}}` written into a user's file is worse than a visible gap.

   **`{{DATE}}` comes from `bootstrappedAt`, never from the clock.** The template renders it as *bootstrapped on `{{DATE}}`*, so re-deriving it with `date +%F` writes a statement that is false. Rung 3 does not apply to it.
5. **Bring the generated text to what `bootstrap` would produce for *this* project — not the raw template.** `bootstrap` does not write the template as-is: it drops the sections a global `CLAUDE.md` already covers, splices `## Invariants` only when the loop is scaffolded, and drops `### Interop with superpowers` when superpowers is absent. Comparing a project against the raw template reports every one of those as a difference the user never introduced. Apply the same section selection here, from the same inputs, **before** diffing.

   **Apply a section drop only when the project file lacks that section.** When the file *has* it, the difference is real and belongs in the arbitration: dropping it turns *your wording is out of date* into a pure deletion, and — for the interop block — makes `Overwrite with the new template` silently remove a section whose removal is supposed to be its own separate question. Answering one question must never decide the other.
6. **Mask what stayed unresolved, on both sides, before comparing.** An unresolved `{{STACK}}` diffed against the real value the file already carries reports a difference that does not exist, and a recap padded with false differences trains the user to accept overwrites without reading. Replace the placeholder in the generated text **and** the span it corresponds to on disk with one identical marker; when that span cannot be located, drop the line from the comparison. Say once, in the recap, which placeholders were masked and for which files.
7. Compare via Bash `diff -u <(printf '%s' "$current") <(printf '%s' "$generated")`:
   - **Identical** → note "already up to date"
   - **Differs** → note "to arbitrate" + keep the diff handy

> **Legacy projects (pre-V0.8, bilingual)**: if `answers.lang` is present (`fr`/`mix`), the project was generated by an older bilingual plugin. The current plugin is English-only — there is no FR template to diff against. Do NOT overwrite French content with English; report these files as "language change — manual review" and, if the user wants to switch to English, offer to write the new English template as `<file>.new` for manual merge.

## Phase 4 — Detect newly available files

For each template in the current plugin that would produce a file given `answers` (respecting the `HAS_*` flags) **but that is NOT in `generatedFiles`**:

- **Distinguish two cases**, because they read very differently to a user. A template **added since OLD** (check `${CLAUDE_PLUGIN_ROOT}/CHANGELOG.md`) is genuinely *new in a recent version*. One that already existed at OLD was simply **never generated for this project** — declined at bootstrap, or lost since. Offer both, but never announce the second as new: on a project whose `generatedFiles` is short, that mislabels every always-created file at once.
- A `HAS_*` flag **absent** from `answers` is *unknown*, not `false`: offer the file and say the state file does not record the choice, rather than silently skipping it.

## Phase 5 — Recap and arbitration

Show a recap table:

```
| File                   | State             | Proposed action      |
|------------------------|-------------------|----------------------|
| CLAUDE.md              | content modified  | show diff then choose |
| docs/LEARNINGS.md      | identical         | skip                 |
| docs/ARCHITECTURE.md   | identical         | skip                 |
| (new) docs/...         | template added    | create? (optional)   |
```

For each "content modified" file, ask via `AskUserQuestion` (group by 3-4):

- `See the diff` — show the diff via Bash `diff -u`, then re-ask
- `Overwrite with the new template` — destructive, but updates
- `Keep my file` — skip
- `Save the new one as .new` — write the new content to `<file>.new` for manual merge by the user

For each "new template available": `Create` / `Skip`.

## Phase 6 — Apply decisions

> If `--dry-run`: skip this phase, go straight to phase 8 with a "would have done:" report.

**What gets written.** Always the **substituted** text of Phase 3 step 4 — **never** the masked text of step 6. Masking exists only to keep an unresolved placeholder out of the *comparison*; writing the masked text would delete the value's whole line from the user's file and, worse, blind the guard below by removing the very tokens it looks for.

**Guard, before every `Write` in this phase — a `{{KEY}}` must never reach a user's file.** Scan the content you are about to write for a **bare** placeholder, applying the same backtick rule as `/groundrules:verify-bootstrap` § 2.4: one wrapped in backticks is a documentation reference, not a leftover. `verify-bootstrap` already reports a bare one as a **failure**, so writing one here would mean this plugin producing the exact defect it ships a detector for. If any remain:

- **Overwrite** → **refuse it.** Write `<file>.new` instead and name the unresolved placeholders. The user's file is never damaged by a migration.
- **Save as .new** → proceed, and name them. When a refused overwrite has already produced the same `<file>.new`, say so plainly: the user picked `Overwrite` and got something else, and a recap that does not explain that reads as the skill ignoring their answer.
- **Create** → **skip the file.** A file that does not exist yet loses nothing by waiting, and creating it half-substituted only moves the problem. Name what is missing.

In every case say where the value would come from — usually a key absent from `.groundrules.json` — so the user can fill it and re-run: `migrate` is re-runnable by design.

**Second guard — never offer `Overwrite` on a file the project writes into.** The placeholder guard above protects against a broken value; this one protects against a correct value being thrown away, which no placeholder scan can see. `PLAN.md`, `CHANGELOG.md`, `docs/LEARNINGS.md`, `docs/AGENT-EVALS.md`, `docs/VISION.md`, `intake/INTENT.md`, `docs/ADOPTION-LOG.md` and everything under `docs/decisions/` are **accumulators**: their value is what the project put in them, and regenerating one from its template is almost never what anybody means. A `PLAN.md` holding real tasks, overwritten, comes back as *(add the first active tasks here)* with nothing warning the user.

For those files, Phase 5 offers **`See the diff` / `Keep my file` / `Save the new one as .new`** and **not** `Overwrite`. Say why in one clause — *this file accumulates your content* — so the missing option does not read as an omission. Everything else keeps all four.

For each "Overwrite" → `Write` the new content.
For each "Save as .new" → `Write` to `<file>.new`.
For each "Create" → `Write` the new file.
For each "rename" (legacy file name) → `git mv` to the new name (after confirmation).

## Phase 7 — Update `.groundrules.json`

Update:
- `groundrulesVersion` → NEW
- `generatedFiles` → updated list (add newly created files, fix renamed paths)
- If `answers.lang` exists and the user migrated content to English, drop the obsolete `lang` key (the plugin no longer uses it).
- `superpowers` → the detection made above, top-level and never under `answers` (nothing was asked): `{ "detected": true, "via": "artifacts" | "project-settings" | "plugin-registry" }` naming the signal that fired, or `{ "detected": false, "via": null }` when none did — `null`, not a word, because there is no signal to name. Its **absence** is what triggers the pass above, so write it on every run that performed the detection, including the silent branch.
- Append (or create) a `migrations` array entry:
  ```json
  {"from": "OLD", "to": "NEW", "at": "YYYY-MM-DD"}
  ```

## Phase 8 — Final recap

Show:
- ✅ Files updated (overwrite)
- ✅ Files created (new templates)
- 🔁 Files renamed (legacy → new name)
- 📁 `.new` files to merge manually
- ⏭️ Files left as-is (user choice)
- 📋 Next steps:
  1. Review the `.new` files and merge in what you like
  2. Flesh out the project-specific sections (Setup/Build/Test commands, stack, etc.) in CLAUDE.md if they were regenerated
  3. Commit when ready — if `.groundrules.json` has `policies.noAiAttribution = true` (or a project/global CLAUDE.md forbids AI attribution), the suggested commit message must contain **no** AI attribution marker (`Co-Authored-By`, "Generated with Claude Code"…), even if a default agent guideline would add it.

**NEVER commit automatically.**

## Important rules

- **No overwrite without an explicit user choice** (phase 5).
- **Refuse downgrade**: if the project version is newer than the installed plugin, stop.
- If a template referenced in `generatedFiles` **no longer exists** in the current plugin (file removed in a recent version), don't touch the file; report it in the recap.
- If `--dry-run`: no writes, just a report — useful to understand before committing.
- The diff must be readable: prefer `diff -u` (unified) over raw `diff`.
