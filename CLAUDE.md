## What this repo is

Skill definitions. Skills are grouped into category folders. Each category has its own `CLAUDE.md` with the conventions specific to it:

- `development-pipeline/` — feature-development workflow (spec → plan → tests → cross-check → implement → review). See `development-pipeline/CLAUDE.md`.
- `utility/` — standalone skills that each do one self-contained job. See `utility/CLAUDE.md`.

## Authoring rules for every SKILL.md

- Frontmatter is required: `name` (must match the folder name), `disable-model-invocation: true`.
- Write for agent consumption: short declarative sentences, explicit identifiers, no rhetorical flourish. Applies to the skill body, inline templates, and the outputs the skills produce.
- Harness-agnostic: never name proprietary tools tied to a specific agent harness.
- Each skill must work from an empty context: a SKILL.md is self-contained and never assumes another skill ran first or relies on prior chat state.
