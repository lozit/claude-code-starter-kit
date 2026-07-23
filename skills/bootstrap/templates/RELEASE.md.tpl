<!-- generated-by: groundrules v1.10.0 -->
# Release — {{PROJECT_NAME}}

> Operational **runbook** for shipping. The CHANGELOG records *what* shipped; this file records *how* to ship safely. Update it whenever a release reveals a fragility (pair it with a `docs/LEARNINGS.md` entry).

## TL;DR

```bash
# The exact commands of a normal release, in order:
<fill in — e.g. npm version patch && git push --follow-tags>
```

## Environments

| Env | Trigger | Host / target | URL |
|---|---|---|---|
| <staging/sandbox> | <e.g. push on main> | <fill in> | <fill in> |
| <production> | <e.g. tag vX.Y.Z> | <fill in> | <fill in> |

## Pre-release checklist

- [ ] Quality suite green locally, **in the same order as CI**: `<lint && typecheck && tests…>`
- [ ] **Capture before shipping** (cf. `CLAUDE.md` → "Capture at checkpoints"): anything **decided** → an ADR, **learned / blocked** → `docs/LEARNINGS.md`, an **agent mistake/drift** → `docs/AGENT-EVALS.md`. A push/tag is the most reliable capture moment.
- [ ] <env-specific checks: migrations applied? secrets present in BOTH envs? functions deployed?>

## Secrets & configuration

- Where they live per environment, how to verify them (names, not values).
- <fill in>

## Rollback

- <how to revert a bad release: previous tag? revert commit? restore procedure?>

## Known fragilities

<!-- Feed this from real incidents — one line each, link the LEARNINGS entry:
- Tags are immutable once pushed: bump a new patch, never re-tag.
-->
- <fill in as you learn>
