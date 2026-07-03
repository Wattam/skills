# Development pipeline

Skills that turn a feature idea or bug report into shipped, reviewed code through a series of small, focused stages. Each stage produces a markdown artifact, so you can inspect, correct, and re-run
any stage before moving to the next. See `../README.md` for installation.

## The pipeline

```
spec ──┬──► plan ──┬──► unit-tests ────────┐
       │           │                       ├──► cross-check ──► implement ──► review-code
       └───────────┴──► integration-tests ─┘
```

| Stage                | You provide                                                                                                                                                                                                                | It produces                                                                                                    |
|----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `/spec`              | A feature or bug description (text or file path)                                                                                                                                                                           | `specs/<title>/<title>-SPEC.md` — **what** to build and why                                                    |
| `/plan`              | The spec folder                                                                                                                                                                                                            | `<title>-PLAN.md` — **how** to build it, as ordered steps                                                      |
| `/integration-tests` | The spec folder                                                                                                                                                                                                            | Integration test files in your codebase + `<title>-INTEGRATION-TESTS.md` (an index of the changes)             |
| `/unit-tests`        | The spec folder (reads the plan)                                                                                                                                                                                           | Unit test files in your codebase + `<title>-UNIT-TESTS.md` (an index of the changes)                           |
| `/cross-check`       | The spec folder                                                                                                                                                                                                            | `<title>-CROSS-CHECK.md` — contradictions between spec, plan, and tests; written when contradictions are found |
| `/implement`         | The spec folder (or a direct path to the plan)                                                                                                                                                                             | The production code change + `<title>-IMPLEMENT.md` (the files changed and each acceptance criterion's result) |
| `/review-code`       | The spec folder + optionally a diff range or file list (defaults to the uncommitted working tree; reads `<title>-PLAN.md`, `<title>-IMPLEMENT.md`, `<title>-UNIT-TESTS.md`, and `<title>-INTEGRATION-TESTS.md` if present) | `<title>-REVIEW.md` — issues found in the code, measured against the spec; written when issues are found       |

Ordering is flexible where it can be:

- `plan` and `integration-tests` both work from the spec alone, so either can go first.
- `unit-tests` and `implement` need the plan to exist.
- For **TDD**, write tests before `/implement`; otherwise write them after. Both flows work.
- `cross-check` runs after the plan and any pre-implementation tests, and before `/implement` — it catches contradictions before any production code is written.

You don't have to run every stage. `spec → plan → implement` is a perfectly valid short loop for small changes.

### A typical run

```
/spec Add a nightly job that archives promotions older than 90 days
# answer its questions, get specs/add-promotion-archive-job/add-promotion-archive-job-SPEC.md

/plan specs/add-promotion-archive-job/
/integration-tests specs/add-promotion-archive-job/
/unit-tests specs/add-promotion-archive-job/
/cross-check specs/add-promotion-archive-job/
# fix anything the cross-check flags, then:

/implement specs/add-promotion-archive-job/
/review-code specs/add-promotion-archive-job/
# fix anything the review flags
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

- **One question at a time.** When a skill hits a gap it cannot resolve from the codebase, it asks you a single plain question in chat and waits. It recommends an answer only when the codebase gives
  it evidence for one. If you decline to answer, the skill records the gap rather than guessing, and where it records it depends on the stage: `spec`, `plan`, `unit-tests`, and `integration-tests` add
  it to an `## Open questions` section in their output; `implement` stops at the blocked step instead; `cross-check` records the divergence as an inconsistency in the matching section; `review-code`
  records the change under `## Out-of-scope changes`.
- **Self-contained documents.** Every artifact inlines all the names, paths, and values needed to act on it — you can hand a spec or plan to anyone (human or LLM) without the surrounding chat.
- **Findings only, no praise.** `cross-check` and `review-code` list only problems. No report file is written when nothing is found — that's the good outcome.
- **Tests run in full.** When `implement` verifies acceptance criteria, it runs the project's entire test suite — not only the tests touching the change — unless the plan or you say not to.
- **Strict lanes.** Specs never say *how*, plans never say *why*, `implement` only executes the plan (it never touches branches or commits, and writes no document other than its `IMPLEMENT.md`
  report), and `cross-check` never modifies anything. If a stage's output drifts out of its lane, that's a bug worth fixing in the skill.
