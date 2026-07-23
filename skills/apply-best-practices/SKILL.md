---
name: apply-best-practices
description: Use when you want external, up-to-date best-practice recommendations for the project (fetched from shanraisshan/claude-code-best-practice and tailored to its vision). The only skill that needs the network.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, WebFetch, AskUserQuestion, Bash
---

# /groundrules:apply-best-practices

You will fetch the up-to-date, community-maintained Claude Code best practices, filter them against the project **vision**, and apply the recommendations the user selects.

## Phase 1 — Prerequisites

1. `.groundrules.json` must exist in the cwd (legacy: a pre-1.0 `.starter-kit.json` is accepted — read it instead and suggest `/groundrules:migrate`). Otherwise: *"This project was not bootstrapped with groundrules. Run `/groundrules:bootstrap` first."* Stop.
2. `docs/VISION.md` must exist. Otherwise: *"No project vision found. This command needs the intent to propose tailored practices. Run `/groundrules:bootstrap` (or add the vision manually before re-running)."* Stop.
3. Read `docs/VISION.md` → full content to pass to the fetch.

## Phase 2 — Fetch the best practices

Use `WebFetch` on `https://github.com/shanraisshan/claude-code-best-practice` with this prompt:

> Here is the vision of a Claude Code project:
>
> ```
> <full content of docs/VISION.md>
> ```
>
> Extract from this page the Claude Code best practices that are **relevant for THIS project specifically** (not a generic list). Categorize the recommendations into:
>
> 1. **Sections to add or enrich in `CLAUDE.md`** — for each section: proposed name, suggested content in 3-6 lines, reason tied to the vision
> 2. **`.claude/rules/<topic>.md` files** — for each rule: filename, `paths:` frontmatter if applicable, content, reason
> 3. **Permissions to pre-allow in `.claude/settings.json`** — list of patterns (`Bash(npm run *)`, `Edit(/docs/**)`, etc.) with justification
> 4. **Hooks to consider** — hook type (PreToolUse, PostToolUse, Stop...), purpose, snippet
> 5. **Custom skills / agents / slash commands to create** — name, purpose, trigger
>
> For each recommendation, assign a **High / Medium / Low** priority based on the fit to the vision. Maximum 15 recommendations total — prefer relevance over exhaustiveness.
>
> Output format: structured Markdown, one recommendation per block with `### NAME` + `**Category** | **Priority** | **Reason** | **Suggested content**`.

## Phase 3 — Present the recommendations

Show the WebFetch result to the user, formatted readably.

Note: if WebFetch fails (network, repo moved, etc.) → show the error, offer to retry or skip. Stop if skip.

## Phase 4 — Selection

Ask a multi-select `AskUserQuestion` with the recommendations. If > 10 items, group by category across several calls (max 4 options per call for good UX).

For each recommendation, the option label: `[PRIO] Short name — reason in 1 line`.

## Phase 5 — Recap before applying

Show in text the selected recommendations and what will concretely change (file by file).

Final `AskUserQuestion`: `Apply now` / `Save the recommendations to docs/best-practices-pending.md and apply later` / `Cancel`.

## Phase 6 — Application

For each selected recommendation:

### If "CLAUDE.md section"

- Read the current `CLAUDE.md`
- Find the logical insertion point (before the "Don't" section, usually near the end)
- Use `Edit` to insert the new section with its suggested content
- Check the file stays under 200 lines; if exceeded, alert the user and suggest extracting to `.claude/rules/`

### If "`.claude/rules/<topic>.md` file"

- Create the file with its frontmatter (including `paths:` if suggested) and content
- **Signature**: place `<!-- generated-by: groundrules vX.Y.Z -->` on the line immediately after the closing `---` of the frontmatter (NOT on line 1, because the frontmatter must stay there). Format:
  ```
  ---
  paths:
    - "..."
  ---
  <!-- generated-by: groundrules v1.10.0 -->

  # Title
  ...
  ```
- Check the `.claude/rules/` folder exists (create if needed via `Write`, which creates parents)

### If "`.claude/settings.json` permission"

- Read `.claude/settings.json` if it exists; otherwise start with a minimal `{}`
- Add the permission to the `permissions.allow` array (create the key if absent)
- Write back

### If "hook"

- Do **not** apply automatically — show the snippet to paste manually into `.claude/settings.json` or `.claude/hooks/`
- Reason: hooks have side effects (shell commands) that require human review
- Save the snippet to `docs/best-practices-pending.md` so it isn't forgotten

### If "custom skill / agent / command"

- Don't apply — show the name and purpose, suggest the user create it manually or re-run `apply-best-practices` after some thought
- Save the suggestion to `docs/best-practices-pending.md`

### If "save for later" chosen in phase 5

Instead of applying, write everything to `docs/best-practices-pending.md` (structured Markdown, easy copy/paste). No direct application.

## Phase 7 — Update `.groundrules.json`

Add (or update) the `appliedPractices` field:

```json
"appliedPractices": [
  {
    "appliedAt": "YYYY-MM-DD",
    "source": "shanraisshan/claude-code-best-practice",
    "items": [
      {"category": "claudemd-section", "name": "...", "status": "applied" | "pending"},
      ...
    ]
  }
]
```

The array is append-only: each run adds a dated object (useful if shanraisshan evolves and the user re-applies).

## Phase 8 — Final recap

Show:
- ✅ Applied practices (with modified/created file)
- 📁 Pending practices (saved to `docs/best-practices-pending.md`)
- ⏭️ Ignored practices (not selected by the user)
- 📋 Next steps:
  - Review `docs/best-practices-pending.md` for the suggested hooks and skills
  - Review `CLAUDE.md` (if modified) before committing
  - Run `/groundrules:apply-best-practices` again later if shanraisshan evolves

**NEVER commit automatically.**

## Important rules

- The fetch is **done on every run**: no local cache of the recommendations (otherwise the source repo — which evolves regularly — is pointless).
- For `CLAUDE.md` modifications, **always show the diff** before writing (show old and new via Edit's natural display).
- If `appliedPractices` already exists (re-run), don't duplicate already-applied practices; report "already applied on YYYY-MM-DD" and allow skip or re-apply (useful if the practice evolved).
- Custom hooks and skills are **never** applied automatically — always saved as `pending`.
