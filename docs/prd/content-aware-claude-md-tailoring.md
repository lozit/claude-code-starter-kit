<!-- generated-by: groundrules v1.10.0 -->
# PRD — Content-aware CLAUDE.md tailoring (retire the lean template)

> Product Requirements Document for a single feature. Written **before** building, so the agent
> builds the right thing — not a coherent surprise. Validate it (and answer the open questions)
> before any code. Update it if the scope shifts.

**Date**: 2026-06-13 · **Status**: draft

## Problem

`bootstrap`/`adopt` choose between two CLAUDE.md templates on a **boolean of presence**:
*does any global `~/.claude/CLAUDE.md` exist?* → if yes, use the static `CLAUDE.lean.md.tpl`,
which has pre-removed all cross-cutting sections (commits, git workflow, verification, tools)
on the assumption the global covers them.

That assumption breaks the moment the global is thin. A global that only says *"always write
in English"* still triggers the full strip → the generated project CLAUDE.md loses its git /
commits / verification guidance entirely. **Holes.** The decision is presence-based, never
content-based.

This reverses **ADR 0009**, which explicitly rejected "auto-slim by parsing the global"
(*"too clever, fragile, against template-over-code"*) and accepted existence-only detection as
a known limitation. The reversal is justified: (1) judging coverage on a <200-line file is a
solid use of a current model; (2) template-over-code (ADR 0002) is **preserved** — templates stay
plain text, only the SKILL's assembly logic changes; (3) the "known limitation" is precisely the
bug the user hit. → **A new ADR (number assigned when built) supersedes ADR 0009.**

## Success criteria

- A thin global (e.g. "write in English") → generated CLAUDE.md keeps git/commits/verification
  (output ≈ today's full, minus only the genuinely-covered topic).
- A rich global (git + commits + verification rules) → generated CLAUDE.md omits those
  (output ≈ today's lean), and **lists what it omitted** so the user can audit.
- No generated CLAUDE.md ever loses a cross-cutting section the global does **not** cover.
- `CLAUDE.lean.md.tpl` no longer exists; one template (`CLAUDE.md.tpl`) is the single master.
- verify-bootstrap still passes (signature + no-bare-placeholder checks are section-agnostic).

## Scope

**In scope**
- Rewrite `bootstrap` Phase 5 "CLAUDE.md template selection": always render `CLAUDE.md.tpl`;
  when a global exists, read it, omit only the cross-cutting sections it covers, keep the rest,
  bias-to-keep on doubt, recap to the user what was omitted.
- `adopt`: same tailoring when generating a fresh CLAUDE.md; for an **existing** project
  CLAUDE.md, make the free-zone additions **gap-driven** (propose only the missing groundrules
  sections) instead of a fixed pointer blob — never overwrite managed content.
- Delete `CLAUDE.lean.md.tpl`.
- A new ADR (supersedes 0009); ADR 0009 header → `Superseded by <that ADR>`; index updated.
- Meta `CLAUDE.md` line 3: drop the `(and CLAUDE.lean.md.tpl)` mention.
- CHANGELOG `[Unreleased]` + PLAN.md.

**Out of scope** (explicit)
- A template engine or `{{KEY}}` logic for the omission — it's SKILL-level agent judgment, not
  template machinery (ADR 0002 preserved).
- Rewriting historical records that mention "lean" truthfully-as-of-their-date (CHANGELOG/PLAN/
  ADR 0012/0014/0020/0026). Only ADR 0009 gets a supersede header.
- Changing verify-bootstrap / migrate (no lean references; data-driven via `generatedFiles`).

## Constraints

- **Template over code** (ADR 0002): templates stay plain text.
- **Context economy**: omit only the genuinely redundant; the global is short (our own <200-line
  doctrine) so reading it fully is cheap.
- **Never overwrite** a managed/foreign CLAUDE.md (ADR 0010 deference still wins, first).
- Posture per ADR 0026: the project CLAUDE.md keeps its own Posture/repo-is-memory even with a
  global, unless the global clearly covers them.

## Build plan

Ordered steps, each with a validation point.

1. **Settle the collapsible-section list** (the only real judgment call — see Open questions).
   Validate: list agreed with the user before touching the SKILL.
2. Rewrite `bootstrap/SKILL.md` Phase 5 + detection (read global content, not just existence).
   Validate: dry-read the new instructions against a thin-global and a rich-global scenario.
3. Apply the same tailoring + gap-driven existing-file logic to `adopt/SKILL.md`.
   Validate: the "CLAUDE.md already present" path still never overwrites.
4. Delete `CLAUDE.lean.md.tpl`; fix meta `CLAUDE.md` line 3.
   Validate: `grep -rn "CLAUDE.lean" skills/` returns nothing.
5. New ADR (supersedes 0009) + supersede header on 0009 + index.
6. CHANGELOG `[Unreleased]` + PLAN.md.
   Validate: E2E — bootstrap against (a) no global, (b) thin global, (c) rich global → inspect
   the three generated CLAUDE.md outputs; verify-bootstrap clean on each.

## Risks

What could go wrong, and the mitigation.

- **Agent mis-reads the global and omits a section it doesn't actually cover → hole.**
  Mitigation: bias-to-keep on doubt; always show the user the omission list; they can veto.
- **Less deterministic than picking a file** → harder to reason about output.
  Mitigation: the recap makes every omission explicit and auditable; verify-bootstrap stays green
  because its checks are section-agnostic.
- **Reversing an accepted ADR sets a precedent.** Mitigation: do it the disciplined way — a new
  ADR supersedes 0009 with the reasoning recorded, not a silent edit.

## Open questions

<!-- Resolved 2026-06-14 before building. -->
- **Collapsible-section list** → **Resolved: conservative** (refined after E2E). Collapse-if-the-global-covers-its-*primary*-directive:
  `### Commits` · `## Git workflow` · `## Verifying the work` · `## Claude Code workflow` ·
  `### Permissions and settings`. **`## Don't` is always kept** (it carries the signature "repo is
  the only memory" line — the E2E showed a generic-Don'ts omission could never fire, so it was
  dropped from the collapsible set). **Always keep** (even if the global mentions them):
  groundrules' signature conventions — Session-start order · Capture-at-checkpoints ·
  When-to-document routing · repo-is-only-memory · living docs · Posture — plus the project-specific
  (Description · Setup/Build/Test · Key files · Code/`{{STACK}}` · Updating-this-file · Tech stack ·
  Notes). Bias-to-keep on any doubt; orphaned parent headings dropped, parents with kept children kept.
- **Omission style** → **Resolved: drop the section + list omitted topics in the deference note**
  (`{{GLOBAL_CLAUDE_NOTE}}` carries "Omitted — your global covers them: …"). Most economical and
  auditable; recap to the user, who can veto.
