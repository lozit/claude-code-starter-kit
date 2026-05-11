<!-- generated-by: starter-kit v0.6.0 -->
# Learnings — Starting-Claude

Non-trivial learnings that emerged during the project. Reverse-chronological order (newest at the top).

One entry per learning. Keep the format simple: title, context, lesson.

---

## 2026-05-11 — Verify-bootstrap regex must be whitelist, not catch-all

**Context**: First E2E run of `/starter-kit:verify-bootstrap` on the dogfood (V0.6). Initial regex `\{\{[A-Z_]+\}\}` flagged 4 files as having "unsubstituted placeholders" — but they were all *documentation* references like `` `{{KEY}}` `` in backticks (PLAN.md mentioning a future hook, CHANGELOG describing the feature, etc.).
**Lesson**: When validating a templating output, use a **whitelist of real placeholder names** (`PROJECT_NAME`, `DESCRIPTION`, `LANG`, etc.), not a catch-all pattern. Documentation about placeholders is a normal occurrence in a self-aware project; the validator must distinguish "documentation of `{{KEY}}` as a concept" from "actual `{{KEY}}` that should have been substituted."

## 2026-05-11 — YAML frontmatter forces signature placement after closing `---`

**Context**: Same E2E run. `.claude/rules/plugin-meta.md` was flagged as "signature absente" even though it had the right signature — but on line 7, after the YAML frontmatter (`---\npaths:\n  - "..."\n---`). The verify-bootstrap script only scanned `head -6`.
**Lesson**: Rules, skills, and any file requiring YAML frontmatter at line 1 **cannot** carry an HTML signature on line 1. Convention: place the signature on the line **immediately after the closing `---`**, and the validator must scan at least the first **10 lines** to find it. Generators (e.g., `apply-best-practices` creating `.claude/rules/*.md`) must follow the same convention.

<!-- Example:

## YYYY-MM-DD — Short title

**Context**: what we were doing.
**Lesson**: what we learned, and how to apply it next time.

-->
