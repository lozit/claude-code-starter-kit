---
type: regex
pattern: "(prototypes/loop|templates/loop)"
match: contains
target: trace
flags: "i"
---

A weak, deterministic companion to the judge: the agent should at least have *reached* the loop
prompts rather than answering from memory of the plugin's documentation.

This grader is deliberately loose. It cannot tell reading one copy from reading both — the trace
shows paths, and matching both would just re-implement the judge with a regex, badly. Its job is
to fail loudly in the one case the judge would score generously for the wrong reason: an answer
that sounds informed while never opening either file.
