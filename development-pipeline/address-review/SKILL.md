---
name: address-review
description: Validate review findings, fix confirmed issues, and update existing pipeline documents.
disable-model-invocation: true
---

Flow: `spec → plan → test → cross-check → implement → review-code → address-review`. `test` runs before `implement` (test-first) or after it. Stages may be skipped; `spec → plan → implement` is a valid short flow.

## Inputs

- A spec folder path or its review file. Expected folder: `specs/<kebab-title>/`. The folder must contain one file ending with `SPEC.md` and its matching `REVIEW.md`.
- Picked up automatically from that folder when present, skipped without penalty when absent: `PLAN.md`, `TEST.md`, `IMPLEMENT.md`, and `CROSS-CHECK.md`. Derive each filename by replacing the
  trailing `SPEC.md` in the spec filename.

## Workflow

1. Read the documents. Locate the single file ending with `SPEC.md` and read it in full. Derive related filenames by replacing that suffix. Read the matching `REVIEW.md` and every present
   optional document in full. Read the project instructions.
2. Validate each review finding. Read the cited code, related tests, and relevant spec Context files. Check the claim against the documents and current code. The spec defines intended behavior.
   Do not treat review claims or earlier verification results as proof. Distinguish confirmed issues from false findings, issues already fixed, and issues that cannot be validated.
3. Fix confirmed issues directly. Do not ask questions or request approval. Make only the required code and test changes. Add or correct regression tests against the specified behavior. Do not
   change requirements or weaken assertions merely to dismiss a finding. A finding whose fix needs a requirement change stays unresolved. Leave blocked or uncertain issues unresolved and continue
   with independent fixes.
4. Verify the changes. Run the affected acceptance checks and the full project test suite unless the plan or user excludes it. Keep an issue unresolved if its correction or verification is
   incomplete. Record actual results; do not claim that failed or unrun checks passed.
5. Update existing documents in place. Rewrite affected content as if originally authored for the corrected version. Preserve document structures. Do not create documents or append repair
   history.
    - Update the spec only where a fix changed an identifier, path, or Context pointer it names. Do not change Goal, Scope, Out of scope, Current behavior, Expected behavior, Acceptance criteria,
      Examples, or Notes. Keep the spec about WHAT and WHY.
    - Update the plan where needed. Keep it about HOW. Integrate corrections into the existing Steps and Acceptance criteria.
    - Update test file lists, test types, test names, and coverage. Map each Coverage row to its source requirement in the spec or plan. Update the `Results` table when present with the checks
      from step 4.
    - Update implementation file lists and acceptance results for the complete change, not only this repair. Use `verified`, `failed`, or `unverified` according to current checks. Do not
      retain success claims invalidated by the changes.
    - In `REVIEW.md`, change only the tag at the end of each issue heading: append ` [fixed]` for verified fixes, including earlier fixes; append ` [invalidated]` for disproved findings. Replace
      an existing tag instead of adding a second one. Leave unresolved issues untagged. Preserve every issue and all other content.
    - In `CROSS-CHECK.md`, do not resolve an open finding by choosing an answer; each one needs a user decision. Remove a finding only when the updated documents and tests no longer contain the
      conflict. Update remaining evidence and line numbers. Delete the report if no findings remain.
6. Confirm briefly in chat. State the fixes, remaining issues or blockers, open cross-check findings, and check results.

## Fix discipline

- Preserve unrelated work and follow existing code and test conventions.
- Use version control only for read-only inspection.
- Do not install dependencies or change the environment. Record a check that cannot run without them as `unverified`.
- Complete removals, including obsolete tests, imports, references, and fallback code.

## Content rules

- Use short declarative sentences and explicit identifiers.
- Keep documents self-contained. Leave no TODOs, stubs, or placeholders.

## Stop conditions

- No folder or review file is provided.
- The folder contains no file ending with `SPEC.md`, or contains multiple.
- The spec or its matching `REVIEW.md` is missing, empty, or unreadable.
