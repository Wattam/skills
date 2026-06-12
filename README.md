# Skills

A collection of [Claude Code skills](https://code.claude.com/docs/en/skills) that turn a feature idea or bug report
into shipped, reviewed code through a series of small, focused stages. Each stage produces a markdown artifact (or, for
`implement`, the code change itself), so you can inspect, correct, and re-run any stage before moving to the next.

All skills are user-invoked only (`disable-model-invocation: true`) — Claude never triggers them on its own. You run
them as slash commands, e.g. `/spec`, `/plan`.

## Installation

```bash
./install-skills.sh
```

This runs `npx skills add . -g -a pi -a claude-code -y`, installing every skill in this repo globally for the
`claude-code` and `pi` agents. Re-run it after editing a skill to pick up changes.

## The pipeline

Seven of the eight skills form one workflow:

```
spec ──┬──► plan ──┬──► unit-tests ────────┐
       │           │                       ├──► cross-check ──► implement ──► review-code
       └───────────┴──► integration-tests ─┘
```

| Stage | You provide | It produces |
|---|---|---|
| `/spec` | A feature or bug description (text or file path) | `specs/<title>/<title>-SPEC.md` — **what** to build and why |
| `/plan` | The spec folder | `<title>-PLAN.md` — **how** to build it, as ordered steps |
| `/integration-tests` | The spec folder | Integration test files in your codebase + `<title>-INTEGRATION-TESTS.md` (an index of the changes) |
| `/unit-tests` | The spec folder (reads the plan) | Unit test files in your codebase + `<title>-UNIT-TESTS.md` (an index of the changes) |
| `/cross-check` | The spec folder | `<title>-CROSS-CHECK.md` — contradictions found between spec, plan, and tests |
| `/implement` | The spec folder (or a direct path to the plan) | The production code change itself — no markdown artifact |
| `/review-code` | The spec folder + optionally a diff range or file list (defaults to the uncommitted working tree) | `<title>-REVIEW.md` — issues found in the code, measured against the spec |

Ordering is flexible where it can be:

- `plan` and `integration-tests` both work from the spec alone, so either can go first.
- `unit-tests` and `implement` need the plan to exist.
- For **TDD**, write tests before `/implement`; otherwise write them after. Both flows work.
- `cross-check` runs after the plan and any pre-implementation tests, and before `/implement` — it catches
  contradictions before any production code is written.

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
        └── add-promotion-archive-job-REVIEW.md
```

Test files and production code go into your codebase directly; the `specs/` folder holds only the documents.

## What to expect while a skill runs

- **One question at a time.** When a skill hits a gap it cannot resolve from the codebase, it asks you a single plain
  question in chat and waits. It recommends an answer only when the codebase gives it evidence for one. If you decline
  to answer, the gap is recorded under an `## Open questions` section in the output (except in `implement`, which stops
  at the blocked step instead).
- **Self-contained documents.** Every artifact inlines all the names, paths, and values needed to act on it — you can
  hand a spec or plan to anyone (human or LLM) without the surrounding chat.
- **Findings only, no praise.** `cross-check` and `review-code` list only problems. An empty report means nothing was
  found — that's the good outcome.
- **Strict lanes.** Specs never say *how*, plans never say *why*, `implement` only executes the plan (it never touches
  branches or commits, and writes no documents), and `cross-check` never modifies anything. If a stage's output drifts
  out of its lane, that's a bug worth fixing in the skill.

## `init-claude-md` (standalone)

Not part of the pipeline. Run `/init-claude-md` inside any repo to generate a minimal `CLAUDE.md` at its root from a
survey of the repo's files plus a short interview — or, if a `CLAUDE.md` already exists, to propose a diff against it.

## Repo layout

Each top-level folder is one skill, and its only file is `SKILL.md` — the full instructions the agent follows when you
invoke it. There is no application code, build, or test suite here; to change a skill's behavior, edit its markdown.
See `CLAUDE.md` for the conventions the skill definitions follow.
