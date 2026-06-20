# CLAUDE.md

This file provides guidance to coding agents when working with code in this repository.

The repository-wide authoring rules in `../CLAUDE.md` apply to every skill here; this file adds the
conventions specific to the utility category.

## What this category is

Each skill here is invoked on its own and shares no artifact chain or input/output contract with any other —
adding one does not affect the others:

- `init-claude-md` — generates a minimal `CLAUDE.md` for the current repository, or proposes a diff against an
  existing one.
