#!/usr/bin/env bash
# generated-by: groundrules v1.8.0
#
# validate-runner.sh — the DETERMINISTIC layer of the loop validation suite.
#
# It proves the only executable piece of the loop — run-loop.sh — is safe, WITHOUT an LLM:
# a stub `claude` on PATH emits scripted output, so we can assert the anti-runaway MAX cap, the
# DONE stop, and one-fresh-invocation-per-iteration with exact, repeatable results (zero tokens).
#
# The behavioural layer (does the maker/verifier prompt logic actually converge / reject / block?)
# is LLM-driven and lives in WALKTHROUGH.md (subagent-simulated or a live `claude -p` run).
#
# Usage:  bash test/loop/validate-runner.sh [path/to/run-loop.sh]
# Default runner: the shipped template (skills/bootstrap/templates/loop/run-loop.sh).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RUNNER="${1:-$REPO_ROOT/skills/bootstrap/templates/loop/run-loop.sh}"

pass=0; fail=0
ok()   { echo "  ✅ $1"; pass=$((pass+1)); }
bad()  { echo "  ❌ $1"; fail=$((fail+1)); }

if [[ ! -f "$RUNNER" ]]; then echo "runner not found: $RUNNER" >&2; exit 2; fi
echo "validate-runner: testing $RUNNER"

# --- a sandbox with a stub `claude` on PATH ---------------------------------
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/bin" "$WORK/proj/loop"
cp "$RUNNER" "$WORK/proj/loop/run-loop.sh"
echo "# fixed per-iteration prompt (content irrelevant to the runner test)" > "$WORK/proj/loop/LOOP.md"
echo "# verifier prompt (content irrelevant to the runner test)" > "$WORK/proj/loop/verifier.md"

# Stub: ignores args, prints $STUB_OUT, and appends a line to $WORK/calls each invocation.
# Since v1.12 an iteration is TWO invocations — maker then verifier — so the call count is what
# proves the split actually happens rather than being merely asked for in the prompts.
cat > "$WORK/bin/claude" <<EOF
#!/usr/bin/env bash
echo "call" >> "$WORK/calls"
printf '%s\n' "\${STUB_OUT:-STATUS: working, not done}"
EOF
chmod +x "$WORK/bin/claude"
export PATH="$WORK/bin:$PATH"

run() { ( cd "$WORK/proj" && : > "$WORK/calls"; "$@" ); }   # reset call counter, run from project root
calls() { wc -l < "$WORK/calls" | tr -d ' '; }

# --- Test 1: MAX cap bounds a never-DONE loop -------------------------------
echo "[1] MAX cap stops a never-DONE loop at exactly --max iterations, two invocations each"
out="$(STUB_OUT='STATUS: still working' run bash loop/run-loop.sh --max 3 2>&1)"; rc=$?
n="$(calls)"
[[ "$n" == "6" ]] && ok "ran 3 iterations as 6 invocations — maker + verifier each (got $n)" \
  || bad "expected 6 invocations for 3 iterations, got $n"
[[ "$(grep -c '── maker pass' <<<"$out")" == "3" ]] && ok "3 maker passes" || bad "expected 3 maker passes"
[[ "$(grep -c '── verifier pass' <<<"$out")" == "3" ]] && ok "3 verifier passes" || bad "expected 3 verifier passes"
grep -q 'hit MAX=3' <<<"$out" && ok "printed the anti-runaway stop message" || bad "missing 'hit MAX' message"
[[ "$rc" == "0" ]] && ok "exited 0 after the cap" || bad "expected exit 0, got $rc"

# --- Test 2: DONE marker stops early ----------------------------------------
echo "[2] 'DONE: backlog empty' stops the loop early"
out="$(STUB_OUT='DONE: backlog empty' run bash loop/run-loop.sh --max 5 2>&1)"; rc=$?
n="$(calls)"
[[ "$n" == "1" ]] && ok "stopped after the maker pass alone (got $n)" || bad "expected 1 invocation, got $n"
grep -q 'natural stop' <<<"$out" && ok "printed the natural-stop message" || bad "missing 'natural stop' message"
grep -q '── verifier pass' <<<"$out" && bad "ran a verifier pass on an empty backlog" \
  || ok "skipped the verifier pass — nothing to verify"

# --- Test 3: the cap is guarded (invalid / absurd values rejected) ----------
echo "[3] the MAX guard rejects invalid and absurd ceilings"
run bash loop/run-loop.sh --max 0  >/dev/null 2>&1; [[ $? == 2 ]] && ok "--max 0 rejected (exit 2)"  || bad "--max 0 not rejected"
run bash loop/run-loop.sh --max 99 >/dev/null 2>&1; [[ $? == 2 ]] && ok "--max 99 rejected (> 50 sanity ceiling)" || bad "--max 99 not rejected"
run bash loop/run-loop.sh --max abc >/dev/null 2>&1; [[ $? == 2 ]] && ok "--max abc rejected (non-integer)" || bad "--max abc not rejected"

# --- Test 4: a missing `claude` CLI is detected -----------------------------
echo "[4] a missing 'claude' on PATH is reported (exit 127)"
( cd "$WORK/proj" && PATH="/usr/bin:/bin" bash loop/run-loop.sh --max 2 >/dev/null 2>&1 ); \
  [[ $? == 127 ]] && ok "exits 127 when claude is absent" || bad "did not exit 127 without claude"

# --- Test 5: template sanity (the cap exists in source — not a tautology) ---
echo "[5] the runner source actually contains the cap guard"
grep -q 'sanity ceiling of 50\|exceeds the sanity ceiling' "$RUNNER" && ok "source has the >50 sanity ceiling" || bad "source missing the sanity ceiling guard"
grep -q 'i<=MAX' "$RUNNER" && ok "source bounds the loop by MAX" || bad "source loop is not bounded by MAX"

echo "─────────────────────────"
echo "validate-runner: $pass passed, $fail failed"
[[ "$fail" == "0" ]] || exit 1
