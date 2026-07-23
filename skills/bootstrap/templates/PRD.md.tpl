<!-- generated-by: groundrules v1.10.0 -->
# PRD — {{FEATURE}}

> Product Requirements Document for a single feature. Written **before** building, so the agent
> builds the right thing — not a coherent surprise. Validate it (and answer the open questions)
> before any code. Update it if the scope shifts.

**Date**: {{DATE}} · **Status**: <draft | validated | built>

## Problem

{{PROBLEM}}

## Success criteria

<!-- Where you can, phrase a criterion so it's expressible as an acceptance test — its executable form.
     If this feature will be handed to an autonomous loop (see /groundrules:realize), that pre-written,
     currently-red acceptance test is the loop's back pressure. -->
{{SUCCESS}}

## Scope

**In scope**
{{SCOPE_IN}}

**Out of scope** (explicit)
{{SCOPE_OUT}}

## Constraints

{{CONSTRAINTS}}

## Build plan

Ordered steps, each with a validation point.

{{BUILD_PLAN}}

## Risks

What could go wrong, and the mitigation.

<!-- Populate this adversarially, not optimistically — run a premortem (Gary Klein, HBR 2007): assume
     this shipped and FAILED, indisputably, then list the causes ranked by probability × impact, each
     with the early signal that would have caught it. Reframing "is my plan good?" into "it failed —
     why?" elicits far less sycophancy than asking for validation. (`/groundrules:premortem` runs it.) -->
{{RISKS}}

## Open questions

<!-- Anything still ambiguous — resolve before building. Delete when empty. -->
{{OPEN_QUESTIONS}}
