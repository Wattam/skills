---
name: init-claude-md
description: Generate a minimal CLAUDE.md for the current repository.
disable-model-invocation: true
---

## Main Objective

Create a minimal CLAUDE.md containing only information an agent could not infer by investigating the repository. Every line must pass: "The agent would make mistakes without this?" If no, cut it.

## Workflow

1. **Phase 1 — Investigate repository:** Search, read and deeply analyze the files in the repository. List gaps: information needed but not inferable from the repository.
2. **Phase 2 — Interview:** Interview me about every gap, one question at a time, until none remain. Also question any niche information in a pre-existing CLAUDE.md.
3. **Phase 3 — Write:** Decide what is worth including, based on Phase 1 and 2, then write the assembled file to `./CLAUDE.md`.

## Content rules

- Write tersely: short imperative rules, concrete examples over prose. Each item stands on its own.
- Be specific: "Use 2-space indentation in TypeScript" beats "format code properly".

## Include

- Build/test/lint commands agents cannot infer.
- Style rules diverging from language defaults.
- Testing quirks.
- Non-obvious gotchas or architectural decisions.

## Exclude

- File or component listings — agents discover these by reading code.
- Standard language conventions.
- Generic advice.
- Commands obvious from manifests (`npm test`, `cargo test`, etc.).
- Long or volatile content (API docs, references).
- Generic introduction with `This file provides guidance to coding agents when working with code in this repository`.
