---
name: integration-tests
description: Create, edit, and delete integration tests in the codebase based on a specification (folder path containing a file ending with SPEC.md). Localize the affected test files with minimal codebase exploration, apply the changes in place, and write a summary of the test changes inside the same spec folder.
disable-model-invocation: true
---

# Integration tests

## Inputs

- A folder path containing a file ending with `SPEC.md`.

## Workflow

1. **Precondition.** If no `CLAUDE.md` exists in the current working directory, tell the user the skill requires project
   context from `CLAUDE.md` and stop.
2. **Locate and ingest the spec.** List the folder contents, identify the file ending with `SPEC.md`, and read it in
   full. Treat Scope (feature spec) or Current behavior + Expected behavior (bug-fix spec), together with Acceptance
   criteria, Context, and Examples, as the binding source of behaviors to cover.
3. **Localize integration tests.** Find the integration test root (e.g. `tests/integration/`, `test/integration/`,
   `src/test/java/.../it/`, `integration-tests/`, `e2e/`). For every file, symbol, endpoint, table, or column named in
   the spec's Context, search the integration test root for direct references. Read each matching integration test file
   in
   full. Read each file the spec's Context names only to confirm signatures and payload shapes needed to write new
   tests. Do not read unit tests, fixtures unrelated to the matched tests, build files, or production code not named in
   the spec's Context.
4. **Build the change set.** For each Scope item (feature spec) or each Expected-behavior bullet (bug-fix spec), and
   for each Acceptance criterion in the spec:
    - An integration test from step 3 already exercises the same symbol, endpoint, or behavior → **EDIT** (record file
      path and the assertions/scenarios to add, change, or remove).
    - No integration test from step 3 covers this item → **CREATE** (record the new file path and the
      assertions/scenarios to add).
    - Spec removes a behavior, endpoint, or symbol that an integration test from step 3 still exercises → **DELETE** (
      record file path, or specific test names if the file still covers in-scope behavior).
      Every Acceptance criterion must map to at least one assertion in the change set.
5. **Identify gaps.** Scan the spec and the localization output for missing information that would block writing or
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
6. **Ask one question at a time.**
    - Include a recommendation only when evidence supports one; never invent one.
    - Wait for an answer before asking the next question.
    - Stop when no gaps remain.
7. **Apply the change set.**
    - **CREATE**: write the new test file at the recorded path. Mirror the framework, imports, naming, fixtures, and
      helpers used by the nearest existing integration test in the same root.
    - **EDIT**: change only the recorded assertions/scenarios. Do not rewrite unchanged tests in the same file.
    - **DELETE**: remove the file, or delete only the specific test functions when the remaining tests in the file still
      cover in-scope behavior.
8. **Write the summary** to a markdown file inside the same folder as the spec. Filename: replace the trailing `SPEC.md`
   with `INTEGRATION-TESTS.md` (e.g. `add-promotion-archive-job-SPEC.md` →
   `add-promotion-archive-job-INTEGRATION-TESTS.md`). Overwrite if it exists.
9. **Confirm** with a one-line message naming the summary file and the counts of files created, edited, and deleted.

## Content rules

- Write in English, optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical
  flourish.
- The summary is a **record of test changes**, not a plan or rationale. Do not describe WHY a test was added. Do not
  restate the spec. If you catch yourself writing "in order to", "so that", "because", or "as the spec describes" —
  delete that sentence.
- The summary must be **self-contained**. Inline every test file path, test name, framework, and assertion focus. Never
  substitute a reference like "see the spec" or "see the test file" for the information itself.
- Every Acceptance criterion in the spec must map to at least one row in the Coverage table. If a criterion cannot be
  mapped, list it under `## Open questions` instead of inventing coverage.
- Do not include test source code in the summary. The tests themselves are the artifact; the summary lists where they
  live and what they cover.
- No TODOs or `<TBD>` placeholders — every gap must either be answered in step 6 or recorded under `## Open questions`
  at the bottom.

## Investigation discipline

- Read only the integration test root and the spec's Context-named files. Do not open unit tests, production code beyond
  the Context, build files, or CI configuration.
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

<include only if step 6 left gaps unanswered>

- <gap>
```

Omit any of `Created`, `Edited`, or `Deleted` that has no entries. Do not introduce other top-level sections.

## Stop conditions

- No folder provided → ask for one, then stop.
- Folder contains no file ending with `SPEC.md` → tell the user, then stop.
- Folder contains multiple files ending with `SPEC.md` → ask which one to use, then wait for their answer.
- Spec is unreadable or empty → tell the user, then stop.
- No integration test root can be located and the user provides none in step 6 → tell the user, then stop without
  applying any changes.
- User declines to answer a gap question → record the gap under `## Open questions` in the summary, omit the
  corresponding test change, and continue.
