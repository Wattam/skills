# Development pipeline

These skills turn a feature request or bug report into specified, tested, reviewed code. Pipeline documents are stored in `specs/<title>/`. See `../README.md` for installation.

## The pipeline

```
spec ──┬──► plan ──┬──► unit-tests ────────┐
       │           │                       ├──► cross-check ──► implement ──► review-code ──► adress-review
       └───────────┴──► integration-tests ─┘
```

| Stage                | You provide                                                                                                                                                                                                                | It produces                                                                                                        |
|----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| `/spec`              | A feature or bug description (text or file path)                                                                                                                                                                           | `specs/<title>/<title>-SPEC.md` — **what** to build and why                                                        |
| `/plan`              | The spec folder                                                                                                                                                                                                            | `<title>-PLAN.md` — **how** to build it, as ordered steps                                                          |
| `/integration-tests` | The spec folder                                                                                                                                                                                                            | Integration test files in your codebase + `<title>-INTEGRATION-TESTS.md` (an index of the changes)                 |
| `/unit-tests`        | The spec folder (reads the plan)                                                                                                                                                                                           | Unit test files in your codebase + `<title>-UNIT-TESTS.md` (an index of the changes)                               |
| `/cross-check`       | The spec folder                                                                                                                                                                                                            | Reconciled spec/plan/test files + `<title>-CROSS-CHECK.md` — unresolved inconsistencies; written if any remain     |
| `/implement`         | The spec folder (or a direct path to the plan)                                                                                                                                                                             | The production code change + `<title>-IMPLEMENT.md` (the files changed and each acceptance criterion's result)     |
| `/review-code`       | The spec folder + optionally a diff range or file list (defaults to the uncommitted working tree; reads `<title>-PLAN.md`, `<title>-IMPLEMENT.md`, `<title>-UNIT-TESTS.md`, and `<title>-INTEGRATION-TESTS.md` if present) | `<title>-REVIEW.md` — issues found in the code, measured against the spec; written when issues are found           |
| `/adress-review`     | The spec folder or its `<title>-REVIEW.md` file                                                                                                                                                                            | Confirmed fixes and updated existing documents; review issues tagged `[fixed]` or `[invalidated]`; no new document |

Ordering is flexible where it can be:

- `plan` and `integration-tests` both work from the spec alone, so either can go first.
- `unit-tests` and `implement` need the plan to exist.
- For **TDD**, write tests before `/implement`; otherwise write them after. Both flows work.
- `cross-check` runs after the plan and any pre-implementation tests, and before `/implement`.
- `adress-review` needs the spec and its matching review. Other stage documents are optional. Run `review-code` again after the fixes to check the final changes.

You don't have to run every stage. `spec → plan → implement` is a perfectly valid short loop for small changes.

### A typical run

```
/spec Add a nightly job that archives promotions older than 90 days
# answer its questions, get specs/add-promotion-archive-job/add-promotion-archive-job-SPEC.md

/plan specs/add-promotion-archive-job/
/integration-tests specs/add-promotion-archive-job/
/unit-tests specs/add-promotion-archive-job/
/cross-check specs/add-promotion-archive-job/
# work through each inconsistency with it; it fixes the docs and tests as you agree, then:

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
        ├── add-promotion-archive-job-INTEGRATION-TESTS.md
        ├── add-promotion-archive-job-UNIT-TESTS.md
        ├── add-promotion-archive-job-CROSS-CHECK.md
        ├── add-promotion-archive-job-IMPLEMENT.md
        └── add-promotion-archive-job-REVIEW.md
```

Test files and production code go into your codebase directly; the `specs/` folder holds only the documents.

## What to expect while a skill runs

- **Questions.** Stages other than `adress-review` ask one question at a time when a missing decision prevents progress. They recommend an answer only when the codebase provides evidence.
- **Self-contained documents.** Every artifact inlines all the names, paths, and values needed to act on it — you can hand a spec or plan to anyone (human or LLM) without the surrounding chat.
- **Findings only, no praise.** `review-code` lists only problems; no report file is written when nothing is found — that's the good outcome. `cross-check` works through the inconsistencies it finds
  with you, fixing the affected documents and test files as you agree on each, and writes a report only for the ones left unresolved.
- **Validated fixes.** `adress-review` validates findings and fixes confirmed issues without questions. It updates existing documents for the corrected version without repair history. In the review, it only tags issues `[fixed]` or `[invalidated]`. Unresolved issues remain untagged. It creates no document.
- **Tests run in full.** `implement` and `adress-review` run the project's entire test suite, not only the tests related to the change, unless the plan or you say not to. They state which checks failed or could not run.
- **Stage limits.** Specs state WHAT and WHY. Plans state HOW. `implement` executes the plan and writes its own report. `cross-check` edits pipeline documents and tests, never production code. `adress-review` can edit production code, tests, and affected documents for confirmed review issues. `implement` and `adress-review` use version control only for read-only checks.
