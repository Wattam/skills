# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of Claude Code **skill definitions**. There is no application code, no build system, no tests. Each
top-level folder is one skill; the only artifact is `<skill>/SKILL.md`. Editing a skill means editing its markdown.
Current skills: `spec/`, `plan/`, `integration-tests/`, `unit-tests/`, `cross-check/`, `implement/`, `review-code/`
(the pipeline) and `init-claude-md/` (standalone).

## Skill file format

Each `SKILL.md` begins with YAML frontmatter:

```yaml
---
name: <skill-name>                      # must match the folder name
description: <one paragraph>            # what it does
disable-model-invocation: true          # current convention across all skills
---
```

Every `SKILL.md` — frontmatter, body, and any inline templates — is written for LLM consumption: short declarative
sentences, explicit identifiers, no rhetorical flourish. The same rule applies to the outputs the skills produce.

## The pipeline: spec → plan → {integration-tests, unit-tests} → cross-check → implement → review-code

The seven skills are stages of one workflow and share conventions. Preserve them when editing. The order between `plan`
and `integration-tests` is not enforced — both consume the spec independently. `unit-tests` and `implement` consume the
plan, so they run after `plan/` has produced its output. The order among `implement`, `integration-tests`, and
`unit-tests` is not enforced — a TDD flow writes tests before `implement`, a non-TDD flow after. `cross-check` runs
after `plan/` and after any pre-implementation tests, and before `implement` — it reconciles the spec, plan, and those
tests against one another so contradictions are caught before code is written.

1. **`spec/`** — turns a feature/bug request into `<kebab-title>-SPEC.md` inside a **new** folder named `<kebab-title>/`
   in the CWD. Describes **WHAT** and minimum **WHY**, never **HOW**.
2. **`plan/`** — reads the `*SPEC.md` from a given folder and writes `<kebab-title>-PLAN.md` **into the same folder**.
   Describes **HOW**, never **WHY**.
3. **`integration-tests/`** — reads the `*SPEC.md` from a given folder, creates/edits/deletes integration test files in
   the codebase, and writes `<kebab-title>-INTEGRATION-TESTS.md` **into the same folder**. The doc is a **record of test
   changes**, not a plan or rationale.
4. **`unit-tests/`** — reads the `*PLAN.md` from a given folder, creates/edits/deletes unit test files in the codebase,
   and writes `<kebab-title>-UNIT-TESTS.md` **into the same folder**. The doc is a **record of test changes**, not a
   plan or rationale.
5. **`cross-check/`** — reads the `*SPEC.md` and `*PLAN.md` from a given folder, plus any `*INTEGRATION-TESTS.md` /
   `*UNIT-TESTS.md` docs and the test files they index, and writes `<kebab-title>-CROSS-CHECK.md` **into the same
   folder**. Contains **only inconsistencies found** across the documents, no praise, no summaries, and no prescribed
   fix. Reads but never modifies the spec, plan, or tests, and never reads production code.
6. **`implement/`** — reads the `*PLAN.md` from a given folder (or a direct path to the plan file) and **executes its
   Steps against the codebase in sequential order**, creating/editing/deleting production code in place and verifying
   the plan's Acceptance criteria. It writes **no markdown document** — its only artifact is the code change. It must
   not create, switch, or commit to branches, and when the plan does not mention tests it must not read or touch test
   files.
7. **`review-code/`** — reads the `*SPEC.md` and a diff/file list, writes `<kebab-title>-REVIEW.md` **into the same
   folder**. Contains **only issues found**, no praise or summaries.

Filename derivation rules:

- `plan`, `integration-tests`, `cross-check`, and `review-code` derive their filename from the spec filename by
  replacing the trailing `SPEC.md` with `PLAN.md` / `INTEGRATION-TESTS.md` / `CROSS-CHECK.md` / `REVIEW.md`.
- `unit-tests` derives its filename from the plan filename by replacing the trailing `PLAN.md` with `UNIT-TESTS.md`.
- `implement` derives no filename — it writes no markdown artifact; its output is the code change plus an in-chat
  summary.

## The `init-claude-md` skill (standalone)

Not part of the pipeline. Generates `./CLAUDE.md` from a survey of repo files plus a short interview, or proposes a diff
when one already exists. Follows the same authoring conventions as the pipeline skills (gap questions, LLM-optimized
prose, self-contained outputs) with two deliberate divergences: it skips the "abort if no `CLAUDE.md`" precondition (it
is the skill that creates the file), and its output lives at the repo root rather than in a `<kebab-title>/` folder.

## Invariants every skill enforces (keep these in sync if you edit one)

- **Precondition.** `spec`, `plan`, `integration-tests`, `unit-tests`, `cross-check`, `implement`, and `review-code`
  abort if no `CLAUDE.md` exists in the CWD — they rely on project context being present. `init-claude-md` is the
  exception: it runs without that precondition because it creates the file.
- **Gap questions are plain chat text, one at a time.** They wait for the user's answer before asking the next, and stop
  when no gaps remain.
- **Recommendations only when evidence supports them** — never invented.
- **Self-contained outputs.** Every identifier, path, signature, role, payload field needed to act on the doc must be
  inlined. Phrases like "see the ticket" / "as discussed" / "see the spec" are banned.
- **No `<TBD>` / TODO placeholders.** Unanswered gaps go under a final `## Open questions` section instead.
- **LLM-optimized prose.** Short declarative sentences, explicit identifiers, no rhetorical flourish.
- **Harness-agnostic phrasing.** Skills must not name proprietary tools tied to a specific harness. Describe the action
  instead ("search and read the codebase", "ask in plain chat text") so the skill runs on any agent. This applies only
  to the harness's tool names — ordinary verbs like "read the file" or "write the spec", and real shell commands like
  `git diff`, are fine.

`implement` shares the precondition, gap-question, recommendation, and prose invariants but produces no markdown
document, so the self-contained-output and `<TBD>`/`Open questions` invariants do not apply to it. Instead it inlines
what is needed into its in-chat summary, and when a gap blocking a Step goes unanswered it stops at that Step rather
than recording the gap.

Stage-specific anti-patterns the docs ban explicitly — useful to know when reviewing edits:

- **Spec must not describe HOW.** If a spec edit contains "first do X, then Y" or "add this method", it has drifted into
  plan territory.
- **Plan must not describe WHY.** If a plan edit contains "because", "in order to", "so that", or "the reason is", it
  has drifted into spec territory.
- **Implement must execute the plan, not author documents or touch version control.** If an `implement` edit loosens
  the bans on creating/switching/committing branches, on running Steps out of sequential order, on out-of-plan changes,
  or on reading/touching test files when the plan does not mention tests — or if it adds a markdown-output step — it has
  drifted out of execution-only territory.
- **Integration-tests summary must contain only the record of test changes and the criterion-to-test coverage map.** If
  an integration-tests summary edit contains "in order to", "so that", "because", "as the spec describes", restates the
  spec, or inlines test source code, it has drifted into spec/plan territory.
- **Unit-tests summary must contain only the record of test changes and the criterion-to-test coverage map.** If a
  unit-tests summary edit contains "in order to", "so that", "because", "as the plan describes", restates the plan, or
  inlines test source code, it has drifted into spec/plan territory.
- **Cross-check must contain only inconsistencies, and must not prescribe the fix.** If a cross-check edit contains
  "overall", "consistent", "matches", "as expected", "also", "additionally", "note that", or restates items that agree
  across the documents, it has drifted into summary territory. If it contains "should change", "fix by", "instead", "in
  order to", or "so that", or names which document to change, it has drifted into plan territory. If it adds a step that
  edits the spec, plan, or tests, or that reads production code, it has drifted out of read-only reconciliation
  territory.
- **Review-code must contain only issues.** If a review-code edit contains "overall", "previously", "good job",
  "also", "additionally", "note that", or restates passing criteria, it has drifted into summary territory.

## Output structure produced by the pipeline

```
<cwd>/
└── <kebab-title>/                    # created by spec, reused by plan/integration-tests/unit-tests/cross-check/review-code
    ├── <kebab-title>-SPEC.md
    ├── <kebab-title>-PLAN.md
    ├── <kebab-title>-INTEGRATION-TESTS.md
    ├── <kebab-title>-UNIT-TESTS.md
    ├── <kebab-title>-CROSS-CHECK.md
    └── <kebab-title>-REVIEW.md
```

The `integration-tests` and `unit-tests` skills also write to the codebase outside the spec folder — the test files
themselves. The `INTEGRATION-TESTS.md` and `UNIT-TESTS.md` docs are indexes of those changes plus a coverage map; they
do not contain test source code.

The `implement` skill writes only to the codebase outside the spec folder — the production code it changes. It adds no
file to the `<kebab-title>/` folder.

The `cross-check` skill writes only the `CROSS-CHECK.md` file inside the spec folder. It reads the spec, plan, test
docs, and the test files those docs index, but modifies none of them and reads no production code.

The cross-check file has exactly three top-level sections in fixed order — `## Spec ↔ plan`, `## Spec ↔ tests`,
`## Plan ↔ tests` — with numbered inconsistencies restarting at 1 inside each section. Sections with no entries are
omitted; the two test sections are omitted entirely when tests are absent. Do not introduce new top-level sections when
editing `cross-check/SKILL.md`.

The review file has exactly three top-level sections in fixed order — `## Out-of-scope changes`,
`## Acceptance criteria not met`, `## Implementation issues` — with numbered issues restarting at 1 inside each section.
Do not introduce new top-level sections when editing `review-code/SKILL.md`.

## Editing tips

- When changing a workflow step (e.g. how gap questions are asked, how filenames are derived, the CLAUDE.md
  precondition), apply the change to all seven pipeline skills so they stay consistent. Exception: `implement` writes no
  markdown artifact, so filename-derivation and output-format changes do not apply to it.
- There are no commands to run, lint, or test. Validation of a skill change is by reading the diff against the
  conventions above.
