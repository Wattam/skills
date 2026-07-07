---
name: spec
description: Turn a natural-language feature/bug-fix request into a specification file.
disable-model-invocation: true
---

## Inputs

A natural-language description of a feature or bug fix, provided as text and/or as a file path.

## Workflow

1. **Classify the request** as **feature** or **bug fix** and pick the template variant (see "File structure" below).
2. **Investigate the codebase.** Search and read the codebase to locate the files, symbols, and existing patterns relevant to the request.
3. **Derive a short title** in kebab-case for the filename. Example: `add-promotion-archive-job`.
4. **Identify gaps.** Scan the request and what the investigation surfaced for missing information that would block writing a useful spec. Treat each of these as a potential gap:
    - Acceptance criteria not testable (no observable pass/fail)
    - No specific files, modules, or existing patterns to point at in Context
    - No concrete example (input → output, before → after)
    - Edge cases not surfaced (null, empty, unauthorized, oversized, concurrent, …)
    - Constraints/gotchas not stated (auth, perf, ordering, idempotency, side effects)
    - Feature:
        - Scope bullets not listable (2–5 concrete items)
        - Out-of-scope items unclear (behavior that must not change)
    - Bug fix:
        - Current behavior not stated
        - Expected-behavior bullets not listable (each a discrete observable behavior that should happen instead)
        - Reproduction steps missing when the behavior is non-obvious
5. **Interview me about every gap.** One question at a time, until none remain. Include a recommendation for a gap when evidence supports one; never invent one.
6. **Write the spec.** Create a folder named `specs/` in the current working directory (if it does not already exist), then create a subfolder inside of it whose name is the derived kebab-case title.
   Write the spec inside that subfolder as `<kebab-case-title>-SPEC.md` (e.g. `specs/add-promotion-archive-job/add-promotion-archive-job-SPEC.md`). If the subfolder already exists, reuse it; if the
   target file already exists, overwrite it.
7. **Confirm** with a one-line message naming the folder and file written.

## Content rules

- Optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical flourish.
- Describe **WHAT** changes and **WHY** to scope it. Do not describe **HOW**.
- The spec must be **self-contained**. Everything needed to scope the work must appear in the spec. Do not write "see the ticket" or "as discussed"; inline the information.
- Point at specific files in Context. Example: "Look at `service/PromotionService.java` for the existing archive pattern".
- No TODOs or `<TBD>` placeholders — every gap must be answered in step 5.

## File structure

### Feature template

```md
# <Title>

## Goal

<what this does and why it matters>

## Scope

- <2–5 bullets of what is in>

## Out of scope

- <what is deliberately untouched; omit this section if no behavior is at risk>

## Acceptance criteria

- <testable condition>
- <testable condition>

## Context

- `path/to/file.ext` — <what it is / why it is relevant>
- Existing pattern to follow: <short description or `path/to/file.ext:symbol`>

## Examples

<input → expected output, or before → after; ≥1 normal case + 1 edge case>

## Notes

<constraints, gotchas, things not to assume — only if non-obvious>
```

### Bug-fix template

Identical to the feature template, except: `## Goal` and `## Scope` are replaced by the three sections below.
`## Examples` placeholder becomes `<input that reproduces the bug → wrong output (current); same input → right output (expected)>`.

```md
## Current behavior

<what happens now, with reproduction steps if non-obvious>

## Expected behavior

- <2–5 bullets, each one observable behavior that should happen instead; one bullet per discrete behavior so downstream stages can map, test, and review them individually>

## Suspected cause

<optional — only if there is a real hypothesis; do not speculate>
```

## Stop conditions

- No description provided.
- Description names no target file, symbol, behavior, or user-visible change.
- Description is still not actionable after the clarifying question.
- File path supplied is unreadable or empty.
