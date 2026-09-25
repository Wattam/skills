## What this category is

The workflow runs `spec → plan → test → cross-check → implement → review → address-review`. Pipeline documents are stored in `specs/<kebab-title>/`. `address-review` updates existing documents and creates none.
Keep `plan`, `test`, `cross-check`, `implement`, `review`, and `address-review` consistent when you change how tests are handled.
Each skill opens with the same `Flow:` line. Update every copy when the flow changes.

## Shared conventions

- Outputs are self-contained.
- No `<TBD>` or TODO placeholders.
- Output filenames derive from the input filename.
- Version control is read-only in every stage.
- A stage that writes a report only when findings exist deletes its stale report on a clean run.
