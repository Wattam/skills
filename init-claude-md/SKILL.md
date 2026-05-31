---
name: init-claude-md
description: Generate a minimal CLAUDE.md for the current repository, or propose a diff against an existing one. CLAUDE.md loads into every Claude Code session — include only what Claude would otherwise get wrong.
disable-model-invocation: true
---

# Init CLAUDE.md

## Inputs

- None. Operate on the current working directory.

## Scope boundary

Treat the current working directory as the filesystem root for this task. Never read, list, or reference paths outside
it. Example: invoked in `/home/user/projects/foo`, `/home/user/projects/` and anything above it is off-limits — only
`foo/` and its subfolders are in scope.

## Workflow

1. **Phase 1 — Survey.** Read, in scope, every file present from this list: manifests (`package.json`, `Cargo.toml`,
   `pyproject.toml`, `go.mod`, `pom.xml`), `Makefile`, CI config (`.github/workflows/*`, `.gitlab-ci.yml`,
   `.circleci/config.yml`, etc.), `README*`, existing `CLAUDE.md`, `AGENTS.md`, `.cursor/rules`, `.cursorrules`,
   `.windsurfrules`, `.clinerules`, `.mcp.json`. From these, detect:
    - Non-standard build/test/lint commands
    - Languages, frameworks, package manager
    - Project structure (monorepo, multi-module, single)
    - Style rules diverging from language defaults
    - Required env vars, gotchas, workflow quirks

   Track what the files alone cannot reveal — these become Phase 2 questions.

2. **Phase 2 — Interview.** Ask only what the survey could not answer: undocumented commands, gotchas, env setup,
   testing quirks.
    - Ask one question at a time.
    - Include a recommendation only when evidence supports one; never invent one.
    - Wait for a answer before asking the next question.
    - Stop when no gaps remain.

3. **Phase 3 — Write.** If no `CLAUDE.md` exists, write a new one at `./CLAUDE.md`. If one already exists, do not
   overwrite — instead, present the proposed changes as a unified diff in the chat with one-line reasoning per change,
   and wait for the user to accept before writing.

4. **Confirm** with a one-line message naming the file written (or the diff presented for review).

## Content rules

- Every line must pass: "Would Claude make mistakes without this?" If no, cut it.
- Write tersely and LLM-optimized: short imperative rules, concrete examples over prose, no redundancy, no filler. Each
  item stands on its own.
- Be specific: "Use 2-space indentation in TypeScript" beats "format code properly."
- Only write facts derived from files read in Phase 1 or interview answers in Phase 2. Do not invent sections like "
  Common Development Tasks" or "Tips for Development."
- For long or volatile content (API docs, references), use `@path/to/file` imports so Claude reads the current version
  on demand instead of inlining it.

## Required preamble

Begin the file with exactly:

```
# CLAUDE.md

This file provides guidance to coding agents when working with code in this repository.
```

## Include

- One-line description of what the project does
- Build/test/lint commands Claude cannot infer (non-standard scripts, flags, sequences)
- Style rules diverging from language defaults (e.g., "prefer `type` over `interface`")
- Testing quirks (e.g., "run single test: `pytest -k 'test_name'`")
- Required env vars and setup steps
- Non-obvious gotchas or architectural decisions

## Exclude

- Anything about git, branches, commits, PRs, or hosting platforms (GitHub, GitLab, Bitbucket, etc.)
- Meta-preferences ("plan first", "be terse", "explain tradeoffs")
- File or component listings — Claude discovers these by reading code
- Standard language conventions
- Generic advice ("write clean code", "handle errors")
- Commands obvious from manifests (`npm test`, `cargo test`, `pytest`)
- Long or volatile content (API docs, references) — use `@path/to/file` imports instead

## Stop conditions

- Current working directory contains none of the surveyed files and the user provides no interview answers → tell the
  user there is nothing concrete to record, then stop.
- User declines to answer an interview question → drop that gap and continue with what is known.
- Existing `CLAUDE.md` is present and the user rejects the proposed diff → leave the file untouched, then stop.
