---
name: integration-tests
description: Create, edit, and delete integration tests in the codebase based on a specification.
disable-model-invocation: true
---

# Integration tests

## Inputs

- A folder path containing a file ending with `SPEC.md`. Expected location: `specs/<kebab-title>/`.

## Workflow

1. **Locate and ingest the spec.** List the folder contents, identify the file ending with `SPEC.md`, and read it in
   full. Treat Scope (feature spec) or Current behavior + Expected behavior (bug-fix spec), together with Acceptance
   criteria, Context, and Examples, as the binding source of behaviors to cover.
2. **Localize integration tests.** Find the integration test root (e.g. `tests/integration/`, `test/integration/`,
   `src/test/java/.../it/`, `integration-tests/`, `e2e/`). For every file, symbol, endpoint, table, or column named in
   the spec's Context, search the integration test root for direct references. Read each matching integration test file
   in full. Read each file the spec's Context names only to confirm signatures and payload shapes needed to write new
   tests.
3. **Build the change set.** For each Scope item (feature spec) or each Expected-behavior bullet (bug-fix spec), and
   for each Acceptance criterion in the spec:
    - An integration test from step 2 already exercises the same symbol, endpoint, or behavior → **EDIT** (record file
      path and the assertions/scenarios to add, change, or remove).
    - No integration test from step 2 covers this item → **CREATE** (record the new file path and the
      assertions/scenarios to add).
    - Spec removes a behavior, endpoint, or symbol that an integration test from step 2 still exercises → **DELETE**
      (record file path, or specific test names if the file still covers in-scope behavior).
4. **Identify gaps.** Scan the spec and the localization output for missing information that would block writing or
   modifying tests. Treat each of these as a potential gap:
    - **Test infrastructure** — integration test root, framework, runner, or invocation command not discoverable from
      the codebase.
    - **Naming and layout** — new test file naming convention, package/module path for new files.
    - **Fixtures and setup** — DB seeding, test data builders, auth/session setup, environment variables, or mocked
      external services not understood.
    - **Coverage decisions** — ambiguous whether a Scope item (feature spec) or Expected-behavior bullet (bug-fix spec)
      warrants a new file, an edit, or both; multiple existing tests look applicable; an Acceptance criterion has no
      clear test target.
    - **Deletion confirmation** — an existing test appears obsolete but the spec does not explicitly mark its target as
      removed.
5. **Ask one question at a time.** Include a recommendation only when evidence supports one; never invent one. Wait for
   an answer before asking the next; stop when no gaps remain.
6. **Apply the change set.**
    - **CREATE**: write the new test file at the recorded path. Mirror the framework, imports, naming, fixtures, and
      helpers used by the nearest existing integration test in the same root.
    - **EDIT**: change only the recorded assertions/scenarios.
    - **DELETE**: remove the recorded file, or delete only the recorded test functions.
7. **Write the summary** to a markdown file inside the same folder as the spec. Filename: replace the trailing `SPEC.md`
   with `INTEGRATION-TESTS.md` (e.g. `…-SPEC.md` → `…-INTEGRATION-TESTS.md`). Overwrite if it exists.

## Content rules

- Write in English, optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical
  flourish.
- The summary is a **record of test changes**, not a plan or rationale. Do not describe WHY a test was added.
- The summary must be **self-contained**. Inline every test file path, test name, framework, and assertion focus. Never
  substitute a reference like "see the spec" or "see the test file" for the information itself.
- Do not include test source code in the summary.
- No TODOs or `<TBD>` placeholders — every gap must either be answered in step 5 or recorded under `## Open questions`
  at the bottom.

## Investigation discipline

- Do not run tests, install dependencies, or trigger any code execution.
- Do not modify production code, fixtures, helpers, build files, CI configuration, or unit tests.
- Do not introduce new helpers, base classes, or fixtures unless an existing integration test in the same root already
  establishes the pattern and a new test in the change set cannot reuse what already exists.

## Summary file structure

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

## Open questions

<include only if step 5 left gaps unanswered>

- <gap>
```

Omit any of `Created`, `Edited`, or `Deleted` that has no entries. Do not introduce other top-level sections.

## Stop conditions

- No folder provided → ask for one, then stop.
- Folder contains no file ending with `SPEC.md` → tell the user, then stop.
- Folder contains multiple files ending with `SPEC.md` → ask which one to use, then wait for their answer.
- Spec is unreadable or empty → tell the user, then stop.
- No integration test root can be located and the user provides none in step 5 → tell the user, then stop without
  applying any changes.
- User declines to answer a gap question → record the gap under `## Open questions` in the summary, omit the
  corresponding test change, and continue.
