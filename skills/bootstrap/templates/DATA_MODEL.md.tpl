<!-- generated-by: groundrules v1.10.0 -->
# Data Model — {{PROJECT_NAME}}

**Living** description of the data model. Update it whenever the schema changes.

For the **why** behind choices (engine, denormalization...) → see `docs/decisions/`.

## Overview

Paragraph or diagram: the main entities and their relationships.

<!-- Mermaid example:
```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains
```
-->

## Entities

### Entity A

| Field | Type | Constraints | Description |
|---|---|---|---|
| `id` | `uuid` | PK | Identifier |
| `...` | `...` | `...` | `...` |

### Entity B

| Field | Type | Constraints | Description |
|---|---|---|---|
| `id` | `uuid` | PK | Identifier |

## Relationships

- `A` 1—N `B`: ...

## Access rules / row-level security

> If the DB enforces row-level access rules (RLS) or policies, document them here. Otherwise, delete this section.

- `A`: a user only sees their own rows (`owner_id = auth.uid()`).

## Indexes and performance

- `A(created_at)` — for date-range queries.

## Migrations

Where migrations live (folder, tool) and how to create one: `<fill in>`.
