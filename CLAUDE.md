# CLAUDE.md

This file provides guidance to coding agents when working with code in this repository.

## What this repo is

Claude Code skill definitions. No application code, build system, or tests. Each skill is one folder whose only file is `SKILL.md` (its `name` matches the folder name); editing a skill means editing
that markdown.

Skills are grouped into category folders. Each category has its own `CLAUDE.md` with the conventions specific to it — read that file before editing a skill in the category:

- `development-pipeline/` — skills that chain into one feature-development workflow (spec → plan → tests → cross-check → implement → review). See `development-pipeline/CLAUDE.md`.
- `utility/` — standalone skills that each do one self-contained job. See `utility/CLAUDE.md`.

`README.md` documents each category and how its skills are used.

## Formatting (all markdown files)

- Hard-wrap every markdown file in this repo (`SKILL.md`, `README.md`, `CLAUDE.md`) at a maximum of 200 columns. Reflow prose and list items to fill up to that width before wrapping.
- Leave fenced code blocks and table rows intact even when a row exceeds 200 columns; never split a table row across lines.

## Authoring rules for every SKILL.md

- Frontmatter is required: `name` (must match the folder name), `description` (one line), `disable-model-invocation: true`.
- Write for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical flourish. Applies to the skill body, inline templates, and the outputs the skills produce.
- Harness-agnostic phrasing: never name proprietary tools tied to a specific agent harness. Describe the action instead ("search and read the codebase", "ask in plain chat text"). Ordinary verbs
  ("read the file") and real shell commands (`git diff`) are fine.
- Each skill must work from an empty context: a SKILL.md is self-contained and never assumes another skill ran first or relies on prior chat state.
- Each skill's SKILL.md is the authority on its stage-specific rules (drift bans, banned words, output structure, read/write limits). Never loosen a ban already stated in the file you are editing.

## Validation

- There is nothing to build, lint, or run. Validate a change by reading the diff against the rules above, the category's `CLAUDE.md`, and the edited skill's own SKILL.md.
