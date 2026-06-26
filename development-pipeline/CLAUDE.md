# CLAUDE.md

This file provides guidance to coding agents when working with code in this repository.

The repository-wide authoring rules in `../CLAUDE.md` apply to every skill here; this file adds the conventions specific to the development-pipeline category.

## What this category is

The workflow runs `spec → plan → {integration-tests, unit-tests} → cross-check → implement → review-code`. Each stage writes a markdown artifact into `specs/<kebab-title>/`, and downstream stages read
the upstream artifacts from that folder. `README.md` documents the ordering, inputs, and artifact layout.

Treat the set as a closed pipeline: the stages, their order, and the artifact names form one interdependent contract — a change to one stage's input or output must be reflected in the stages next to
it.

The test stages (`unit-tests`, `integration-tests`) write the tests that `implement` runs in full as one of its acceptance criteria, unless the plan or the user opts out. Keep both sides consistent if
you change how tests are handled.

## Each skill still stands alone

Because the stages chain, do not let a skill assume a previous stage ran in the chat. Per the empty-context rule in `../CLAUDE.md`, each skill re-ingests its input artifact from disk (e.g. `plan`
lists the spec folder and reads the `SPEC.md` itself).

## Shared conventions

These hold across every pipeline skill. When you change one of them in a skill, apply the same change to all the others:

- Gap questions are asked one at a time in plain chat text; a recommendation is included only when evidence supports one, never invented.
- Outputs are self-contained: inline every name, path, signature, and value needed to act on the artifact; never substitute a reference like "see the spec".
- No `<TBD>` or TODO placeholders.
- Output filenames derive from the input filename: replace the trailing `SPEC.md` or `PLAN.md` with the stage's suffix.
