---
name: unit-tests
description: Create, edit, and delete unit tests in the codebase based on an implementation plan.
disable-model-invocation: true
---

# Unit tests

## Inputs

- A folder path containing a file ending with `PLAN.md`. Expected location: `specs/<kebab-title>/`.

## Workflow

1. **Precondition.** If no `CLAUDE.md` exists in the current working directory, tell the user the skill requires project
   context from `CLAUDE.md` and stop.
2. **Locate and ingest the plan.** List the folder contents, identify the file ending with `PLAN.md`, and read it in
   full. Treat Context, Steps, and Acceptance criteria as the binding source of behaviors to cover.
3. **Localize unit tests.** Determine the project's unit test convention: co-located (`foo.test.ts` next to `foo.ts`,
   `foo_test.go`, `test_foo.py` next to `foo.py`), parallel tree (`tests/unit/`, `test/`, `src/test/java/...`,
   `__tests__/`), or framework-specific layout declared in `CLAUDE.md`. For every file, module, function, class, or
   method named in the plan's Steps or Context, search those unit test locations for direct references and read each
   matching unit test file in full. Read each production file named in the plan only to confirm signatures, types, and
   exported symbols needed to write new tests.
4. **Build the change set.** For each Step and each Acceptance criterion in the plan:
    - A unit test from step 3 already exercises the same symbol or behavior → **EDIT** (record file path and the
      assertions/cases to add, change, or remove).
    - No unit test from step 3 covers this symbol or behavior → **CREATE** (record the new file path and the
      assertions/cases to add).
    - Plan removes a symbol, branch, or behavior that a unit test from step 3 still exercises → **DELETE** (record file
      path, or specific test names if the file still covers in-scope behavior).
      Every Acceptance criterion must map to at least one assertion in the change set. Every Step that introduces or
      modifies a symbol must map to at least one test case in the change set.
5. **Identify gaps.** Scan the plan and the localization output for missing information that would block writing or
   modifying tests. Treat each of these as a potential gap:
    - **Test infrastructure** — unit test framework, runner, assertion library, mocking library, or invocation command
      not discoverable from the codebase.
    - **Naming and layout** — new test file naming convention, location (co-located vs parallel tree), package/module
      path for new files.
    - **Isolation and doubles** — how the project mocks, stubs, or fakes external collaborators (DB, HTTP, clock,
      filesystem, third-party clients); whether dependency injection or module-level patching is used.
    - **Fixtures and setup** — input builders, factory helpers, `beforeEach`/`setUp` patterns, parameterization
      conventions not understood.
    - **Coverage decisions** — ambiguous whether a Step warrants a new file, an edit, or both; multiple existing tests
      look applicable; an Acceptance criterion has no clear test target; a private/internal symbol is not directly
      testable.
    - **Deletion confirmation** — an existing test appears obsolete but the plan does not explicitly mark its target as
      removed.
6. **Ask one question at a time.**
    - Include a recommendation only when evidence supports one; never invent one.
    - Wait for an answer before asking the next question.
    - Stop when no gaps remain.
7. **Apply the change set.**
    - **CREATE**: write the new test file at the recorded path. Mirror the framework, imports, naming, fixtures, mocks,
      and helpers used by the nearest existing unit test in the same location.
    - **EDIT**: change only the recorded assertions/cases. Do not rewrite unchanged tests in the same file.
    - **DELETE**: remove the file, or delete only the specific test functions when the remaining tests in the file still
      cover in-scope behavior.
8. **Write the summary** to a markdown file inside the same folder as the plan. Filename: replace the trailing `PLAN.md`
   with `UNIT-TESTS.md` (e.g. `specs/add-promotion-archive-job/add-promotion-archive-job-PLAN.md` →
   `specs/add-promotion-archive-job/add-promotion-archive-job-UNIT-TESTS.md`). Overwrite if it exists.
9. **Confirm** with a one-line message naming the summary file and the counts of files created, edited, and deleted.

## Content rules

- Write in English, optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical
  flourish.
- The summary is a **record of test changes**, not a plan or rationale. Do not describe WHY a test was added. Do not
  restate the plan. If you catch yourself writing "in order to", "so that", "because", or "as the plan describes" —
  delete that sentence.
- The summary must be **self-contained**. Inline every test file path, test name, framework, and assertion focus. Never
  substitute a reference like "see the plan" or "see the test file" for the information itself.
- Every Acceptance criterion in the plan must map to at least one row in the Coverage table. If a criterion cannot be
  mapped, list it under `## Open questions` instead of inventing coverage.
- Do not include test source code in the summary. The tests themselves are the artifact; the summary lists where they
  live and what they cover.
- No TODOs or `<TBD>` placeholders — every gap must either be answered in step 6 or recorded under `## Open questions`
  at the bottom.

## Investigation discipline

- Read only the unit test locations and the production files named in the plan. Do not open integration tests,
  end-to-end tests, fixtures unrelated to the matched tests, production code beyond the plan, build files, or CI
  configuration.
- Do not run tests, install dependencies, or trigger any code execution.
- Do not modify production code, fixtures, helpers, build files, CI configuration, integration tests, or end-to-end
  tests.
- Do not introduce new helpers, base classes, mocks, or fixtures unless an existing unit test in the same location
  already establishes the pattern and a new test in the change set cannot reuse what already exists.

## Summary file structure

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

## Open questions

<include only if step 6 left gaps unanswered>

- <gap>
```

Omit any of `Created`, `Edited`, or `Deleted` that has no entries. Do not introduce other top-level sections.

## Stop conditions

- No folder provided → ask for one, then stop.
- Folder contains no file ending with `PLAN.md` → tell the user, then stop.
- Folder contains multiple files ending with `PLAN.md` → ask which one to use, then wait for their answer.
- Plan is unreadable or empty → tell the user, then stop.
- No unit test location can be located and the user provides none in step 6 → tell the user, then stop without applying
  any changes.
- User declines to answer a gap question → record the gap under `## Open questions` in the summary, omit the
  corresponding test change, and continue.
