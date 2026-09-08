<!-- generated-by: groundrules v1.10.0 -->
# 0039 — The superpowers interop section is conditional, detected rather than asked

**Date**: 2026-09-08
**Status**: Accepted

## Context

The generated `CLAUDE.md` carries a `### Interop with superpowers` section: a heading, an
introductory sentence and four bullets explaining that groundrules and
[superpowers](https://github.com/obra/superpowers) work at different altitudes and how their
artifacts relate. Eight lines, unconditional, in every project the plugin has ever generated.

Most projects do not use superpowers. For those, the section is eight lines of instruction about
a plugin that is not installed — and the budget it spends is the scarcest one this project has.
[ADR 0021](0021-context-economy-index-over-doc-search.md) and the <200-line `CLAUDE.md` doctrine exist
because a longer file lowers adherence to every line in it, including the ones that matter. A
section that is pure noise for the majority does not merely waste space; it dilutes the rest.

The plugin already detects superpowers in four places — `bootstrap` Phase 1, `adopt` Phase 1,
`/groundrules:prd` Phase 1 and `/groundrules:realize` Phase 1 — and already changes its behaviour
accordingly ([ADR 0026](0026-posture-and-per-feature-prd.md): defer the per-feature altitude when
present). The one place the detection was never wired is the section that *describes* the interop.

## Decision

**1. The section is conditional on a new `{{HAS_SUPERPOWERS}}` placeholder.** When `false`, the
whole `###` block is dropped from the composed `CLAUDE.md` before it is written. This reuses the
drop mechanic the global-tailoring logic already uses, on a different trigger: there a section
goes because the global `CLAUDE.md` already covers it, here because the plugin it describes is
not in play.

**2. Detected, never asked.** Three read-only, best-effort signals, in order: the presence of
`docs/superpowers/plans/` or `specs/` in the folder; this folder's own `.claude/settings.json`,
where a **project-scope** install is recorded; failing both, the user's installed-plugin registry,
if the harness exposes one. None → `false`, which is both the default and the common case.

**Scope is part of the signal, not a detail.** The registry records project-scope installs
alongside user-scope ones, each carrying the path it belongs to. Reading it without filtering
makes *every folder on the machine* report `true` because one unrelated repository installed the
plugin — a false positive that no user could explain. A registry entry therefore counts only when
it is user-scoped, or project-scoped **to this folder**. The name is matched by exact equality on
the segment before `@`: a fork is not the plugin whose interop this section describes.

**Why not ask.** The obvious alternative is one interview question. It fails on its own terms:
a question costs *every* user something in order to spare a minority eight lines, which moves
the tax rather than removing it. It also cannot be answered well at bootstrap time — the folder
is empty, the project does not exist yet, and "will you use superpowers on this project?" asks
someone to predict a tooling choice they have not made. Detection answers the question that is
actually decidable: *is that plugin here now?*

**3. A wrong `false` is recoverable, and says so.** superpowers lets the user relocate its
artifacts, so signal 1 can miss; a project-scope install can leave no trace in the user's
registry, so signal 2 can miss too. When the section is omitted, the final recap says so in **one
line** and names the two ways back — `/groundrules:migrate`, or pasting the block from the
template. When the section is kept, the recap says nothing: a section that is present needs no
explanation.

**4. The inline mention stays.** `## Claude Code workflow` says *"a PRD (`/groundrules:prd`, or
your superpowers spec)"*. Four words, an aside rather than a section, and not worth a second
conditional.

**5. `HAS_SUPERPOWERS=true` overrides the global tailoring.** No global `CLAUDE.md` covers a
plugin interop, so the section is never dropped as "already covered".

## Alternatives considered

- **Ask one interview question** — rejected, per decision 2. It taxes everyone to spare a few,
  and at bootstrap time it asks for a prediction rather than a fact.
- **Move the block to its own template and splice it in**, like `loop/CLAUDE-invariants.md` —
  rejected: the splice exists because the loop scaffolding is a whole namespace with its own
  files. Here one `###` section is dropped from a file already being composed in memory. A new
  template file and a new mapping row would be more machinery than the thing they carry
  ([ADR 0034](0034-posture-keep-the-diff-small.md)).
- **Leave it unconditional and shorten it instead** — rejected: a shorter irrelevant section is
  still irrelevant, and the compression would cost the section its usefulness for the users who
  *do* need it.
- **Drop the section outright** — rejected: for a superpowers user it is the note that prevents
  the actual failure mode, duplicating `PLAN.md` against the plugin's per-feature plans.

## Consequences

### Positive
- A project not using superpowers gets a `CLAUDE.md` eight lines shorter, spent instead on
  content that applies to it.
- The detection that four skills already performed now also governs the document that describes
  it — one fact, one source.
- No new interview question: the interview's length is unchanged.

### Negative / Tradeoffs
- **The registry signal reads a harness-owned file whose location and shape may move.** Written
  as best-effort and explicitly allowed to fall through, so a change degrades to `false` — the
  common answer anyway — rather than to an error.
- **Detection can be stale in the other direction.** A folder can hold `docs/superpowers/` from a
  plugin no longer in use; signal 1 still says `true`. Keeping a section that is merely no longer
  needed is the cheaper error, so the ordering stands.
- **A superpowers user with relocated artifacts and a project-scope install gets a false
  negative.** Mitigated by the recap line, not by a question.
- One more placeholder to keep in sync across `bootstrap`, `adopt` and `migrate`.

### Neutral
- `CLAUDE.md.tpl` itself is unchanged: the section is dropped at generation time, so the template
  stays the single full source.
- Recorded as `answers.usesSuperpowers` in `.groundrules.json`, so `migrate` can honour it later.

## Notes

- **Validated by two fresh-subagent dry runs** before merge (the discipline recorded in
  `docs/LEARNINGS.md`): an empty folder and a folder carrying `docs/superpowers/plans/`. Both
  behaved correctly — flag, section, parent heading, recap, and no question in either. The runs
  also returned nine defects in the instructions, all fixed here: the unfiltered registry scope
  above; a heading the drop rule could not match literally, and a bullet count coupling it to the
  template's body; `Call 2c`'s skip still keyed on `docs/superpowers/plans/` alone rather than on
  the flag; the detection filed under `answers` as if it had been asked; and a recap pointing at
  `/groundrules:migrate`, which has no superpowers awareness and would only have shown the block
  as a generic diff.
- **`{{HAS_SUPERPOWERS}}` is a decision variable, not a substituted token** — like every other
  `{{HAS_*}}`, it appears in no template. Both runs flagged the placeholder list for presenting
  the two as one kind; the list now says which is which.

- Detection sites that already existed: `bootstrap` Phase 1, `adopt` Phase 1, `prd` Phase 1,
  `realize` Phase 1. The caveat that superpowers can be relocated is recorded in
  `skills/prd/SKILL.md` and is why signal 1 alone was never enough.
- Related: [ADR 0021](0021-context-economy-index-over-doc-search.md) (context economy),
  [ADR 0026](0026-posture-and-per-feature-prd.md) (defer to superpowers when present),
  [ADR 0029](0029-content-aware-claude-md-tailoring.md) (the drop mechanic this reuses).
