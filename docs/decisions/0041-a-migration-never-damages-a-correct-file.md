<!-- generated-by: groundrules v1.11.0 -->
# 0041 — A migration never damages a correct file: two write guards, and a comparison text that matches what `bootstrap` would produce

**Date**: 2026-09-08
**Status**: Accepted

## Context

`/groundrules:verify-bootstrap` § 2.4 searches every generated file for a **bare** placeholder and
reports one as a **failure**. The plugin therefore already holds the doctrine: a `{{KEY}}` that
survives into a user's file is a defect, not a cosmetic blemish. `/groundrules:vision` states the
matching authoring rule — *"use 'To be defined' where the user skipped — never fabricate"*.

`/groundrules:migrate` could produce that defect. Its Phase 3 said, in one line, *"substitute the
placeholders with `answers`"* — and `answers` is not sufficient, by construction. `bootstrap`
fills the template from several sources: the interview's `answers`, the folder scan (`{{STACK}}`),
the clock (`{{DATE}}`), the global `CLAUDE.md` (`{{GLOBAL_CLAUDE_NOTE}}`), the git remote. A
project bootstrapped by an older version can carry an `answers` object holding little more than
`projectName`, and `migrate` was authorised to read none of the rest.

Two harms followed, and the second is the serious one:

1. **False differences.** An unresolved `{{STACK}}` diffed against the real value the file already
   carries reports a difference that does not exist. A recap padded with them trains the user to
   accept overwrites without reading — which is how the second harm gets triggered.
2. **Silent corruption.** Phase 6 wrote whatever Phase 3 composed. Answering *overwrite with the
   new template* wrote a literal `{{STACK}}` into the user's `CLAUDE.md`, replacing a correct
   value with a broken one, in a file the user did not re-read because a migration had just told
   them it was an update.

Found by a fresh-subagent dry run of `migrate` against a fixture whose state file was deliberately
thin — the discipline recorded in `docs/LEARNINGS.md`. Nothing in the instructions was wrong when
read; the gap was in what they did not say.

## Decision

**1. A bare `{{KEY}}` must never be written into a user's file, by any skill.** The rule is stated
once, here, and enforced at the write site rather than hoped for at the substitution site. The
**backtick rule** of `verify-bootstrap` § 2.4 applies unchanged: a placeholder wrapped in
backticks is a documentation reference, not a leftover.

**2. `migrate` resolves each placeholder through a ladder, first hit wins.**

1. `.groundrules.json` — `answers`, and also `intent` (its fields are what the `VISION`
   placeholders were written from) and the top-level keys.
2. **The file on disk** — the strongest source, and the one `bootstrap` never has: a previous
   generation already substituted these, so the current file *is* the record of the values.
   Recover by anchoring on the template's literal text around the placeholder. **Recover, never
   guess**: text hand-edited past recognition counts as unresolved.
3. Re-derive the non-interactive ones exactly as `bootstrap` does — the clock, the folder's stack
   markers, the global `CLAUDE.md`, the git remote.
4. Unresolved stays unresolved.

**3. Never fabricate, and never ask.** `migrate` is not an interview; adding questions to it would
change what the skill is. A plausible invented `{{DESCRIPTION}}` written into a user's file is
worse than a visible gap, because it looks authored.

**4. Unresolved placeholders are masked on both sides before diffing** — the same marker in the
generated text and in the span it corresponds to on disk, or the line dropped when that span
cannot be located. This removes harm 1 at its source rather than asking the user to see through it.

**5. Second guard — `Overwrite` is never offered on a file the project writes into.** The first
guard sees a broken value; it cannot see a **correct** value being thrown away. `PLAN.md`,
`CHANGELOG.md`, `docs/LEARNINGS.md`, `docs/AGENT-EVALS.md`, `docs/VISION.md`, `intake/INTENT.md`,
`docs/ADOPTION-LOG.md` and everything under `docs/decisions/` are **accumulators**: their whole
value is what the project put in them. A `PLAN.md` holding real tasks, overwritten from its
template, comes back as *(add the first active tasks here)* — and the placeholder guard passes it,
because nothing about it is unresolved. Those files are offered `See the diff` / `Keep my file` /
`Save as .new`, and the missing option is explained rather than silently absent.

This guard exists because testing the first one found it: the same dry run that confirmed the
overwrite refusal on `CLAUDE.md` also watched `PLAN.md` sail through and destroy a real task.
Same principle, one register up — *a migration never damages a file that was correct* — which is
why it is recorded here rather than in an ADR of its own.

**6. The comparison text is what `bootstrap` would generate for this project, not the raw
template.** `bootstrap` drops the sections a global `CLAUDE.md` covers, splices `## Invariants`
only for a scaffolded loop, and drops the superpowers interop when that plugin is absent.
Diffing against the raw template reports every one of those as a difference the user never made,
and a recap padded with false differences is what makes an unsafe answer look routine — the same
harm as the unresolved placeholder, from a different source.

**A section is dropped from the comparison only when the project file lacks it.** When the file
*has* the section, the difference is real and belongs in the arbitration. Dropping it there would
turn *your wording is out of date* into a pure deletion and, for the interop block, would let
`Overwrite` silently remove a section whose removal is a separate question. Answering one question
must never decide the other.

**7. The write paths degrade, each in the way that costs least.**
- **Overwrite** → refused; `<file>.new` is written instead. A migration never damages a file that
  was correct.
- **Save as `.new`** → proceeds, annotated.
- **Create** → skipped. A file that does not exist yet loses nothing by waiting, and creating it
  half-substituted only moves the problem.

In every case the missing values are named, with where they would come from, because `migrate` is
re-runnable by design: fill the state file, run again.

**What is written is always the substituted text, never the masked one.** Masking (decision 4)
serves the comparison only. Writing the masked text would delete the value's line from the user's
file, and — worse — blind the first guard by removing the very tokens it scans for. The two
mechanisms were designed independently and interact badly if this is left unsaid; a dry run
produced both readings, with opposite outcomes.

## Alternatives considered

- **Ask the user for the missing values** — rejected, per decision 3. It turns a mechanical
  migration into an interview, and the answers would belong in `.groundrules.json` anyway, where
  the user can put them and re-run.
- **Substitute an empty string for anything unresolved** — rejected: it silently deletes a correct
  value from the user's file on overwrite, which is the same harm with no visible trace. A bare
  placeholder is at least detectable; an empty string is not.
- **Leave it to `verify-bootstrap`** — rejected. A post-hoc detector is the right complement to a
  guard, never a substitute for one ([ADR 0025](0025-no-runtime-hook-no-watch.md)'s regime is that
  verification is post-hoc *and invoked*; nothing says the tool may create the defect it detects).
  The user would also have to think to run it, after a migration that reported success.
- **Refuse the whole migration when any placeholder is unresolved** — rejected: one missing
  `{{DESCRIPTION}}` would block every other correct update. Degrading per file keeps the rest of
  the migration useful.
- **Treat an accumulator's overwrite as the user's problem** — rejected. They chose `Overwrite` for
  a file, not for its history, and the option was offered to them as if the two were the same.
  Removing the option is honest where a warning would just be one more thing to click past.
- **Make "unresolved" mean any derivation that finds nothing** — rejected: `bootstrap` defines
  `{{STACK}}` as *"stack or empty string"*, so a stack-less project is resolved, not blocked.
  Only placeholders with no defined empty form can be unresolved.

## Consequences

### Positive
- The corruption path is closed at the write site, so it is closed for placeholders that do not
  exist yet, not only for today's list.
- The recap stops carrying false differences, which is what made an unsafe answer look routine.
- Recovering values from the file on disk makes `migrate` work on old projects whose state file
  predates half the placeholder list — the common case it was worst at.
- Accumulator files stop being one careless answer away from losing their history.
- The recap stops reporting sections as differences when the project never had them.

### Negative / Tradeoffs
- Phase 3 is heavier: reading the state file, the file on disk, and re-deriving a few values,
  where it used to do one substitution pass.
- Anchoring on surrounding literal text is heuristic. It is bounded by *recover, never guess*, and
  its failure mode is a masked placeholder and a skipped write — never a wrong value.
- A migration can now end with files deliberately not written. Reported explicitly, with the
  remedy, rather than counted as a success.

### Neutral
- No template changes, no new placeholder, nothing generated differently for a healthy project.

## Notes

- The doctrine this ADR states was already implicit in `/groundrules:verify-bootstrap` § 2.4 and in
  `/groundrules:vision`'s *never fabricate*. Written down because a third skill could violate it.
- Related: [ADR 0002](0002-plain-text-placeholder-substitution.md) (plain-text substitution — the
  reason a placeholder is a literal string that can survive into output),
  [ADR 0003](0003-multi-skill-architecture.md), which already warned that the placeholder list is a
  contract several skills must keep in sync.
