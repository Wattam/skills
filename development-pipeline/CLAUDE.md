## What this category is

The workflow runs `spec → plan → {integration-tests, unit-tests} → cross-check → implement → review-code`. Each stage writes a markdown artifact into `specs/<kebab-title>/`.
Keep both `unit-tests` and `integration-tests` consistent if you change how tests are handled.

## Shared conventions

- Outputs are self-contained.
- No `<TBD>` or TODO placeholders.
- Output filenames derive from the input filename.
