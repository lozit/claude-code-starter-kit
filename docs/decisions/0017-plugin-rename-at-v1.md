<!-- generated-by: groundrules v1.10.0 -->
# 0017 — Rename the plugin to groundrules at V1.0.0

**Date**: 2026-06-06
**Status**: Accepted — implemented in V1.0.0 (name decided 2026-06-06, implemented 2026-06-06)

## Context

The plugin name `starter-kit` is accurate for the primary use case but **undersells** what the plugin became: "starter kit" suggests a one-shot bundle of files, while the plugin now manages a project's documentation backbone across its whole life (`bootstrap` from scratch, `adopt` brownfield, `migrate` across versions, `verify-bootstrap`, `apply-best-practices`).

Renaming the plugin is however a **near-total rebrand**, far heavier than a folder rename:

- the plugin name is the **slash-command prefix** (`/starter-kit:bootstrap` → all commands change for all users);
- **`.starter-kit.json`** — the state file in every bootstrapped project — carries the name (a rename needs migrate logic for the file itself);
- the **signature** `<!-- generated-by: starter-kit vX.Y.Z -->` lives in every generated file of every project (the `verify-bootstrap` regex, `bootstrap` resume detection, and `migrate` diffing would all need to accept both legacy and new forms);
- the GitHub repo `lozit/claude-code-starter-kit`, the marketplace name (just renamed, ADR 0016), and the links inside generated templates;
- every user must re-add/reinstall.

## Decision

**Rename the plugin `starter-kit` → `groundrules` at V1.0.0.** Keep `starter-kit` for the whole 0.x series; the rename is **the** defining breaking change of **V1.0.0**, shipped with a complete migration path in `migrate` (state-file rename `.starter-kit.json` → `.groundrules.json`, dual-form signature detection, command-alias guidance, repo/marketplace rename).

**Why `groundrules`** — *ground rules* are the rules a team agrees on at the start and lives by afterwards: the exact semantic of the plugin's strongest identity face, chosen by the user — applying **best practices of documentation and configuration** (CLAUDE.md conventions, config, living-docs discipline, `apply-best-practices`, `verify-bootstrap`). It keeps the echo of the rejected `groundwork` without its collisions, and declines well: `/groundrules:bootstrap`, `.groundrules.json`, `generated-by: groundrules`.

**Namespace verification (2026-06-06)** — remarkably free: npm `groundrules` AND `ground-rules` unregistered (registry 404), PyPI free, GitHub shows only four 0-star repos, no trademark surfaced in web searches.

**Formal trademark check (TMview, 2026-06-06, post-release)** — full sweep across USPTO/EUIPO/WIPO + ~80 offices:
- **Class 42 (software services): clear in every office.** **EU: clear in both classes.**
- **Class 9 (downloadable software), US only**: one live conflict — word mark **GROUNDRULES** (US app. 99523675, Noel Innovations LLC, filed 2025-12-01, published for opposition 2026-05-05) for *downloadable social-networking mobile app software*, plus a companion "GROUNDRULES CHALLENGE ACCEPTED". Assessment: low risk for this project — we **use** the name for a free OSS developer tool (no trademark filing), the goods/channels/audiences are disjoint (consumer social app vs dev tooling), "ground rules" is a common phrase (narrow protection), and the EU register is empty. Consequences: do not file a US class 9 mark without IP counsel; re-assess if Noel Innovations' products ever approach developer tooling. The 29 "ground rules" two-word hits are all in unrelated classes (flooring, wine, textiles) or dead.

### Runner-up (kept for the record)

**`charter`** — a *project charter* is the founding document that defines goal, scope and stakeholders, then governs the project: captures the docs-artifact face (VISION, intent) and its normative function. Standard PM vocabulary; npm `charter` abandoned (v0.0.2, 12 years old); "project charter" generic → weak mark. Not chosen: the user weighs the **best-practices face** (docs + config) as the core identity, which `groundrules` carries best.

### Naming due diligence (checked 2026-06-06)

Name conflicts are a **trademark** matter, not copyright (a single word is not copyrightable). Findings:

- **`groundwork` — rejected.** (a) "GroundWork" / "GWOS" are claimed as **USPTO-registered trademarks** by GroundWork Open Source, Inc. (gwos.com), an established IT-monitoring software vendor — same broad software class; (b) the npm package `groundwork` already exists and is itself a **project scaffolding tool** — a direct functional collision, bad for discoverability regardless of the legal question; (c) heavily diluted otherwise (`@usace/groundwork`, `groundwork-css`, `groundwork.js`).
- **`keel` — not shortlisted.** No registered trademark found, but keel.sh / keel-hq is a well-known OSS Kubernetes deployment-automation tool. Compound forms (`claude-keel`, `keel-kit`…) would mitigate; kept here as fallback only.
- **`keelson` — not shortlisted.** Nearly collision-free (one niche maritime API project, RISE-Maritime), but the word is obscure: both the metaphor and the word itself need explaining.
- **`plinth` — not shortlisted.** Diluted without a dominant holder (FreedomBox's web UI is named Plinth — a Debian project; a programming language; assorted libs).
- **`drydock` — rejected.** Heavily crowded in dev tooling (Airship host provisioning, container-update monitoring, mock server, Docker debug tools…).
- **`logbook` — rejected.** Zalando's Logbook (Java HTTP logging) is popular.
- **`best-practices` — rejected.** (a) Command stutter with the existing skill: `/best-practices:apply-best-practices`; (b) it's a category label, not a name — maximally descriptive therefore maximally undiscoverable (every search drowns in the thousands of repos using the phrase as a descriptor); (c) claims authority ("THE best practices") and invites bikeshedding of every opinionated choice, where a proper name says "our way"; (d) only carries the practices face, with zero brand identity. Its sole asset (generic = unmarkable) is shared by `groundrules`/`goldenpath`, which are at least nameable.
- **`goldenpath` — vetted, kept as wildcard.** "Golden path" (Spotify) / "paved road" (Netflix) is the established platform-engineering term for "an opinionated, well-documented way of building" — instantly understood by the target audience, and being a method name owned by no vendor, any mark on it is weak. Not shortlisted: it evokes IDPs/Backstage-style code templates, which is precisely a non-goal of this plugin; the docs-artifact face is absent.
- **`praxis` — rejected.** Direct ecosystem collision: DFilipeS/praxis is an AI-assisted development workflow shipped as agent skills explicitly compatible with Claude Code; plus an AI coding platform (MiteshSharma/praxis), an API framework (praxis/praxis), and the npm name is taken.
- **`rubric` — rejected.** RubricLab ships an AI dev suite including `create-rubric-app` (a scaffolding CLI — same functional collision as `groundwork`), plus a DSL for validating AI-generated code.
- **`touchstone` / `yardstick` — rejected.** Both crowded with active dev tools (benchmarking, testing frameworks; doc-coverage and vulnerability-scanner tooling).
- **`kata` / `gauge` — rejected.** Kata Containers (CNCF), ThoughtWorks Gauge.
- **`ethos` — rejected.** npm `ethos` taken (state-management lib) plus a crypto ecosystem (ethos-connect for Sui, an Ethereum browser); the "eth-" sound evokes Ethereum.
- **`playbook` — rejected.** Conceptually saturated by Ansible playbooks and countless SaaS products.
- **`house-rules` — not shortlisted.** Charming semantic (the CLAUDE.md *is* the house rules; cf. the `sbt-houserules` precedent), but scattered namespace (validators, game mods, a GitHub org) and the hyphen is awkward in a command prefix.
- **`canon` — not shortlisted.** Moderate namespace (`@datawheel/canon-core`, cannon.js typo-confusion, the Canon Inc. brand looming in another class).
- **`doctrine` — rejected.** Doctrine ORM (PHP) is major.
- Earlier rejects: `blueprint` (overemphasizes the initial plan, docs are living), `kickstart`/`launchpad`/`scaffold` (start-only bias, or implies app-code generation which is a non-goal), `bedrock`/`primer`/`cornerstone`/`foundry` (major existing software brands: AWS, GitHub, etc.).
- Wildcards if `groundrules` falls through before V1.0.0: `charter` (runner-up, see above), `goldenpath` (vetted), and unvetted sparks `mainstay`, `plumbline`, `slipway`, `outfitter`, `tenet`, `precept`.
- At V1.0.0 implementation time: run a formal USPTO (tmsearch) + EUIPO (eSearch) check on Nice classes 9/42 for `groundrules`, re-check the npm/GitHub namespace at that date, and consider squatting the npm name preventively. **Done 2026-06-06**: `groundrules@0.0.1` published on npm — an honest placeholder (executable pointer stub + README to the repo), securing the developer-channel name; a real npm CLI remains a post-1.0 option.

## Consequences

### Positive
- The name decision is made and namespace-verified — V1.0.0 scoping starts from a settled identity, not a debate.
- No breaking churn during 0.x; users keep stable command names until the one big break.

### Negative / Tradeoffs
- The underselling `starter-kit` name persists until V1.0.0.
- The `groundrules` namespace is free **today**; it could be taken before V1.0.0 ships (mitigation: preventive npm squat, see Notes).

## Notes

- Tracked in `PLAN.md` ("Up next"): V1.0.0 = implement the rename with full migration.
- At V1.0.0 the GitHub repo is renamed to **`lozit/groundrules`** (not `claude-code-groundrules`): the project is meant to extend beyond Claude Code to other harnesses in the future, so the repo name stays harness-neutral. The **marketplace** keeps the harness-scoped name **`claude-code-groundrules`** — it designates the Claude Code distribution channel of the groundrules project (and avoids the redundant `groundrules@groundrules` install spec). GitHub redirects old repo URLs, but marketplace adds should be re-verified.
