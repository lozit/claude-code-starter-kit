<!-- generated-by: groundrules v1.10.0 -->
# 0031 — `/goal` interop: the loop executor is swappable; reposition `run-loop.sh` as fallback

**Date**: 2026-06-15
**Status**: Accepted (2026-06-17)

## Context

M1 (v1.6.0) shipped loop scaffolding whose **executor** is `loop/run-loop.sh` — a shell runner that
drives `claude -p` headless, one fresh agent per iteration, with a mandatory `MAX` cap.

Claude Code has since shipped **`/goal`** (GA; present in the local 2.1.177). Verified behaviour
(official docs + local `changelog.md`): you set a natural-language **completion condition**; Claude keeps
working **across turns** without re-prompting; after each turn a **separate small evaluator model**
(Haiku by default) judges whether the condition holds **from the conversation transcript** and, if not,
its reason guides the next turn; the goal clears when met. It is a **wrapper around a Stop hook**, works
in interactive / `-p` / Remote Control. Key traits that bear on us:

- **Context accumulates** (one growing transcript) — *not* fresh-context-per-iteration.
- The **evaluator reads the transcript, not the files** — it does not independently re-run the test or
  re-derive from the diff; it trusts what the transcript shows.
- **No hard cap** — only what you encode in the condition; a vague condition can loop indefinitely.
- **Ephemeral state** — the condition survives `--resume` but counters reset; nothing durable on disk.

`/goal` overlaps `run-loop.sh`. The question this ADR settles: **compete, or interoperate?**

## Decision

**Treat the loop *executor* as swappable** (the direct application of [ADR 0027](0027-reflection-realization-interactive-loop.md) §2 — "the executor is swappable"). `/goal` is a first-class executor **alongside** our shell runner, not a competitor.

1. **groundrules owns the *reflection*, not the runner.** Our durable value is the partitioned backlog
   (`/groundrules:realize`), the **pre-written red acceptance test** (the TDD gate), the `## Invariants`,
   the `blocked.md` backward-crossing, and the ADR/LEARNINGS memory — *the comprehension-debt antidote*.
   These make any loop runner **trustworthy**; the runner itself is a commodity.
2. **Choose the executor by stakes — two fidelity levels, not one "preferred".**
   - **`/goal` = the light, low-ceremony loop.** Best for a *simple, transcript-verifiable* goal
     (`/goal "go test ./... exits 0"`): one accumulating session judged by the Haiku evaluator. Quick,
     in-the-box, no setup.
   - **The groundrules loop (`run-loop.sh` + the `maker.md`/`verifier.md`/`LOOP.md` prompts) =
     the high-fidelity loop.** Fresh context per iteration; the verifier **re-runs the oracle and
     re-derives from the diff** (catches plausible-but-wrong work a transcript-judge misses); a real
     decision is **parked in `blocked.md`** instead of guessed. Reach for it when you want the strong
     back pressure, not just a green transcript.
   - In both cases **groundrules writes the goal** (the pre-written red acceptance test, the partitioned
     backlog, the invariants); only the *runner* differs.
3. **`run-loop.sh` is not "just a fallback" — distinguish the *script* from the *system*.** The script
   is a commodity `while`-loop (bare, `/goal` beats it as a raw runner), **but it is the carrier of the
   high-fidelity contract** — the completeness lives in the prompts it replays, not the script. Its
   audience after `/goal`: (a) **high-fidelity loops** on Claude Code (the guarantees `/goal` doesn't
   give); (b) **harnesses without `/goal`** (M2: Cursor, Codex, Gemini…); (c) **fully-scripted /
   unattended** runs.
4. **Keep our verification discipline even when deferring.** Because `/goal`'s evaluator judges the
   *transcript* (not an independent re-run), the condition must be a **binary command the maker actually
   runs**; ideally our independent verifier still runs as a **final gate before commit**. (A known
   limitation, not papered over — see Consequences.)
5. **Don't adopt `/goal`'s accumulating-context model** into our thesis. Fresh-context-per-iteration +
   "the repo remembers" stays groundrules' position (ADR 0020/0027, context-rot evidence); `/goal` is
   *offered* as an executor with the tradeoff stated honestly.

## Alternatives considered

- **Compete — keep `run-loop.sh` as *the* driver, ignore `/goal`.** Rejected: `/goal` is in-the-box, GA,
  better integrated (overlay, resume, evaluator); maintaining an inferior parallel runner and steering
  users away from the native tool is a losing, confusing position.
- **Depend on `/goal` — drop `run-loop.sh`.** Rejected: breaks harness-neutrality (the whole reason the
  repo is named *groundrules*; M2 targets non-Claude-Code harnesses with no `/goal`) and the scriptable
  fallback; also a runtime dependency we'd rather not hard-require (ADR 0002/0025 spirit).
- **Wrap `/goal` inside `run-loop.sh`.** Rejected *for now*: unnecessary coupling — the interop is a
  usage/doc concern (emit a `/goal`-ready condition, document the `/goal` path), not new code. Revisit if
  a concrete need appears.

## Consequences

### Positive
- A clean, honest interop story: **the executor is swappable**, `/goal` is the in-the-box one, our runner
  is the portable fallback. groundrules is positioned as *what makes a loop runner trustworthy* — it
  writes the goal, decides what is loop-safe, and remembers the why.
- No code required now; positioning + a usage note. The reflection layer (the real moat) is unaffected.

### Negative / Tradeoffs
- **`run-loop.sh`'s audience narrows, but it is not redundant.** For *simple* loops, Claude Code users
  will reach for `/goal` and won't need it. Its remaining real value is the **high-fidelity** loop (the
  guarantees `/goal` doesn't give), other harnesses, and scripted runs. (An earlier framing of the runner
  as "largely redundant" was too strong — corrected here: the *script* is commodity, the *system* it
  carries is not.)
- **`/goal` alone is *less complete* than the full groundrules loop** — its evaluator trusts the
  transcript (no independent re-run of the oracle, no re-derivation from the diff), it accumulates
  context, and it has no decision-parking. Mitigation (decision §4): make the condition a binary command
  and optionally keep our verifier as a final gate. A real gap to keep in view, not solved — and the
  reason the two-fidelity-level framing (§2) matters.
- **A held tension, not resolved**: `/goal` accumulates context; we preach fresh context. Both are valid
  for different work; we don't pretend ours is universally better.

### Neutral
- Implementation is **deferred to a PRD** when built — this ADR only settles positioning. That PRD's
  scope will include: `realize` emitting a `/goal`-ready condition; a `/goal` interop note in the
  generated `loop/README.md` (mirroring the superpowers defer note); and **explaining the two fidelity
  levels in the project `README.md`** (when to reach for `/goal` vs the full groundrules loop, and why
  `/goal` alone is lighter — the user-facing version of §2).

## Notes

- Sources: official `/goal` docs; local `~/.claude/cache/changelog.md` (l.737 "Added `/goal`…", + evaluator
  / hooks fixes) on Claude Code 2.1.177. Architecture-level facts corroborated; exact intro version not
  load-bearing here.
- Parent decision: [ADR 0027](0027-reflection-realization-interactive-loop.md) (reflection vs realization;
  executor swappable). Precedent pattern: the **superpowers defer** (groundrules contributes the layers a
  loop pipeline lacks, rather than re-building the pipeline).
- Spun from a 2026-06-15 analysis of `/goal` in the groundrules perspective.
