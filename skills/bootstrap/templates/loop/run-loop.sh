#!/usr/bin/env bash
# generated-by: groundrules v1.8.0
#
# run-loop.sh — the capped runner for the maker/verifier loop (the HIGH-FIDELITY executor).
#
# For a lighter, in-the-box loop on a single self-evident task, Claude Code's `/goal` is an alternative
# (it judges the transcript rather than re-running the oracle) — see loop/README.md "Two ways to run".
#
# Delivery: Claude Code (drives `claude -p` headless). Harness portability is a separate milestone.
#
# Each iteration is TWO fresh agent invocations, never one:
#   1. the maker pass   — loop/LOOP.md   — picks one task, implements it, leaves the work uncommitted
#   2. the verifier pass — loop/verifier.md — judges that diff and commits it, or rejects it
#
# The split is the point. A single invocation doing both passes gives the verifier the maker's
# reasoning for free, and a verifier that remembers writing the code re-confirms its own blind spots.
# The prompts have always demanded a fresh context for the verifier; before this, nothing supplied one.
#
# It repeats until one of:
#   - the maker reports "DONE: backlog empty" (natural stop — the verifier is skipped), or
#   - the hard MAX iteration ceiling is hit (anti-runaway — MANDATORY, not optional).
#
# The model forgets between iterations; the repo remembers. All loop logic lives in the Markdown
# prompts (loop/LOOP.md, loop/maker.md, loop/verifier.md) — this script is the ONLY executable piece.
#
# Usage (run from the project root):
#   bash loop/run-loop.sh [--max N] [--prompt path/to/LOOP.md] [--verifier path/to/verifier.md] [--workdir DIR]
#
# Defaults: --max 5, --prompt <script dir>/LOOP.md, --verifier <script dir>/verifier.md,
# --workdir current directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MAX=5                          # hard ceiling — the anti-runaway safety. There is no "unlimited".
PROMPT="$SCRIPT_DIR/LOOP.md"
VERIFIER="$SCRIPT_DIR/verifier.md"
WORKDIR="$(pwd)"
DONE_MARKER="DONE: backlog empty"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --max)     MAX="$2"; shift 2 ;;
    --prompt)  PROMPT="$2"; shift 2 ;;
    --verifier) VERIFIER="$2"; shift 2 ;;
    --workdir) WORKDIR="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# Guard the cap: must be a positive integer, and refuse an absurd ceiling that defeats the purpose.
if ! [[ "$MAX" =~ ^[0-9]+$ ]] || [[ "$MAX" -lt 1 ]]; then
  echo "error: --max must be a positive integer (got '$MAX')" >&2; exit 2
fi
if [[ "$MAX" -gt 50 ]]; then
  echo "error: --max $MAX exceeds the sanity ceiling of 50 (this is anti-runaway, on purpose)" >&2
  exit 2
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "error: 'claude' CLI not found on PATH — this runner drives 'claude -p' headless." >&2
  exit 127
fi

cd "$WORKDIR"
echo "loop: workdir=$WORKDIR  prompt=$PROMPT  max=$MAX"

for (( i=1; i<=MAX; i++ )); do
  echo "──────── iteration $i / $MAX ────────"

  # --- Maker pass: a FRESH headless invocation. No carried context; state read from disk.
  # `|| true` so a non-zero exit doesn't kill the loop before we inspect the output.
  echo "── maker pass"
  out="$(claude -p "$(cat "$PROMPT")" 2>&1 || true)"
  printf '%s\n' "$out"

  # The backlog emptied: stop before spending a verifier invocation on nothing.
  if printf '%s' "$out" | grep -qF "$DONE_MARKER"; then
    echo "loop: natural stop — '$DONE_MARKER' at iteration $i."
    exit 0
  fi

  # --- Verifier pass: a SECOND fresh invocation, and that is the whole point.
  # It is handed nothing from the maker's turn — not this variable, not the transcript. It re-derives
  # the task, the acceptance test and the diff from disk, judges them, and commits or rejects.
  echo "── verifier pass"
  vout="$(claude -p "$(cat "$VERIFIER")" 2>&1 || true)"
  printf '%s\n' "$vout"
done

echo "loop: hit MAX=$MAX without an empty backlog. Stopping (anti-runaway)."
echo "loop: inspect loop/backlog.md (unchecked tasks) and loop/blocked.md (parked decisions)."
exit 0
