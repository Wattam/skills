---
name: plan
description: Turn a specification into an implementation plan.
disable-model-invocation: true
---

## Inputs

A folder path containing a file ending with `SPEC.md`. Expected location: `specs/<kebab-title>/`.

## Workflow

1. **Locate and ingest the spec.** List the folder contents, identify the file ending with `SPEC.md`, and read it in full.
2. **Investigate the codebase.** Open each file the spec's Context names, plus their direct callers, related entities, and tests. Extract exact signatures, current line targets, and existing
   patterns to mirror. Look for **prefactoring opportunities** — existing code worth restructuring first, without changing behavior, to make the feature change simpler to apply.
3. **Identify gaps.** Scan the spec and what the investigation surfaced for missing information that would block execution. Treat each of these as a potential gap:
    - **Identifiers** — target files/modules/directories, function/class/endpoint/table/column names, dependencies/libraries/versions not pinned.
    - **Behavior** — input/output shapes, types, schemas, edge cases, error handling, failure modes, side effects (DB writes, network calls, file I/O) not described.
    - **Constraints** — auth, permissions, role requirements not stated.
    - **Verification** — acceptance criteria, migration/rollout/backfill steps not stated.
4. **Interview me about every gap.** One question at a time, until none remain. Include a recommendation for a gap when evidence supports one; never invent one.
5. **Write the plan** to a markdown file inside the same folder as the spec. Filename: replace the trailing `SPEC.md` with `PLAN.md`. Overwrite if it exists.
6. **Confirm** with a one-line message naming the file written.

## Content rules

- Optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical flourish.
- Describe **HOW**, never **WHY** — no rationale, no background.
- The plan must be **self-contained**: inline every identifier, path, signature, schema, role, and value. Never substitute a reference like "see the spec" for the information itself.
- Use ordered steps; one concrete action per step.
- For each step, include when applicable: the exact file path, the exact symbol, the exact line target, the exact signature/payload/SQL, and the exact command to run.
- Place prefactoring Steps **before** the Steps that add the feature.
- Prefer code blocks and tables over prose.
- No TODOs or `<TBD>` placeholders — every gap must be answered in step 4.
- Do not create or update test files, and do not add test-writing steps to the plan, unless explicitly asked.

## File structure

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
```

## Stop conditions

- No folder provided.
- Folder contains no file ending with `SPEC.md`, or contains multiple.
- Spec is unreadable or empty.
