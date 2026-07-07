---
name: unit-tests
description: Create, edit, and delete unit tests in the codebase based on an implementation plan.
disable-model-invocation: true
---

## Inputs

A folder path containing a file ending with `PLAN.md`. Expected location: `specs/<kebab-title>/`.

## Workflow

1. **Locate and ingest the plan.** List the folder contents, identify the file ending with `PLAN.md`, and read it in full. Treat Steps and Acceptance criteria as the binding source of behaviors to
   cover.
2. **Localize unit tests.** Determine the project's unit test convention: co-located (`foo.test.ts`, `foo_test.go`, `test_foo.py` next to the source file) or parallel tree (`tests/unit/`,
   `src/test/java/...`, `__tests__/`). For every file, module, function, class, or method named in the plan's Steps or Context, search those locations for direct references and read each matching
   test file in full. Read the production files named in the plan only to confirm signatures, types, and exported symbols.
3. **Build the change set.** For each Step and each Acceptance criterion:
    - An existing unit test exercises the same symbol or behavior → **EDIT** (record file path and the assertions/cases to add, change, or remove).
    - No unit test covers the symbol or behavior → **CREATE** (record the new file path and the assertions/cases to add).
    - Plan removes a symbol, branch, or behavior a unit test still exercises → **DELETE** (record file path, or specific test names if the file still covers in-scope behavior).
4. **Identify gaps.** Scan the plan and the localization output for missing information that would block writing or modifying tests. Treat each of these as a potential gap:
    - **Test infrastructure** — unit test framework, runner, assertion library, mocking library, or invocation command not discoverable from the codebase.
    - **Naming and layout** — new test file naming convention, location (co-located vs parallel tree), package/module path for new files.
    - **Isolation and doubles** — how the project mocks, stubs, or fakes external collaborators (DB, HTTP, clock, filesystem, third-party clients).
    - **Fixtures and setup** — input builders, factory helpers, `beforeEach`/`setUp` patterns, parameterization conventions not understood.
    - **Coverage decisions** — ambiguous whether a Step warrants a new file, an edit, or both; multiple existing tests look applicable; an Acceptance criterion has no clear test target; a
      private/internal symbol is not directly testable.
    - **Deletion confirmation** — an existing test appears obsolete but the plan does not explicitly mark its target as removed.
5. **Interview me about every gap.** One question at a time, until none remain. Include a recommendation for a gap when evidence supports one; never invent one.
6. **Apply the change set.**
    - **CREATE**: write the new test file at the recorded path. Mirror the framework, imports, naming, fixtures, mocks, and helpers used by the nearest existing unit test.
    - **EDIT**: change only the recorded assertions/cases.
    - **DELETE**: remove the recorded file, or only the recorded test functions.
7. **Write the summary** to a markdown file inside the same folder as the plan. Filename: replace the trailing `PLAN.md` with `UNIT-TESTS.md`. Overwrite if it exists.
8. **Confirm** with a one-line message naming the summary file written and the counts of test files created, edited, and deleted.

## Content rules

- Optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical flourish.
- The summary is a **record of test changes**, not a plan or rationale. Do not describe WHY a test was added.
- The summary must be **self-contained**. Inline every test file path, test name, framework, and assertion focus; never substitute a reference like "see the plan" for the information itself.
- Do not include test source code in the summary.
- No TODOs or `<TBD>` placeholders — every gap must be answered in step 5.

## Investigation discipline

- Do not run tests, install dependencies, or trigger any code execution.
- Do not modify production code, fixtures, helpers, build files, CI configuration, integration tests, or end-to-end tests.
- Do not introduce new helpers, base classes, mocks, or fixtures unless an existing unit test already establishes the pattern and nothing existing can be reused.

## File structure

```md
# Unit tests: <short title taken from the plan>

## Test layout

`<co-located | parallel tree path>` — <framework / runner / mocking library>

## Created

| File                              | Tests / cases                              |
|-----------------------------------|--------------------------------------------|
| `<unit test path>`                | `<test_name_1>`, `<test_name_2>`           |

## Edited

| File                              | Tests / cases changed                      | Change                    |
|-----------------------------------|--------------------------------------------|---------------------------|
| `<unit test path>`                | `<test_name>`                              | added / updated / removed |

## Deleted

| File or test                      | Plan reference                             |
|-----------------------------------|--------------------------------------------|
| `<unit test path>`                | <Step number or removed symbol>            |

## Coverage

| Acceptance criterion (quoted from plan)   | Covered by                                   |
|-------------------------------------------|----------------------------------------------|
| <criterion text>                          | `<file>::<test_name>`                        |
```

Omit any of `Created`, `Edited`, or `Deleted` that has no entries. Do not introduce other top-level sections.

## Stop conditions

- No folder provided.
- Folder contains no file ending with `PLAN.md`, or contains multiple.
- Plan is unreadable or empty.
- No unit test location can be determined and none is provided in step 5.
