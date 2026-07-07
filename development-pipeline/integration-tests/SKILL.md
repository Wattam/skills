---
name: integration-tests
description: Create, edit, and delete integration tests in the codebase based on a specification.
disable-model-invocation: true
---

## Inputs

A folder path containing a file ending with `SPEC.md`. Expected location: `specs/<kebab-title>/`.

## Workflow

1. **Locate and ingest the spec.** List the folder contents, identify the file ending with `SPEC.md`, and read it in full. Treat Scope (feature spec) or Current behavior + Expected behavior (bug-fix
   spec), together with Acceptance criteria, Context, and Examples, as the binding source of behaviors to cover.
2. **Localize integration tests.** Find the integration test root (e.g. `tests/integration/`, `src/test/java/.../it/`, `e2e/`). For every file, symbol, endpoint, table, or column named in the spec's
   Context, search the integration test root for direct references and read each matching test file in full. Read the files the spec's Context names only to confirm signatures and payload shapes.
3. **Build the change set.** For each Scope item (feature spec) or Expected-behavior bullet (bug-fix spec), and for each Acceptance criterion:
    - An existing integration test exercises the same symbol, endpoint, or behavior → **EDIT** (record file path and the assertions/scenarios to add, change, or remove).
    - No integration test covers the item → **CREATE** (record the new file path and the assertions/scenarios to add).
    - Spec removes a behavior, endpoint, or symbol an integration test still exercises → **DELETE** (record file path, or specific test names if the file still covers in-scope behavior).
4. **Identify gaps.** Scan the spec and the localization output for missing information that would block writing or modifying tests. Treat each of these as a potential gap:
    - **Test infrastructure** — integration test root, framework, runner, or invocation command not discoverable from the codebase.
    - **Naming and layout** — new test file naming convention, package/module path for new files.
    - **Fixtures and setup** — DB seeding, test data builders, auth/session setup, environment variables, or mocked external services not understood.
    - **Coverage decisions** — ambiguous whether an item warrants a new file, an edit, or both; multiple existing tests look applicable; an Acceptance criterion has no clear test target.
    - **Deletion confirmation** — an existing test appears obsolete but the spec does not explicitly mark its target as removed.
5. **Interview me about every gap.** One question at a time, until none remain. Include a recommendation for a gap when evidence supports one; never invent one.
6. **Apply the change set.**
    - **CREATE**: write the new test file at the recorded path. Mirror the framework, imports, naming, fixtures, and helpers used by the nearest existing integration test.
    - **EDIT**: change only the recorded assertions/scenarios.
    - **DELETE**: remove the recorded file, or only the recorded test functions.
7. **Write the summary** to a markdown file inside the same folder as the spec. Filename: replace the trailing `SPEC.md` with `INTEGRATION-TESTS.md`. Overwrite if it exists.
8. **Confirm** with a one-line message naming the summary file written and the counts of test files created, edited, and deleted.

## Content rules

- Optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical flourish.
- The summary is a **record of test changes**, not a plan or rationale. Do not describe WHY a test was added.
- The summary must be **self-contained**. Inline every test file path, test name, framework, and assertion focus; never substitute a reference like "see the spec" for the information itself.
- Do not include test source code in the summary.
- No TODOs or `<TBD>` placeholders — every gap must be answered in step 5.

## Investigation discipline

- Do not run tests, install dependencies, or trigger any code execution.
- Do not modify production code, fixtures, helpers, build files, CI configuration, or unit tests.
- Do not introduce new helpers, base classes, or fixtures unless an existing integration test already establishes the pattern and nothing existing can be reused.

## File structure

```md
# Integration tests: <short title taken from the spec>

## Test root

`<path to integration test directory>` — <framework / runner>

## Created

| File                              | Tests / scenarios                          |
|-----------------------------------|--------------------------------------------|
| `<integration test path>`         | `<test_name_1>`, `<test_name_2>`           |

## Edited

| File                              | Tests / scenarios changed                  | Change                    |
|-----------------------------------|--------------------------------------------|---------------------------|
| `<integration test path>`         | `<test_name>`                              | added / updated / removed |

## Deleted

| File or test                      | Spec reference                                            |
|-----------------------------------|-----------------------------------------------------------|
| `<integration test path>`         | <Scope item, Expected-behavior bullet, or removed symbol> |

## Coverage

| Acceptance criterion (quoted from spec)   | Covered by                                   |
|-------------------------------------------|----------------------------------------------|
| <criterion text>                          | `<file>::<test_name>`                        |
```

Omit any of `Created`, `Edited`, or `Deleted` that has no entries. Do not introduce other top-level sections.

## Stop conditions

- No folder provided.
- Folder contains no file ending with `SPEC.md`, or contains multiple.
- Spec is unreadable or empty.
- No integration test root can be located and none is provided in step 5.
