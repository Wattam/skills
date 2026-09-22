---
name: adress-review
description: Validate review findings, fix confirmed issues, and update existing pipeline documents.
disable-model-invocation: true
---

Flow: `spec → plan → test → cross-check → implement → review-code → adress-review`.

## Inputs

A spec folder path or its review file. Expected folder: `specs/<kebab-title>/`.

`TEST.md` and `CROSS-CHECK.md` are optional. Skip missing documents.

## Workflow

1. Read the documents. Locate the single file ending with `SPEC.md` and read it in full. Derive related filenames by replacing that suffix. Read the matching `REVIEW.md` and all present `PLAN.md`, `TEST.md`, `IMPLEMENT.md`, and `CROSS-CHECK.md` files in full. Read the project instructions. Stop if the spec or review is missing, ambiguous, empty, or unreadable.
2. Validate each finding. Read the cited code, related tests, and relevant spec Context files. Check the claim against the documents and current code. The spec defines intended behavior. Do not treat review claims or earlier verification results as proof. Distinguish confirmed issues from false findings, issues already fixed, and issues that cannot be validated.
3. Fix confirmed issues directly. Do not ask questions or request approval. Make only the required code and test changes. Add or correct regression tests against the specified behavior. Do not change requirements or weaken assertions merely to dismiss a finding. Leave blocked or uncertain issues unresolved and continue with independent fixes.
4. Verify the changes. Run the affected acceptance checks and the full project test suite unless the plan or user excludes it. Keep an issue unresolved if its correction or verification is incomplete. Record actual results; do not claim that failed or unrun checks passed.
5. Update existing documents in place. Rewrite affected spec, plan, test, and implementation content as if originally authored for the corrected version. Preserve document structures. Do not create documents or append repair history.
    - Update the spec and plan where needed. Keep the spec about WHAT and WHY, and the plan about HOW. Integrate corrections into the existing content and steps.
    - Update test file lists, test types, test names, and coverage. Map each Coverage row to its source requirement in the spec or plan.
    - Update implementation file lists and acceptance results for the complete change, not only this repair. Use `verified`, `failed`, or `unverified` according to current checks. Do not retain success claims invalidated by the changes.
    - In `REVIEW.md`, change only the tag on each issue heading: `[fixed]` for verified fixes, including earlier fixes; `[invalidated]` for disproved findings. Leave unresolved issues untagged. Preserve every issue and all other content.
    - Keep only unresolved findings in `CROSS-CHECK.md`. Update remaining evidence and line numbers. Delete that report if no findings remain.
6. Confirm briefly in chat. State the fixes, remaining issues or blockers, and check results.

## Constraints

- Preserve unrelated work and follow existing code and test conventions.
- Use version control only for read-only inspection.
- Complete removals, including obsolete tests, imports, references, and fallback code.
- Keep documents self-contained. Leave no TODOs, stubs, or placeholders.
