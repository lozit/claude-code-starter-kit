<!-- generated-by: starter-kit v0.4.0 -->
# 0004 — `.starter-kit.json` schema with `bootstrappedWithVersion` and `migrations` array

**Date**: 2026-05-11
**Status**: Accepted

## Context

`.starter-kit.json` is the persistent state file written at the project root by `bootstrap`, read by every other skill, and updated by `migrate`. V0.1 designed it minimally:

```json
{
  "starterKitVersion": "<version>",
  "bootstrappedAt": "<date>",
  "answers": { ... },
  "generatedFiles": [ ... ],
  "skippedFiles": { ... }
}
```

When `migrate` was designed in V0.4, two needs emerged that the V0.1 schema could not satisfy:

1. **What was the original bootstrap version?** Once `starterKitVersion` is bumped by a migration, the genesis is lost. But knowing the origin matters: it tells migrate which templates the user *might* have edited (those that existed at bootstrap) vs which are *new* introductions.
2. **What migrations have happened?** A project might have migrated 0.1 → 0.2 → 0.3 → 0.4 over months. The git history is one source of truth, but `.starter-kit.json` is not always git-tracked, and history correlation is fragile. A local log inside the file is robust.

## Decision

Three version-related fields, with distinct lifecycles:

| Field | Mutability | Purpose |
|---|---|---|
| `starterKitVersion` | **mutable** — bumped on each migration | Current effective version of the project's structure |
| `bootstrappedWithVersion` | **immutable** — set once at bootstrap | Genesis version, never overwritten |
| `migrations` | **append-only** — `migrate` pushes one entry | Log of `{from, to, at, note?}` per migration |

Final schema:

```json
{
  "starterKitVersion": "0.4.0",
  "bootstrappedAt": "2026-05-11",
  "bootstrappedWithVersion": "0.1.0",
  "migrations": [
    {"from": "0.1.0", "to": "0.4.0", "at": "2026-05-11"}
  ],
  "answers": { ... interview answers ... },
  "generatedFiles": [ ... paths relative to project root ... ],
  "skippedFiles": { "<path>": "<reason>" }
}
```

`bootstrap/SKILL.md` writes this schema for every new project. `migrate/SKILL.md` updates `starterKitVersion`, appends to `migrations`, optionally updates `generatedFiles` if new files were created.

**Backward compatibility**: when `migrate` reads an old `.starter-kit.json` lacking `bootstrappedWithVersion` or `migrations`, it injects sensible defaults: `bootstrappedWithVersion = starterKitVersion`, `migrations = []`. The schema gap is invisible to the user.

## Alternatives considered

- **Single mutable `starterKitVersion`** (V0.1 schema kept as-is) — rejected: loses origin info after the first migration.
- **Full event log of every action** (every bootstrap field change, every file regeneration logged) — rejected: overkill for now, file would grow unbounded. If forensic audit is ever needed, git history is the right source.
- **External history file** (`.starter-kit-history.json` alongside `.starter-kit.json`) — rejected: splits state across two files for no real gain; the migration log is small.
- **Git history as the only source of truth** — rejected: not all projects choose to track `.starter-kit.json`, and even when tracked, parsing git log to reconstruct version history is brittle.

## Consequences

### Positive
- Migrate can show meaningful "you've gone from X to Y" reports.
- The genesis version is preserved even after multiple migrations.
- Backward-compatible: V0.1 projects work with V0.4 migrate without manual editing of `.starter-kit.json`.
- Schema is human-readable and easy to inspect/edit by hand if something goes wrong.

### Negative / Tradeoffs
- Three version fields invite confusion: a future contributor might wonder which is "the real" version. Mitigation: `starterKitVersion` is the answer to "what version am I on now"; the others are historical.
- Migration entries are not validated by anything — a user editing the file manually could write inconsistent history. Acceptable: this is local state, the user is the only writer in practice.
- Slight overhead at bootstrap: writing 2 extra fields. Negligible.

### Neutral
- The dogfood `.starter-kit.json` for this repo (Starting-Claude) carries one synthetic migration entry noting the informal dev-bumps from V0.1 to V0.4 — the migrations were not done via `/starter-kit:migrate` but by `sed` during plugin authorship. Documented for honesty.

## Notes

- Schema documented in `skills/bootstrap/SKILL.md` phase 4 (in the "État persisté" section).
- Read by all four skills (bootstrap, add-adr, learn, migrate); written by bootstrap and migrate; left alone by add-adr and learn (they only read `answers.lang`).
- See [ADR 0003](0003-multi-skill-architecture.md) for the multi-skill architecture that makes this shared schema necessary.
