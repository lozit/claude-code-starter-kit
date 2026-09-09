<!-- generated-by: groundrules v1.11.0 -->
# Security & Compliance — {{PROJECT_NAME}}

**Living** document of security and compliance (GDPR / privacy) choices.

For the **why** behind structural decisions → see `docs/decisions/`.

## Authentication

- Method: `<fill in>` (password, OAuth, magic link, SSO...)
- Session / token handling: `<fill in>`
- Reset, MFA: `<fill in>`

## Authorization / access control

- Model: `<fill in>` (roles, RBAC, ABAC, RLS...)
- Role × resource matrix: `<fill in>`

## Personal data (GDPR / privacy)

- Personal data collected: `<fill in>`
- Legal basis for processing: `<fill in>`
- Retention period: `<fill in>`
- User rights (access, deletion, export): `<fill in>`
- Processors / transfers outside the EU: `<fill in>`

## Secrets and configuration

- Where secrets live (vault, env vars, manager): `<fill in>`
- NEVER commit a secret. See `.gitignore` (`.env`).

## Attack surface and controls

- Untrusted inputs (forms, API, uploads) and validation: `<fill in>`
- Encryption in transit / at rest: `<fill in>`
- Logging and audit: `<fill in>`

## Incident / disclosure

Procedure in case of a breach or leak: `<fill in>`.
