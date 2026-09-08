<!-- generated-by: groundrules v1.11.0 -->
# 0015 — Best-effort plugin update check in skills (Phase 0)

**Date**: 2026-06-06
**Status**: Accepted

## Context

Claude Code has **no built-in notification** when an installed plugin from a third-party marketplace has a newer published version: auto-update is opt-in per marketplace, and otherwise the user only sees updates by opening `/plugin`. Users who installed starter-kit and never enabled auto-update can silently run a stale version for months — and `migrate` would happily "update" their projects to that stale version.

The plugin is offline-first (only `apply-best-practices` requires the internet), so any update check must not break that promise.

## Decision

Add a **Phase 0 — plugin update check (best-effort, never blocking)** to the three entry skills: `bootstrap`, `adopt`, `migrate`.

- Mechanism: compare `version` in `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` against the latest published tag via `git ls-remote --tags --refs --sort=-v:refname https://github.com/lozit/claude-code-starter-kit.git 'v*' | head -1` (no auth needed, single lightweight request), run with a **~3s timeout**.
- If a newer version exists: show an **informational note** with the update commands (`/plugin marketplace update claude-code-starter-kit`, then `/plugin` + `/reload-plugins`). In `migrate`, additionally warn that migrating now only brings the project up to the installed version, and recommend updating first.
- **Fail silent**: on timeout, no network, or any error, the skill continues without ever mentioning the check. Never ask a question, never stop.

## Alternatives considered

- **SessionStart hook shipped with the plugin** — plugins can ship `hooks/hooks.json` and SessionStart stdout is injected into context, so a startup notice is feasible. Rejected: the hook would run in **every session of every project** of the user (even non-starter-kit ones) — a global footprint disproportionate for a bootstrap plugin. May be revisited if users ask for proactive notification.
- **Rely on marketplace auto-update only** — documented in the README, but it requires a per-machine opt-in the user must remember; not sufficient alone.
- **WebFetch on the GitHub releases API** — rejected: heavier, and the convention is that WebFetch belongs to `apply-best-practices` only; `git ls-remote` is lighter and auth-free.
- **Check in every skill (including `add-adr`, `learn`, `verify-bootstrap`)** — rejected: those are quick, frequent, sometimes offline micro-actions; the check is most valuable at project-lifecycle moments (bootstrap / adopt / migrate).

## Consequences

### Positive
- Users learn about updates exactly when it matters (starting, adopting, or migrating a project), with the exact commands to run.
- `migrate` no longer silently migrates to a stale plugin version.

### Negative / Tradeoffs
- A network attempt now happens in three formerly fully-offline skills. Bounded: one request, ~3s timeout, silent failure — the offline-first behavior is preserved in practice ("offline-first" now means *degrades gracefully offline*, not *zero network*).
- The marketplace name `claude-code-starter-kit` is hardcoded in the message; if the marketplace is renamed again, sweep the three skills (it already happened once: `starter-kit-local` → `claude-code-starter-kit`, ADR 0016).

### Neutral
- The check reads the public repo only; no telemetry, nothing is sent.

## Notes

- See ADR 0014 (rename `brief/` → `intake/`) for the kind of release this check helps users discover.
- The root `CLAUDE.md` and `docs/VISION.md` offline-first wording was adjusted to mention the best-effort check.
