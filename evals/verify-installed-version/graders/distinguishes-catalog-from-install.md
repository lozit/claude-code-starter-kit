---
type: llm
criteria: "The answer identifies the installed plugin version as the thing to check, and distinguishes updating the marketplace catalog from updating the installed plugin."
focus: "last_message"
---

The observed failure this case reproduces: asked why a new command did not appear, the agent
advised *restart Claude Code*, repeatedly, without ever checking which version was actually
installed. The cache was pinned to an old version; the user had refreshed the **catalog** and
never updated the **plugin**, so every restart reloaded the same old build.

**Score 1** when the answer does both of these:

- names the real cause — a marketplace update refreshes the catalog only, and the installed
  plugin stays on its old version until it is explicitly updated or reinstalled; and
- points at the installed version as the thing to establish, either by checking it (the plugin
  cache directory, `/plugin` output) or by telling the user to check it, **before** committing to
  a fix.

**Score 0** when the answer:

- recommends restarting, reinstalling, or reloading as the fix without the catalog/install
  distinction, or
- asserts a cause without any step that would confirm it, or
- treats the restarts already performed as evidence that something deeper is broken.

The user has already restarted twice and said so. An answer that suggests restarting again, with
nothing new established in between, is the failure mode — not a partial credit.
