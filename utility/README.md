# Utility

Each skill here is invoked on its own and shares no artifact chain with any other. See `../README.md` for installation.

## `init-agents-md`

Run `/init-agents-md` inside any repo to write a minimal `AGENTS.md` at its root from an investigation of the repo plus a short interview. Every line must earn its place: only information an agent
could not infer from the repo itself.

## `pi-extension`

Run `/pi-extension` to create a new extension for the Pi coding agent or update an existing one. It locates the official docs shipped with the installed Pi package and routes you to the sections
and examples each capability needs (tools, commands, hooks, UI, providers, packaging).

## `solo-review`

Run `/solo-review` to review a set of code changes (file paths, a directory, a git diff range, or the uncommitted working tree) against loose context — a free-text intent, a pasted ticket, or a
document you point it at — or, with no context, for correctness and convention compliance alone. When it finds issues, it writes them to a `REVIEW.md`; when it finds none, it writes no file.

## `solo-address-review`

Run `/solo-address-review` with a review file or pasted findings to validate claims, fix confirmed issues, and run checks. It accepts any code review format and optional requirements or context. With no review input, it reads `REVIEW.md` in the current working directory. It updates finding statuses in a local review file or reports them in chat for pasted reviews. It requires no pipeline documents.
