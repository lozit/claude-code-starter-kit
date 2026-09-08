<!-- generated-by: groundrules v1.10.0 -->
# 0040 — Three bootstrap modes: emptiness and prior state are two questions, not one

**Date**: 2026-09-08
**Status**: Accepted

## Context

`bootstrap`'s Phase 1 defined its operating mode twice, in two places, and the two definitions
disagreed.

- One rule made **resume mode** a consequence of the state file: `.groundrules.json` present (or
  a legacy `.starter-kit.json`) → load it and switch to resume.
- The other, at the end of the same phase, made it a consequence of the folder being non-empty:
  *"If the folder is completely empty → classic bootstrap mode. Otherwise → resume mode."*

For the case both rules cover — a non-empty folder that groundrules has never touched — they give
opposite answers. The first says there is nothing to resume; the second says resume. A fresh
agent executing the skill has to pick, and nothing in the file tells it which.

The contradiction was found by running the instructions rather than reading them: a subagent
evaluating a brownfield fixture reported that it had followed the second rule *"because it is the
one that actually decides the mode"*, and flagged that the two were being answered with one word.

The disagreement is not cosmetic, because the third case has a **different right answer than
either rule gives**. A non-empty folder with no groundrules history is exactly what
[ADR 0008](0008-adopt-brownfield-projects.md) created `/groundrules:adopt` for: bootstrap
classifies every pre-existing file as foreign and ignores it, which 0008 called *lossy and
semantically odd*. Calling that situation "resume" hides it behind a word that promises the
opposite — that there is prior state to pick up.

## Decision

**Two questions decide the mode, asked in this order — is there groundrules state, and only then
is the folder empty — and they name three modes.**

| State file present? | Anything else in the folder? | Mode |
|---|---|---|
| **yes** | irrelevant | **resume** |
| no | no | **bootstrap** |
| no | yes | **brownfield** |

- **bootstrap** — generate everything, no arbitration.
- **resume** — prior groundrules state exists: load it, skip what is already there, re-ask nothing
  the state answers. *Resume* now means only this, and the state file alone decides it: a folder
  is never "too empty" to resume.
- **brownfield** — someone else's files, no groundrules history. **Say so, and point at
  `/groundrules:adopt` first**, then offer to continue with bootstrap anyway (create only what is
  missing, ignore the rest).

**The order matters, and so does the definition of "empty".** State first, because the state file
is itself a file: asking "is the folder empty" first makes a folder holding only
`.groundrules.json` ambiguous. And *anything else* **ignores `.git/` and the state file** — a
folder holding only a git repository has nothing to preserve, so it is `bootstrap`, not
`brownfield`. Without that, every `git init` followed by a bootstrap would be misrouted.

**The mode is named `brownfield`, not `foreign`.** `foreign` already denotes a **file** category
in this skill — present without a generated-by signature — and it is recorded under that name in
`.groundrules.json`'s `skippedFiles`. `brownfield` is `adopt`'s own vocabulary, used in its
description, in the README and in ADR 0008. Fixing one overloaded word by introducing another
would have been the same mistake in a new place.

**Never refuse, and never silently proceed as if this were a resume.** `adopt` is a
recommendation, not a gate: a user who wants the bootstrap behaviour on a non-empty folder is
entitled to it, and being told what the other skill does is enough.

**The recommendation is made before the interview begins, and repeated at the confirmation
screen.** Before, because asking whether the user wants a different skill *after* starting to
question them is the wrong order. Repeated, because the recap is the last thing seen before
generating, and an advisory given once has scrolled away by the moment it decides anything. The
offer is one question, and choosing `adopt` **stops** the skill with the command to run: a skill
cannot invoke another.

## Alternatives considered

- **Keep two modes and pick one rule** — rejected whichever way it is resolved. Picking the state
  file leaves the brownfield case unnamed and unhandled; picking non-emptiness keeps calling it
  *resume*, which is the misnomer that hid the gap.
- **Refuse and redirect to `adopt`** — rejected: bootstrap on a folder with a stray `README.md` is
  a legitimate thing to want, and a hard redirect would make the common small case pay for the
  rare large one.
- **Detect "brownfield-ness" by size** (a file count, a LOC threshold) — rejected: a threshold is
  a guess that fails at the boundary in both directions, where the two facts already available —
  is it empty, is there state — are exact.
- **Silently delegate to `adopt`** — rejected: switching skills under the user is a surprise, and
  `adopt` asks different questions with different consequences.

## Consequences

### Positive
- The contradiction is gone: one rule, one table, and *resume* means one thing.
- The brownfield case is named and routed instead of being absorbed by a word that denied it.
- A user who runs `bootstrap` where `adopt` fits is told so, at the moment it is cheap to switch.

### Negative / Tradeoffs
- A third mode is one more branch to keep consistent across `bootstrap`'s phases, and Phase 4's
  ignored-files list now has two possible reasons rather than one.
- Users who were relying on the old wording will see a different announcement for the same folder.
  The behaviour they get is unchanged unless they take the `adopt` suggestion.

### Neutral
- No change to `adopt`, to any template, or to any generated file.

## Notes

- Found by a fresh-subagent dry run, per the discipline recorded in `docs/LEARNINGS.md`; the same
  run also surfaced that `bootstrap`'s Phase 4 recap had no slot for the notes two earlier phases
  route to it, fixed alongside this ADR.
- Related: [ADR 0008](0008-adopt-brownfield-projects.md), which created `adopt` for precisely the
  case this ADR now names.
