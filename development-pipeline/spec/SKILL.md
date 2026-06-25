---
name: spec
description: Turn a natural-language feature/bug-fix request into a specification file.
disable-model-invocation: true
---

# Spec

## Inputs

- A natural-language description of a feature or bug fix, provided as:
    - Text in invocation message, or
    - A file path.

## Workflow

1. **Classify the request** as **feature** or **bug fix** and pick the template variant (see "File structure"
   below).
2. **Investigate the codebase.** Search and read the codebase to locate the files, symbols, and existing patterns the
   request touches. Record what you find.
3. **Derive a short title.** 2–6 words, kebab-case for the filename, Title Case for the document heading. Examples:
   `add-promotion-archive-job` / `Add Promotion Archive Job`, `fix-template-role-check` / `Fix Template Role Check`.
4. **Identify gaps.** Scan the request and what the investigation surfaced for missing information that would block
   writing a useful spec. Treat each of these as a potential gap:
    - Acceptance criteria not testable (no observable pass/fail)
    - No specific files, modules, or existing patterns to point at in Context
    - No concrete example (input → output, before → after)
    - Edge cases not surfaced (null, empty, unauthorized, oversized, concurrent, …)
    - Constraints/gotchas not stated (auth, perf, ordering, idempotency, side effects)
    - Feature:
        - Goal not stateable in one sentence (what + why)
        - Scope bullets not listable (2–5 concrete items)
        - Out-of-scope items unclear (behavior that must not change)
    - Bug fix:
        - Current behavior not stated
        - Expected behavior not stated
        - Repro steps missing when the behavior is non-obvious
5. **Ask one question at a time.** Include a recommendation only when evidence supports one; never invent one. Wait for
   an answer before asking the next; stop when no gaps remain.
6. **Write the spec.** Create a folder named `specs/` in the current working directory if it does not already exist,
   then create a subfolder inside `specs/` whose name is the derived kebab-case title. Write the spec inside that
   subfolder as `<kebab-case-title>-SPEC.md` (e.g. `specs/add-promotion-archive-job/add-promotion-archive-job-SPEC.md`).
   If the subfolder already exists, reuse it; if the target file already exists, overwrite it.
7. **Confirm** with a one-line message naming the folder and file written.

## Content rules

- Write in English, optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical
  flourish.
- Describe **WHAT** changes and the minimum **WHY** to scope it (one-sentence Goal). Do not describe **HOW**: no
  step-by-step procedures, no chosen algorithms, no file edits, no code.
- The spec must be **self-contained**. Every name, path, role, identifier, payload field, or value needed to scope the
  work must appear in the spec. Do not write "see the ticket" or "as discussed" — inline the information.
- Point at specific files in Context. "Look at `service/PromotionService.java` for the existing archive pattern"
  prevents an implementer from inventing a new one.
- No TODOs or `<TBD>` placeholders — every gap must either be answered in step 5 or recorded under `## Open questions`
  at the bottom.

## File structure

### Feature template

```md
# <Title>

## Goal

<one sentence: what this does and why it matters>

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

## Open questions

<include only if step 5 left gaps unanswered>

- <gap>
```

### Bug-fix template

Identical to the feature template, except: `## Goal`, `## Scope`, and `## Out of scope` are replaced by the three
sections below, and the `## Examples` placeholder becomes
`<repro input → wrong output (current); same input → right output (expected)>`.

```md
## Current behavior

<what happens now, with repro steps if non-obvious>

## Expected behavior

<what should happen>

## Suspected cause

<optional — only if there is a real hypothesis; do not speculate>
```

## Stop conditions

- No description provided → ask for one, then stop.
- Description names no target file, symbol, behavior, or user-visible change → ask one clarifying question (what is
  changing and where), then wait for their answer.
- Description is still not actionable after the clarifying question → tell the user, then stop.
- File path supplied is unreadable or empty → tell the user, then stop.
- User declines to answer a gap question → record it under `## Open questions` and continue.
