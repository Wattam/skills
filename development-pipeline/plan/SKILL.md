---
name: plan
description: Turn a specification into an implementation plan.
disable-model-invocation: true
---

# Plan

## Inputs

- A folder path containing a file ending with `SPEC.md`. Expected location: `specs/<kebab-title>/`.

## Workflow

1. **Locate and ingest the spec.** List the folder contents, identify the file ending with `SPEC.md`, and read it in full.
2. **Investigate the codebase.** Open each file the spec's Context names, plus their direct callers, related entities, and tests. Search and read the codebase to extract exact signatures, current line
   targets, and existing patterns to mirror. Record findings to populate the plan's per-step details. Look for **prefactoring opportunities** — existing code worth restructuring first, without
   changing behavior, to make the feature change simpler to apply.
3. **Identify gaps.** Scan the spec and what the investigation surfaced for missing information that would block execution. Treat each of these as a potential gap:
    - **Identifiers** — target files/modules/directories, function/class/endpoint/table/column names, dependencies/libraries/versions not pinned.
    - **Behavior** — input/output shapes, types, schemas, edge cases, error handling, failure modes, side effects (DB writes, network calls, file I/O) not described.
    - **Constraints** — auth, permissions, role requirements not stated.
    - **Verification** — acceptance criteria, migration/rollout/backfill steps not stated.
4. **Ask one question at a time.** Include a recommendation only when evidence supports one; never invent one. Wait for an answer before asking the next; stop when no gaps remain.
5. **Write the plan** to a markdown file inside the same folder as the spec. Filename: replace the trailing `SPEC.md` with `PLAN.md` (e.g. `…-SPEC.md` → `…-PLAN.md`). Overwrite if it exists.
6. **Confirm** with a one-line message naming the file written.

## Plan content rules

- Write in English, optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical flourish.
- Describe **HOW**, never **WHY** — no rationale, no background. If you catch yourself writing "because", "in order to", "so that", or "the reason is", delete that sentence.
- The plan must be **self-contained**: inline every identifier, path, signature, schema, role, and value. Never substitute a reference like "see the spec" for the information itself.
- Use ordered steps; one concrete action per step.
- For each step, include (when applicable):
    - The exact file path
    - The exact symbol (function, class, method, endpoint, table, column)
    - The exact line target (current line number or range)
    - The exact signature, payload shape, or SQL
    - The exact command to run
- If the investigation surfaced a prefactoring opportunity, emit it as Step(s) placed **before** the Steps that add the feature.
- Prefer code blocks and tables over prose.
- No TODOs or `<TBD>` placeholders — every gap must either be answered in step 4 or recorded under `## Open questions` at the bottom.
- Do not create or update test files, and do not add test-writing steps to the plan, unless explicitly asked.

## Plan file structure

```md
# Implementation plan: <short title taken from the spec>

## Context

<one paragraph max — names the system, the entry point, and the artifact being changed. No motivation.>

## Steps

1. <action> — <file:symbol@line> — <signature/payload/SQL/command>
2. ...

## Acceptance criteria

- <check 1>
- <check 2>

## Open questions

<include only if step 4 left gaps unanswered>

- <gap>
```

## Stop conditions

- No folder provided → ask for one, then stop.
- Folder contains no file ending with `SPEC.md` → tell the user, then stop.
- Folder contains multiple files ending with `SPEC.md` → ask which one to use, then wait for their answer.
- Spec is unreadable or empty → tell the user, then stop.
