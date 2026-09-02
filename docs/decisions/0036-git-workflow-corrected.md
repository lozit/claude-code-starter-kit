<!-- generated-by: groundrules v1.10.0 -->
# 0036 — Git workflow corrected: PR on protected `main`, no AI attribution (supersedes 0028)

**Date**: 2026-09-02
**Status**: Accepted

## Context

[ADR 0028](0028-git-workflow-conventions.md) recorded three git conventions for this repo. Two of
its three premises are no longer true — and both were **falsifiable against the machine**, which is
how the drift was found:

1. **Branching** — 0028 states the model is *"trunk-based on `main`: changes land directly on
   `main`"*. But `main` is **protected**: `required_pull_request_reviews` is on and
   `enforce_admins: true`, so a direct push is refused even for the repo admin (force-push and
   deletion are blocked too). The practice already moved: PR #1 was merged on 2026-09-02. The
   setting is the intent; the ADR was the stale half.
2. **AI attribution** — 0028 states *"for this repo: **attribute** (no rule forbids it)"*. A rule
   **does** forbid it: the maintainer's global `~/.claude/CLAUDE.md` says *never* add a
   `Co-Authored-By: Claude` trailer, a `Claude-Session:` trailer or a "Generated with Claude Code"
   line — on commits, PRs and issues alike — and states that it overrides any default harness
   guidance. 0028's *conditional* was right ("attribute **unless** a rule forbids"); only its factual
   premise was wrong. Commits carried the trailer up to 2026-07-23 and stopped at the 2026-09-02
   commit, so the practice had already followed the rule; the ADR had not.

Point 3 of 0028 — **boundary commits** (a completed chunk, Conventional Commits, tag + finalize the
`CHANGELOG` at release, message references the `CHANGELOG` rather than re-listing it) — is unchanged
and carried over here verbatim in intent.

## Decision

**1. Branching — short branch + self-merged PR on a protected `main`.**
- `main` stays **protected** (PR required, admins included, no force-push, no deletion). Work lands
  through a short-lived branch and a PR, merged by the maintainer; **0 approvals** are required, so
  a solo maintainer is never blocked — the protection buys the safety net (no accidental direct
  push, no force-push over published history), not a review ceremony.
- Tags `vX.Y.Z` still mark releases, cut on `main` after the merge.
- The **generated** `CLAUDE.md.tpl` stays branching-model-neutral ("state your own model") — that
  half of 0028 was and remains correct. This ADR only restates the *dogfood's* model.

**2. AI attribution — none in this repo.**
- No `Co-Authored-By: Claude …`, no `Claude-Session:` trailer, no "Generated with Claude Code" line
  — in commit messages, PR descriptions or issue bodies. The forbidding rule lives in the
  maintainer's global `CLAUDE.md` and applies to every repo of theirs, this one included.
- The rule is recorded **in the repo** as `policies.noAiAttribution: true` in `.groundrules.json`,
  the same field `bootstrap`/`adopt` set from detection ([ADR 0011](0011-detect-no-ai-attribution-policy.md)).
  A machine-local global file cannot be read by a fresh clone, a CI run or a subagent; the
  `.groundrules.json` field can. This is the dogfood of ADR 0011's own persistence step — until now
  the repo detected the policy for *users* and recorded nothing for *itself*.
- **No history rewrite**: the ~20 commits that carry the trailer (2026-06-13 → 2026-07-23, under
  0028's rule) stay as they are. Rewriting published history to enforce a later rule breaks clones
  and falsifies the record.

**3. Boundary commits — unchanged from 0028**, and now framed per PR: a PR groups the boundary
commits of one chunk of work; commit at natural boundaries within it, never a mega-commit per
release.

## Alternatives considered

- **Lift the branch protection and keep trunk-based** (the other way to close the contradiction) —
  rejected by the maintainer: the protection is deliberate, and its cost for a solo maintainer is
  one `gh pr create && gh pr merge`, not a review wait.
- **Amend 0028 in place** — rejected: 0028 is Accepted and its *context* (the 2026-06-13 drift
  review) is still an accurate record of what was decided then. Superseding keeps both the old
  reasoning and the correction legible, as 0029 did for 0009.
- **Rely on the global `CLAUDE.md` alone for attribution** — rejected: it is machine-local. See the
  `.groundrules.json` point above.
- **Rewrite the ~20 attributed commits** — rejected, same reasoning as 0028.

## Consequences

### Positive
- Both stale premises are closed against verifiable state (`gh api …/branches/main/protection`,
  `.groundrules.json`), not against memory.
- The attribution rule survives a clone, a fresh agent and a headless run, because it is in the repo.
- Dogfoods ADR 0011 end to end: detect → persist → suppress.
- **It is also the single-operator form of separation of duties.** The AI-native SDLC playbook rests
  that principle on code owners and a team; with one operator there is no second person, so the
  separation has to come from the machine. `enforce_admins: true` is exactly that: the agent cannot
  land its own work — a human merge is structurally required, not merely habitual. Nothing extra to
  remember, no ceremony added (see `intake/2026-09-02-ai-native-sdlc-evals-and-verification.md`,
  tension 4, which was written against 0028's stale trunk claim).

### Negative / Tradeoffs
- One extra step per landing (branch + PR) for a solo maintainer — accepted for the safety net.
- Two ADRs to read on git workflow instead of one (0028 for the history, 0036 for the rule) —
  mitigated by the Superseded marker and the index.

### Neutral
- Nothing changes in the plugin's **output**: the generated `CLAUDE.md` remains branching-neutral and
  the attribution detection was already correct.

## Notes

- Supersedes [ADR 0028](0028-git-workflow-conventions.md) (points 1 and 3 of its Decision; its
  boundary-commit point is carried over).
- Related: [ADR 0011](0011-detect-no-ai-attribution-policy.md) (detect + persist a no-attribution
  policy), [ADR 0010](0010-managed-project-claude-md-deference.md) (deference to a managed
  `CLAUDE.md`).
- Verified 2026-09-02: `gh api repos/lozit/groundrules/branches/main/protection` →
  `required_pull_request_reviews` present, `enforce_admins.enabled: true`,
  `allow_force_pushes.enabled: false`.
