# Utility

Each skill here is invoked on its own and shares no artifact chain with any other. See `../README.md` for installation.

## `init-claude-md`

Run `/init-claude-md` inside any repo to write a minimal `CLAUDE.md` at its root from an investigation of the repo plus a short interview. Every line must earn its place: only information an agent
could not infer from the repo itself.

## `pi-extension`

Run `/pi-extension` to create a new extension for the Pi coding agent or update an existing one. It locates the official docs shipped with the installed Pi package and routes you to the sections
and examples each capability needs (tools, commands, hooks, UI, providers, packaging).

## `standalone-review`

Run `/standalone-review` to review a set of code changes (file paths, a directory, a git diff range, or the uncommitted working tree) against loose context — a free-text intent, a pasted ticket, or a
document you point it at — or, with no context, for correctness and convention compliance alone. When it finds issues, it writes them to a `REVIEW.md`; when it finds none, it writes no file.
