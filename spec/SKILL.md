---
name: spec
description: Turn a natural-language feature or bug-fix request into a tight, LLM-optimized specification written to a markdown file inside a new folder named after the derived kebab-case title in the current working directory. The spec describes WHAT changes and the minimum WHY needed to scope it, never HOW to implement it.
disable-model-invocation: true
---

# Spec

## Inputs

- A natural-language description of a feature or bug fix, provided as:
    - Text in invocation message, or
    - A file path.

## Workflow

1. **Precondition.** If no `CLAUDE.md` exists in the current working directory, tell the user the skill requires project
   context from `CLAUDE.md` and stop.
2. **Classify the request** as **feature** or **bug fix** and pick the template variant (see "Spec file structure"
   below).
3. **Investigate the codebase.** Search and read the codebase to locate the files, symbols, and existing patterns the
   request touches. Record what you find; these populate the spec's Context section without needing a user question.
4. **Derive a short title.** 2–6 words, kebab-case for the filename, Title Case for the document heading. Examples:
   `add-promotion-archive-job` / `Add Promotion Archive Job`, `fix-template-role-check` / `Fix Template Role Check`.
5. **Identify gaps.** Scan the request and what the investigation surfaced for missing information that would block
   writing a useful spec. Treat each of these as a potential gap:
    - Goal not stateable in one sentence (what + why)
    - Scope bullets not listable (2–5 concrete items)
    - Out-of-scope items unclear when the change touches shared code
    - Acceptance criteria not testable (no observable pass/fail)
    - No specific files, modules, or existing patterns to point at in Context
    - No concrete example (input → expected output, or before → after)
    - Edge cases not surfaced (null, empty, unauthorized, oversized, concurrent, …)
    - Constraints/gotchas not stated (auth, perf, ordering, idempotency, side effects)
    - For bug fixes: repro steps missing, expected behavior not stated
6. **Ask one question at a time.**
    - Include a recommendation only when evidence supports one; never invent one.
    - Wait for a answer before asking the next question.
    - Stop when no gaps remain.
7. **Write the spec** to a markdown file inside a new folder. Create a folder in the current working directory whose
   name is the derived kebab-case title, then write the spec inside it as `<kebab-case-title>-SPEC.md` (e.g.
   `add-promotion-archive-job/add-promotion-archive-job-SPEC.md`). If the folder already exists, reuse it; if the target
   file already exists, overwrite it.
8. **Confirm** with a one-line message naming the folder and file written.

## Spec content rules

- Write in English, optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical
  flourish.
- Describe **WHAT** changes and the minimum **WHY** to scope it (one-sentence Goal). Do not describe **HOW**: no
  step-by-step procedures, no chosen algorithms, no file edits, no code. Implementation choices do not belong in a
  spec — delete them. If you catch yourself writing "first do X, then Y" or "add this method" — delete it.
- The spec must be **self-contained**. Every name, path, role, identifier, payload field, or value needed to scope the
  work must appear in the spec. Do not write "see the ticket" or "as discussed" — inline the information.
- Point at specific files in Context. "Look at `service/PromotionService.java` for the existing archive pattern"
  prevents an implementer from inventing a new one.
- Include at least one concrete example. Even for a one-line fix: "input `null` should return `[]` not throw" beats a
  paragraph of description. For features, include one normal case and one edge case.
- Include the **Out of scope** section only when the change touches shared code; omit it for narrowly scoped changes.
- No TODOs or `<TBD>` placeholders — every gap must either be answered in step 6 or recorded under `## Open questions`
  at the bottom.

## Spec file structure

### Feature template

```md
# <Title>

## Goal

<one sentence: what this does and why it matters>

## Scope

- <2–5 bullets of what is in>

## Out of scope

- <what is deliberately untouched>

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

<include only if step 6 left gaps unanswered>

- <gap>
```

### Bug-fix template (swap the top two sections)

```md
# <Title>

## Current behavior

<what happens now, with repro steps if non-obvious>

## Expected behavior

<what should happen>

## Suspected cause

<optional — only if there is a real hypothesis; do not speculate>

## Acceptance criteria

- <testable condition>

## Context

- `path/to/file.ext` — <relevance>

## Examples

<repro input → wrong output (current); same input → right output (expected)>

## Notes

<constraints, gotchas — only if non-obvious>

## Open questions

<include only if step 6 left gaps unanswered>

- <gap>
```

## Stop conditions

- No description provided → ask for one, then stop.
- Description names no target file, symbol, behavior, or user-visible change → ask one clarifying question (what is
  changing and where), then wait for their answer.
- Description is still not actionable after the clarifying question → tell the user, then stop.
- File path supplied is unreadable or empty → tell the user, then stop.
- User declines to answer a gap question → record the gap under `## Open questions` at the bottom of the spec and
  continue.
