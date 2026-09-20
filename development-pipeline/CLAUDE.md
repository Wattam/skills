## What this category is

The workflow runs `spec → plan → {integration-tests, unit-tests} → cross-check → implement → review-code → adress-review`. Pipeline documents are stored in `specs/<kebab-title>/`. `adress-review` updates existing documents and creates none.
Keep both `unit-tests` and `integration-tests` consistent if you change how tests are handled.

## Shared conventions

- Outputs are self-contained.
- No `<TBD>` or TODO placeholders.
- Output filenames derive from the input filename.
