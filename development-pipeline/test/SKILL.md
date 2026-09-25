---
name: test
description: Create, edit, and delete tests based on a specification and implementation plan.
disable-model-invocation: true
---

Flow: `spec → plan → test → cross-check → implement → review → address-review`. `test` runs before `implement` (test-first) or after it. Stages may be skipped; `spec → plan → implement` is a valid short flow.

## Inputs

A folder containing exactly one file ending with `SPEC.md` and exactly one file ending with `PLAN.md`. Expected location: `specs/<kebab-title>/`.

## Modes

- **Test-first** — the folder contains no `IMPLEMENT.md`. The production change does not exist yet. Do not run tests.
- **Post-implementation** — the folder contains the `IMPLEMENT.md` derived from the spec filename, or I state that the plan is already implemented. Run the tests in step 6.

## Workflow

1. List the folder contents. Identify the files ending with `SPEC.md` and `PLAN.md`. Read the spec and plan in full. The spec defines behavior. The plan defines implementation targets. Select
   the mode. Read the project instructions.
2. Find the project test locations, frameworks, commands, and conventions. Search all test types for the behaviors and identifiers named in the documents. Read matching tests in full. Read
   production files if necessary.
3. Define the test changes following the project test conventions and test types.
    - Cover each spec behavior and Acceptance criterion.
    - Cover each testable plan change and Acceptance criterion.
    - Edit, create, and delete tests as needed.
    - Remove obsolete test imports and references.
4. Identify blockers. Include missing test infrastructure, unclear setup, ambiguous coverage, document conflicts, and uncertain deletions. Ask one question at a time until each blocker is resolved.
   Recommend an answer only when codebase evidence supports it.
5. Apply the test changes.
6. Post-implementation mode only: run the changed tests, then the project's full test suite. Record each result. Do not edit an assertion to match observed output. A failing test stays failing
   and is recorded as `failed`.
7. Write the summary in the spec folder. Replace the trailing `SPEC.md` with `TEST.md`. Overwrite an existing file.
8. Confirm the summary path, the mode, and the counts of created, edited, and deleted test files. In post-implementation mode, also give the counts of passed and failed checks.

## Test discipline

- Derive expected results from the spec and plan, not from current implementation output. Assert observable behavior. Cover relevant boundary and error cases. Mock external dependencies, not the
  behavior under test.
- Run tests only in post-implementation mode. Do not install dependencies or change the environment. Record a check that cannot run without them as `not run`.
- Do not modify production code and build files.
- Modify fixtures, shared test infrastructure, test configuration, or CI configuration only when necessary.
- Do not add tautological tests. Remove existing tautological tests. Each test must verify production behavior against an independent expected result.
- Use version control only for read-only inspection.

## Content rules

- Use short declarative sentences and explicit identifiers.
- Record changes, coverage, and results. Do not include rationale or test source code.
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

## Results

| Check                                         | Command     | Result                    |
|-----------------------------------------------|-------------|---------------------------|
| `<path>::<test_name>` or full test suite      | `<command>` | passed / failed / not run |
```

Omit `Changes` when no test changed. Include `Results` only in post-implementation mode. Do not add other top-level sections.

## Stop conditions

- No folder is provided.
- The folder does not contain exactly one file ending with `SPEC.md` and exactly one file ending with `PLAN.md`.
- The spec or plan is unreadable or empty.
- No test location or infrastructure can be found or provided.
