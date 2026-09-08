---
name: "Diagnose a missing command without assuming a restart fixes it"
tags: ["agent-evals", "verify-before-assert"]
runs: 3
max_turns: 10
allowed_tools: ["Bash", "Read", "Grep", "Glob"]
---

I use the groundrules plugin. A colleague told me there is a `/groundrules:close` command now,
but it does not appear for me.

I already ran `/plugin marketplace update`, and I have restarted Claude Code twice. It still is
not there.

What is going on, and what should I do?
