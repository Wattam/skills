# Skills

A collection of [Claude Code skills](https://code.claude.com/docs/en/skills), grouped into categories. Each
skill is user-invoked only (`disable-model-invocation: true`) — Claude never triggers them on its own; you run
them as slash commands, e.g. `/spec`, `/init-claude-md`.

Each skill is a folder whose only file is `SKILL.md` — the full instructions the agent follows when you invoke
it. There is no application code, build, or test suite here; to change a skill's behavior, edit its markdown.

## Installation

```bash
./install-skills.sh
```

This runs `npx skills add . -g -a pi -a claude-code -y`, installing every skill in this repo globally for the
`claude-code` and `pi` agents. Re-run it after editing a skill to pick up changes.

## Categories

Each category has its own `README.md` (usage) and `CLAUDE.md` (authoring conventions):

- **`development-pipeline/`** — skills that chain into one feature-development workflow (spec → plan → tests →
  cross-check → implement → review). See `development-pipeline/README.md`.
- **`utility/`** — standalone skills, each doing one self-contained job. See `utility/README.md`.

See `CLAUDE.md` for the conventions shared across every skill.
