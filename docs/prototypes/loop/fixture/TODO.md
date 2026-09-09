<!-- generated-by: groundrules v1.11.0 (prototype fixture) -->
# TODO — slugify fixture

Backlog for the minimal-loop fixture. Tasks are `- [ ]` (ready) / `- [x]` (done). The loop takes the
first ready task each iteration. The repo is the only memory.

## Tasks

- [ ] **Implement `slugify(text) -> str` in `slugify.py`.** Acceptance test: `test_slugify.py`
      (run: `python3 test_slugify.py` → exit 0 = green). Behaviour, exactly:
      1. lowercase the input;
      2. replace every run of whitespace with a single hyphen `-`;
      3. drop every character that is not `a-z`, `0-9`, or `-`;
      4. collapse any run of consecutive hyphens into a single `-`;
      5. strip leading and trailing hyphens.
      Pure function, no I/O, standard library only. `slugify("") == ""`.

- [ ] **Add a `max_length` option to `slugify`.** `slugify(text, max_length=N)` must cap the slug at
      `N` characters. *(This task is deliberately under-specified — it does not say where to cut when a
      slug exceeds `N`. The loop should BLOCK on it, not guess. See `blocked.md.example`.)*
