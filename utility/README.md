# Utility

Each skill here is invoked on its own and shares no artifact chain with any other. See `../README.md` for installation.

## `init-claude-md`

Run `/init-claude-md` inside any repo to generate a minimal `CLAUDE.md` at its root from a survey of the repo's files plus a short interview — or, if a `CLAUDE.md` already exists, to propose a diff
against it.

## `pi-extension`

Run `/pi-extension` to create a new extension for the pi coding agent or update an existing one. It covers what every extension needs (the default-export factory, the event lifecycle,
`ExtensionContext`/ `ExtensionAPI`, placement, and modes), then points to the capability-specific pi docs for tools, commands, hooks, UI, providers, and packaging.

## `standalone-review`

Run `/standalone-review` to review a set of code changes (file paths, a directory, a git diff range, or the uncommitted working tree) against loose context — a free-text intent, a pasted ticket, or a
document you point it at — or, with no context, for correctness and convention compliance alone. It writes the findings to a `REVIEW.md`.
