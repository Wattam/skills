# Development pipeline

These skills turn a feature request or bug report into specified, tested, and reviewed code. Pipeline documents are stored in `specs/<title>/`. See `../README.md` for installation.

## The pipeline

```
spec ──► plan ──► test ──► cross-check ──► implement ──► review ──► address-review
```

| Stage             | You provide                                                                                                                                                            | It produces                                                                                                       |
|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|
| `/spec`           | A feature or bug description as text or a file path                                                                                                                    | `specs/<title>/<title>-SPEC.md` with what to build and why                                                        |
| `/plan`           | The spec folder                                                                                                                                                        | `<title>-PLAN.md` with ordered implementation steps                                                               |
| `/test`           | The spec folder with the spec and plan                                                                                                                                 | Test files in the codebase and `<title>-TEST.md` as an index of the changes; after `/implement`, test results     |
| `/cross-check`    | The spec folder                                                                                                                                                        | Reconciled spec, plan, and test files; `<title>-CROSS-CHECK.md` records unresolved inconsistencies when needed    |
| `/implement`      | The spec folder or a direct path to the plan; it reads `TEST.md` and `CROSS-CHECK.md` when present                                                                     | The production code change, necessary test setup repairs, updated setup documentation, and `<title>-IMPLEMENT.md` |
| `/review`         | The spec folder and an optional diff range or file list; the default is the uncommitted working tree outside `specs/`; it reads the other stage documents when present | `<title>-REVIEW.md` when issues are found                                                                         |
| `/address-review` | The spec folder or its `<title>-REVIEW.md` file                                                                                                                        | Confirmed fixes and updated documents; review issues tagged `[fixed]` or `[invalidated]`; no new document         |

Ordering is flexible where the inputs permit it:

- `test` needs the spec and plan.
- For TDD, run `/test` before `/implement`. `/test` does not run the tests; `/implement` runs them. Otherwise run `/test` after `/implement`. `/test` then runs the new tests and the full suite and records the results in `TEST.md`.
- Run `cross-check` after the plan and any pre-implementation tests. Run it before `/implement`. `/implement` asks before it proceeds with open cross-check findings.
- `address-review` needs the spec and its matching review. Other stage documents are optional.
- Run `review` again after fixes to check the final changes. A clean run deletes the stale `REVIEW.md`.
- Re-running `/spec` or `/plan` makes later documents in the folder stale. Both skills name the stale documents when they finish.

You do not have to run every stage. `spec → plan → implement` is a valid short flow for small changes.

### A typical run

```
/spec Add a nightly job that archives promotions older than 90 days
# Answer its questions. It writes specs/add-promotion-archive-job/add-promotion-archive-job-SPEC.md.

/plan specs/add-promotion-archive-job/
/test specs/add-promotion-archive-job/
/cross-check specs/add-promotion-archive-job/
# Resolve each inconsistency. The skill updates the documents and tests after each answer.

/implement specs/add-promotion-archive-job/
/review specs/add-promotion-archive-job/
# If the review reports issues:
/address-review specs/add-promotion-archive-job/
/review specs/add-promotion-archive-job/
```

### What lands in your project

```
<your-project>/
└── specs/
    └── add-promotion-archive-job/
        ├── add-promotion-archive-job-SPEC.md
        ├── add-promotion-archive-job-PLAN.md
        ├── add-promotion-archive-job-TEST.md
        ├── add-promotion-archive-job-CROSS-CHECK.md
        ├── add-promotion-archive-job-IMPLEMENT.md
        └── add-promotion-archive-job-REVIEW.md
```

Test files and production code go into the codebase. The `specs/` folder contains only pipeline documents.

## What to expect while a skill runs

- **Questions.** Stages other than `address-review` ask one question at a time when a missing decision blocks progress. They recommend an answer only when codebase evidence supports it.
- **Self-contained documents.** Each artifact includes the names, paths, and values needed to use it without the chat history.
- **Findings only.** `review` lists only problems. It writes no report when it finds no problem and deletes a stale one. `cross-check` resolves inconsistencies with you. It updates documents and test files after each answer. It writes a report only for unresolved findings and deletes a stale one when none remain.
- **Validated fixes.** `address-review` validates findings and fixes confirmed issues without questions. It updates existing documents for the corrected version. It appends `[fixed]` or `[invalidated]` to review issue headings. It leaves unresolved issues untagged. It leaves open cross-check findings for you to decide. It creates no document.
- **Full test runs.** `implement` and `address-review` run the full project test suite unless the plan or you exclude it. `test` runs it only after `/implement`. They report checks that fail or cannot run. `implement` repairs setup blockers and reruns tests; it asks before installing dependencies or changing the environment. The other stages do not install dependencies.
- **Stage limits.** Specs state what and why. Plans state how. `test` edits tests but not production code. `implement` executes the plan, repairs only test setup/infrastructure blockers, updates affected `PLAN.md`/`TEST.md` setup details, and writes its report. It does not change test assertions or feature behavior to make tests pass. `cross-check` edits pipeline documents and tests but not production code. `address-review` can edit production code, tests, and affected documents for confirmed review issues. Every stage uses version control only for read-only checks.
