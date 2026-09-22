# Development pipeline

These skills turn a feature request or bug report into specified, tested, and reviewed code. Pipeline documents are stored in `specs/<title>/`. See `../README.md` for installation.

## The pipeline

```
spec ──► plan ──► test ──► cross-check ──► implement ──► review-code ──► adress-review
```

| Stage            | You provide                                                                                                                                                          | It produces                                                                                                    |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `/spec`          | A feature or bug description as text or a file path                                                                                                                  | `specs/<title>/<title>-SPEC.md` with what to build and why                                                     |
| `/plan`          | The spec folder                                                                                                                                                      | `<title>-PLAN.md` with ordered implementation steps                                                            |
| `/test`          | The spec folder with the spec and plan                                                                                                                               | Test files in the codebase and `<title>-TEST.md` as an index of the changes                                    |
| `/cross-check`   | The spec folder                                                                                                                                                      | Reconciled spec, plan, and test files; `<title>-CROSS-CHECK.md` records unresolved inconsistencies when needed |
| `/implement`     | The spec folder or a direct path to the plan                                                                                                                         | The production code change and `<title>-IMPLEMENT.md`                                                          |
| `/review-code`   | The spec folder and an optional diff range or file list; the default is the uncommitted working tree; it reads `PLAN.md`, `IMPLEMENT.md`, and `TEST.md` when present | `<title>-REVIEW.md` when issues are found                                                                      |
| `/adress-review` | The spec folder or its `<title>-REVIEW.md` file                                                                                                                      | Confirmed fixes and updated documents; review issues tagged `[fixed]` or `[invalidated]`; no new document      |

Ordering is flexible where the inputs permit it:

- `test` needs the spec and plan.
- For TDD, run `/test` before `/implement`. Otherwise run it after `/implement`.
- Run `cross-check` after the plan and any pre-implementation tests. Run it before `/implement`.
- `adress-review` needs the spec and its matching review. Other stage documents are optional.
- Run `review-code` again after fixes to check the final changes.

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
/review-code specs/add-promotion-archive-job/
# If the review reports issues:
/adress-review specs/add-promotion-archive-job/
/review-code specs/add-promotion-archive-job/
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

- **Questions.** Stages other than `adress-review` ask one question at a time when a missing decision blocks progress. They recommend an answer only when codebase evidence supports it.
- **Self-contained documents.** Each artifact includes the names, paths, and values needed to use it without the chat history.
- **Findings only.** `review-code` lists only problems. It writes no report when it finds no problem. `cross-check` resolves inconsistencies with you. It updates documents and test files after each answer. It writes a report only for unresolved findings.
- **Validated fixes.** `adress-review` validates findings and fixes confirmed issues without questions. It updates existing documents for the corrected version. It tags review issues only as `[fixed]` or `[invalidated]`. It leaves unresolved issues untagged. It creates no document.
- **Full test runs.** `implement` and `adress-review` run the full project test suite unless the plan or you exclude it. They report checks that fail or cannot run.
- **Stage limits.** Specs state what and why. Plans state how. `test` edits tests but not production code. `implement` executes the plan and writes its report. `cross-check` edits pipeline documents and tests but not production code. `adress-review` can edit production code, tests, and affected documents for confirmed review issues. `implement` and `adress-review` use version control only for read-only checks.
