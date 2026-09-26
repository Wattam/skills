# Skills

A collection of agent skills grouped into categories. Each skill is user-invoked only (`disable-model-invocation: true`). Invoke them as slash commands, e.g. `/spec`, `/init-agents-md`.

Each skill is a folder whose only file is `SKILL.md` — the full instructions the agent follows when you invoke it. There is no application code, build, or test suite here; to change a skill's
behavior, edit its markdown.

## Installation

On macOS or Linux:

```bash
./install-skills.sh
```

On Windows, run from PowerShell (requires Node.js and npm):

```powershell
.\install-skills.ps1
```

The shell script runs `npx skills add . -g -y -a universal -a pi -a claude-code`. The PowerShell script runs `npx skills add . -g -y -a pi`. Both run from the repository directory. The CLI installs canonical skill copies under `~/.agents/skills` and links skills into the selected agents' global directories: `universal` (`~/.config/agents/skills`), `pi` (`~/.pi/agent/skills`), and `claude-code` (`~/.claude/skills`). On Windows, the CLI uses directory junctions and falls back to copying if a link cannot be created. Re-run the relevant script after editing a skill to pick up changes.

## Categories

Each category has its own `README.md` (usage) and `AGENTS.md` (authoring conventions):

- **`development-pipeline/`** — skills that form one feature-development workflow (spec → plan → test → cross-check → implement → review → address-review). See `development-pipeline/README.md`.
- **`utility/`** — standalone skills, each doing one self-contained job. See `utility/README.md`.

See `AGENTS.md` for the conventions shared across every skill.
