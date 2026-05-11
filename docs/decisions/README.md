<!-- generated-by: starter-kit v0.5.0 -->
# Architecture Decisions (ADR)

This folder contains the project's **Architecture Decision Records**: each structural decision made during the project is recorded in a file.

## Format

Inspired by [Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions). See `0000-template.md`.

## Naming convention

`NNNN-title-kebab.md` where NNNN is a 4-digit incremental integer.

Examples:
- `0001-database-choice.md`
- `0002-auth-pattern.md`

## When to create an ADR

When a decision:
- has a **long-term impact** on the architecture
- is **hard to reverse**
- has **explicit tradeoffs** worth documenting
- might be **revisited later** (better to freeze the context now)

No ADR needed for trivial choices or implementation details.

## Index

| # | Title | Status | Date |
|---|---|---|---|
| 0000 | Template | — | — |
| [0001](0001-marketplace-json-location.md) | `marketplace.json` lives in `.claude-plugin/`, not at the repo root | Accepted | 2026-05-11 |
| [0002](0002-plain-text-placeholder-substitution.md) | Plain text placeholder substitution, no templating engine | Accepted | 2026-05-11 |
| [0003](0003-multi-skill-architecture.md) | Multi-skill architecture with `disable-model-invocation: true` | Accepted | 2026-05-11 |
| [0004](0004-starter-kit-json-schema.md) | `.starter-kit.json` schema with `bootstrappedWithVersion` and `migrations` | Accepted | 2026-05-11 |
| [0005](0005-intent-capture-and-apply-best-practices.md) | Intent capture in bootstrap + separate `apply-best-practices` skill | Accepted | 2026-05-11 |
