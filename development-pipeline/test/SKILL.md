---
name: test
description: Create, edit, and delete tests based on a specification and implementation plan.
disable-model-invocation: true
---

Flow: `spec → plan → test → cross-check → implement → review-code → adress-review`.

## Input

A folder containing exactly one file ending with `SPEC.md` and exactly one file ending with `PLAN.md`. Expected location: `specs/<kebab-title>/`.

## Workflow

1. List the folder contents. Identify the files ending with `SPEC.md` and `PLAN.md`. Read the spec and plan in full. The spec defines behavior. The plan defines implementation targets.
2. Find the project test locations, frameworks, commands, and conventions. Search all test types for the behaviors and identifiers named in the documents. Read matching tests in full. Read production files if necessary.
3. Define the test changes following the project test conventions and test types.
    - Cover each spec behavior and Acceptance criterion.
    - Cover each testable plan change and Acceptance criterion.
    - Edit, create, and delete tests as needed.
    - Remove obsolete test imports and references.
4. Identify blockers. Include missing test infrastructure, unclear setup, ambiguous coverage, document conflicts, and uncertain deletions. Ask one question at a time until each blocker is resolved. Recommend an answer only when codebase evidence supports it.
5. Apply the test changes. 
6. Write the summary in the spec folder. Replace the trailing `SPEC.md` with `TEST.md`. Overwrite an existing file.
7. Confirm the summary path and the counts of created, edited, and deleted test files.

## Rules

- Derive expected results from the spec and plan, not from current implementation output. Assert observable behavior. Cover relevant boundary and error cases. Mock external dependencies, not the behavior under test.
- Do not run tests, install dependencies, or execute project code.
- Do not modify production code and build files.
- Modify fixtures, shared test infrastructure, test configuration, or CI configuration only when necessary.
- Do not add tautological tests. Remove existing tautological tests. Each test must verify production behavior against an independent expected result.
- Use short declarative sentences and explicit identifiers.
- Record changes and coverage. Do not include rationale or test source code.
- Make the summary self-contained. Include test paths, names, types, commands, and assertion focus.
- Do not add TODOs or `<TBD>` placeholders.

## Summary format

```md
# Test: <title from the spec>

## Setup

| Test type | Location | Framework / runner   | Command     |
|-----------|----------|----------------------|-------------|
| <type>    | `<path>` | <framework / runner> | `<command>` |

## Changes

| Action                     | File or test                      | Test type | Assertion focus     |
|----------------------------|-----------------------------------|-----------|---------------------|
| created / edited / deleted | `<path>` or `<path>::<test_name>` | <type>    | <observable result> |

## Coverage

| Source requirement                                   | Covered by            |
|------------------------------------------------------|-----------------------|
| <exact spec or plan location and quoted requirement> | `<path>::<test_name>` |
```

Omit `Changes` when no test changed. Do not add other top-level sections.

## Stop conditions

- No folder is provided.
- The folder does not contain exactly one file ending with `SPEC.md` and exactly one file ending with `PLAN.md`.
- The spec or plan is unreadable or empty.
- No test location or infrastructure can be found or provided.
