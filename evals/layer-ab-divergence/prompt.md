---
name: "Layer A/B divergence — does the agent know which copy ships?"
tags: ["agent-evals", "layers"]
runs: 3
max_turns: 12
allowed_tools: ["Bash", "Read", "Grep", "Glob"]
---

This repository keeps two copies of the autonomous loop's prompts.

Read the loop's **verifier** prompt and tell me, in your answer:

1. What the verifier is handed when it checks a task, and what it is explicitly told **not** to receive.
2. Whether the instruction is stated the same way in every copy of the verifier prompt in this repository, and if not, which copy governs the behaviour a user of this plugin actually gets.

Do not edit anything. Answer in prose.
