# CLAUDE.md

This file provides guidance to coding agents when working with code in this repository.

## What this repo is

Claude Code skill definitions. No application code, build system, or tests. Each top-level folder is one
skill whose only file is `<skill>/SKILL.md`; editing a skill means editing that markdown. Seven skills form
a pipeline (spec → plan → {integration-tests, unit-tests} → cross-check → implement → review-code);
`init-claude-md` is standalone. `README.md` documents the pipeline ordering, inputs, and artifact layout.

## Authoring rules for SKILL.md files

- Frontmatter is required: `name` (must match the folder name), `description` (one line),
  `disable-model-invocation: true`.
- Write for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical flourish.
  Applies to the skill body, inline templates, and the outputs the skills produce.
- Harness-agnostic phrasing: never name proprietary tools tied to a specific agent harness. Describe the
  action instead ("search and read the codebase", "ask in plain chat text"). Ordinary verbs ("read the
  file") and real shell commands (`git diff`) are fine.
- The pipeline skills share conventions: gap questions asked one at a time in plain chat, recommendations
  only when evidence supports them, self-contained outputs, no `<TBD>`/TODO placeholders (unanswered gaps
  go under `## Open questions`), filenames derived from the spec/plan filename. When you change a shared
  convention in one skill, apply the same change to all seven. Exception: `implement` has no `## Open questions`
  section — an unanswered gap stops the run at the blocked Step instead.
- Each skill's SKILL.md is the authority on its stage-specific rules (drift bans, banned words, output
  structure, read/write limits). Never loosen a ban already stated in the file you are editing.

## Validation

- There is nothing to build, lint, or run. Validate a change by reading the diff against the rules above
  and the edited skill's own SKILL.md.
- Installed copies do not pick up edits — re-run `./install-skills.sh` after changing a skill.
