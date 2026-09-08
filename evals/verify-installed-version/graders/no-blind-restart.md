---
type: regex
pattern: "(restart|relaunch|reload)[^.]{0,80}(claude code|the app|it)"
match: not_contains
target: last_message
flags: "i"
---

A deterministic floor under the judge: the user has already restarted twice and said so, so a
reply whose remedy is *restart* is the recorded failure verbatim.

Deliberately narrow. It matches a restart offered as the **action**, not the word appearing in a
correct explanation — *"a restart reloads the same installed version, which is why it changed
nothing"* is the right answer and does not match, because the pattern requires the verb to govern
the application directly.

If this grader turns out to fire on good answers once the suite can actually run, weaken it rather
than the judge: a false red on a deterministic grader is what teaches people to ignore a suite.
