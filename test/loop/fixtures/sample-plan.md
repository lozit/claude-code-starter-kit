<!-- generated-by: groundrules v1.10.0 (loop walkthrough fixture) -->
# Sample approved plan — feed this to `/groundrules:realize`

A deliberately **mixed** plan so the walkthrough shows `realize` partitioning correctly. Paste this (or
its tasks) when `realize` asks for the source.

1. Implement `slugify(text)` in `widgetkit/text.py` — lowercase, replace whitespace runs with `-`, drop
   any char not in `[a-z0-9-]`, collapse hyphen runs, strip leading/trailing hyphens.
   Acceptance test: `python3 test/test_slugify.py` (exit 0 = green). **A red acceptance test already
   exists** (`test/test_slugify.py`) → this is `[loop]`-eligible.
2. Implement `truncate(s, n)` in `widgetkit/text.py` — cap a string at `n` characters. *(No acceptance
   test, and "where to cut" is unspecified — expect `[supervised]`: a hidden decision + no red test.)*
3. Decide and implement the caching strategy for the renderer (in-memory vs Redis vs none).
   *(Embedded decision → expect `[supervised]`.)*

Expected partition: **task 1 → `[loop]`** (red behavioural test present, writer ≠ maker); **tasks 2 & 3
→ `[supervised]`** (2 = no red test + hidden truncation decision; 3 = embedded decision).
