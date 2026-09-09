<!-- generated-by: groundrules v1.11.0 -->
# Intake / Intent — groundrules

Raw upstream content (paste, email copy, call transcript, PO doc, etc.) describing the project intent.

This file is the **raw source**. The structured synthesis (goal, users, constraints, non-goals, acceptance) lives in `docs/VISION.md`.

---

> Captured retroactively on 2026-05-11 from the first message that kicked off the project (before the intent-capture phase existed in the plugin itself).

> Note: the original prompt was written in French; it has been translated to English (the project is now English-only — cf. ADR 0012). The intent is preserved.

I'd like to create a way to start a Claude Code project as well as possible. So I imagine maybe a slash command? Tell me if that's the right method.

I usually start with this CLAUDE.md found here: https://resources.leadgenman.com/claudemdfile and then I look at how to improve it with this document: https://github.com/shanraisshan/claude-code-best-practice
There are other interesting resources on best practices here: https://howborisusesclaudecode.com/ and https://github.com/0xquinto/bcherny-claude

In addition to a tailored project configuration, I'd also like to standardize a bit what I do:
- Always use GIT
- Optionally use GITLAB or GITHUB to host some projects
- Have a predefined tree to document the project: I want the plan/todo present in my working folder, I want a README.md matching what should be produced on a GIT project (project explanation, how to install, etc.). Maybe a DOCUMENTATION.md if needed. I'd like the decisions we make to be recorded in this tree. Same for the things we've learned. I'd also like a folder containing everything I wrote upfront to describe the project (maybe a tree there too) and to store the files needed for the project. An area for media. Etc.

A friend made this structure:
```
docs/
  00-VISION.md          business context, goals, what's out of V1
  01-ARCHITECTURE.md    stack, environments, structural decisions
  02-DATA_MODEL.md      database schemas, RLS rules
  03-MODULES.md         specs of the 6 V1 modules
  04-I18N.md            bilingual strategy
  05-INTEGRATION.md     field mapping, sync flows
  06-DESIGN_SYSTEM.md   colors, typography, components
  07-SECURITY_GDPR.md   authentication, RLS, compliance
  08-NOTIFICATIONS.md   push and transactional-email matrix
  09-ROADMAP.md         breakdown into deliverable increments
  10-REFERENCE_DATA.md  reference data
  tickets/              one .md file per ticket
```

It looks a bit complex to me, but it's a good system.

I imagine we could start the project either by answering questions you'd ask, or by assembling documentation that would serve as a starting point.
