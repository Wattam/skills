# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of Claude Code **skill definitions**. There is no application code, no build system, no tests. Each
top-level folder is one skill; the only artifact is `<skill>/SKILL.md`. Editing a skill means editing its markdown.
Current skills: `spec/`, `plan/`, `integration-tests/`, `unit-tests/`, `review-code/` (the pipeline) and `init-claude-md/` (
standalone).

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

## The pipeline: spec → plan → {integration-tests, unit-tests} → review-code

The five skills are stages of one workflow and share conventions. Preserve them when editing. The order between `plan`
and `integration-tests` is not enforced — both consume the spec independently. `unit-tests` consumes the plan, so it
runs after `plan/` has produced its output.

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
5. **`review-code/`** — reads the `*SPEC.md` and a diff/file list, writes `<kebab-title>-REVIEW.md` **into the same folder**.
   Contains **only issues found**, no praise or summaries.

Filename derivation rules:

- `plan`, `integration-tests`, and `review-code` derive their filename from the spec filename by replacing the trailing
  `SPEC.md` with `PLAN.md` / `INTEGRATION-TESTS.md` / `REVIEW.md`.
- `unit-tests` derives its filename from the plan filename by replacing the trailing `PLAN.md` with `UNIT-TESTS.md`.

## The `init-claude-md` skill (standalone)

Not part of the pipeline. Generates `./CLAUDE.md` from a survey of repo files plus a short interview, or proposes a diff
when one already exists. Follows the same authoring conventions as the pipeline skills (plain-text gap questions, no
`AskUserQuestion`, LLM-optimized prose, self-contained outputs) with two deliberate divergences: it skips the "abort if
no `CLAUDE.md`" precondition (it is the skill that creates the file), and its output lives at the repo root rather than
in a `<kebab-title>/` folder.

## Invariants every skill enforces (keep these in sync if you edit one)

- **Precondition.** `spec`, `plan`, `integration-tests`, `unit-tests`, and `review-code` abort if no `CLAUDE.md` exists in
  the CWD — they rely on project context being present. `init-claude-md` is the exception: it runs without that
  precondition because it creates the file.
- **Gap questions are plain chat text, one at a time.** Skills explicitly forbid `AskUserQuestion`. They wait for the
  user's answer before asking the next, and stop when no gaps remain.
- **Recommendations only when evidence supports them** — never invented.
- **Self-contained outputs.** Every identifier, path, signature, role, payload field needed to act on the doc must be
  inlined. Phrases like "see the ticket" / "as discussed" / "see the spec" are banned.
- **No `<TBD>` / TODO placeholders.** Unanswered gaps go under a final `## Open questions` section instead.
- **LLM-optimized prose.** Short declarative sentences, explicit identifiers, no rhetorical flourish.

Stage-specific anti-patterns the docs ban explicitly — useful to know when reviewing edits:

- **Spec must not describe HOW.** If a spec edit contains "first do X, then Y" or "add this method", it has drifted into
  plan territory.
- **Plan must not describe WHY.** If a plan edit contains "because", "in order to", "so that", or "the reason is", it
  has drifted into spec territory.
- **Integration-tests summary must contain only the record of test changes and the criterion-to-test coverage map.** If
  an integration-tests summary edit contains "in order to", "so that", "because", "as the spec describes", restates the
  spec, or inlines test source code, it has drifted into spec/plan territory.
- **Unit-tests summary must contain only the record of test changes and the criterion-to-test coverage map.** If a
  unit-tests summary edit contains "in order to", "so that", "because", "as the plan describes", restates the plan, or
  inlines test source code, it has drifted into spec/plan territory.
- **Review-code must contain only issues.** If a review-code edit contains "overall", "previously", "good job", "also", "
  additionally", "note that", or restates passing criteria, it has drifted into summary territory.

## Output structure produced by the pipeline

```
<cwd>/
└── <kebab-title>/                    # created by spec, reused by plan/integration-tests/unit-tests/review-code
    ├── <kebab-title>-SPEC.md
    ├── <kebab-title>-PLAN.md
    ├── <kebab-title>-INTEGRATION-TESTS.md
    ├── <kebab-title>-UNIT-TESTS.md
    └── <kebab-title>-REVIEW.md
```

The `integration-tests` and `unit-tests` skills also write to the codebase outside the spec folder — the test files
themselves. The `INTEGRATION-TESTS.md` and `UNIT-TESTS.md` docs are indexes of those changes plus a coverage map; they
do not contain test source code.

The review file has exactly three top-level sections in fixed order — `## Out-of-scope changes`,
`## Acceptance criteria not met`, `## Implementation issues` — with numbered issues restarting at 1 inside each section.
Do not introduce new top-level sections when editing `review-code/SKILL.md`.

## Editing tips

- When changing a workflow step (e.g. how gap questions are asked, how filenames are derived, the CLAUDE.md
  precondition), apply the change to all five pipeline skills so they stay consistent.
- There are no commands to run, lint, or test. Validation of a skill change is by reading the diff against the
  conventions above.
