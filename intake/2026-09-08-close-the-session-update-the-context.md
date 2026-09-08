# Close the session: update the project's context, as a check rather than a reminder

**Written**: 2026-09-08, from a cockpit session. The one idea worth taking from a competitor's
system, recorded on 2026-09-03 as *"the best candidate for adoption of the whole evening"*.

## Why

Every groundrules repository carries a living record of where the work stands — `PLAN.md`,
and in the estate's vault a `_context.md` per project with a *"where it stands"* section. The
rule that keeps them true is written in every `CLAUDE.md`: **keep a doc in sync in the same
change that makes it stale.** It relies on the agent remembering, and it fails on a schedule:

- 2026-09-01 — five project records found stale, corrected by hand.
- 2026-09-04 — the vault said an MCP server was *"not built, no package.json yet"* while it
  was running in production.
- 2026-09-07 — `atlas/PLAN.md` carried a fetch-key item as in-progress a day after the
  release that replaced it.
- 2026-09-08 — the vault's own system context still says *"nothing has run on the server
  yet"*, weeks after the server went live.

Each was found by a human noticing. The estate's standing answer to a failure that repeats is
also in every `CLAUDE.md`: **prefer a check to a reminder.** A reminder relies on attention;
a check does not. This brief asks for the check.

## What to obtain

A command — name it in this repository's own voice; `close` is one candidate — that a session
runs at a checkpoint and that **proposes** the update the living record needs:

- It reads what the session actually changed: the diff since the session opened, the files
  touched, the commits made, the items of `PLAN.md` whose subject those touch.
- It compares that with what the record *says*: `PLAN.md`'s in-progress and open items, and
  where the project has one, the vault's `_context.md` *"where it stands"* section — reached
  through the vault MCP, never a path, using the `repo:` field that already links the two.
- It produces **a proposed edit**, shown to the human as a diff: items to tick, sentences now
  false, the one paragraph to rewrite. The human confirms; the command writes; the commit
  says what the record now states.

The output is a proposal, not a write. *Everything outside the inbox is authored* — somebody
decided it should say what it says — and that somebody is the human.

## The trap, and the steer

**Do not auto-write facts.** A command that rewrites `_context.md` on its own inference is the
stale record with a fresh date on it. It proposes; a person confirms. The value is that the
proposal exists at the moment the knowledge is still in context — not that it is applied
blind.

**Do not match briefs to plan items by name.** The estate already recorded this trap for
atlas: nothing links a brief's filename to a `PLAN.md` line, and a matcher on names cries wolf.
Match on *what changed* — paths, subjects, commits — and let the human resolve the rest.

**The context note is often in another repository.** For estate projects it lives in
`second-brain`, reached through the MCP; the command must not assume the note is beside the
code, and must say clearly when it cannot reach it rather than skip it in silence.

**Keep it cheap enough to run every time.** A close command that costs a minute runs once a
week; one that costs ten seconds runs at every checkpoint. The first is a reminder wearing a
command's name.

## Done when

- Run at the end of a session that changed `PLAN.md`'s subject, it proposes ticking the
  superseded items and rewriting the stale sentence — verified against the four cases above,
  replayed.
- It reaches a `_context.md` in `second-brain` through the MCP and proposes the *"where it
  stands"* edit; when the MCP is unreachable it says so.
- It never writes without a confirmation, and the confirmation is one gesture.
- `CLAUDE.md`'s checkpoint list names it, so the rule fires where it is loaded.

## Where the rest is written

- `second-brain` → `00-inbox/2026-09-03-prismaone-webinar-decision.md` — where the idea was
  weighed, and the pattern named: *a check, not a reminder*.
- `cockpit` → `TODO.md` §7 — the item this brief turns into work.
