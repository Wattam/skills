---
name: standalone-address-review
description: Validate findings from any code review and fix confirmed issues without pipeline documents.
disable-model-invocation: true
---

## Inputs

- A review provided as inline text or a file path. Accept any review format. If neither is supplied, use `REVIEW.md` in the current working directory.
- Optional context: intended behavior, requirements, constraints, examples, or paths to documents that define them.
- Optional repository path. Default to the current working directory.

## Workflow

1. Read the inputs. Read the review, supplied context documents, and project instructions. Identify each finding separately. Do not require a spec, plan, stage report, or a review produced by another skill. Stop if the review is missing, empty, unreadable, or ambiguous.
2. Validate each finding. Read the cited code, related tests, callers, and relevant project documents. Locate current code when review line numbers are stale. Check each claim against current evidence and stated requirements. Do not treat review claims or earlier check results as proof. Classify each finding as confirmed, disproved, already fixed, or unresolved. If intended behavior is not defined, assess correctness and existing contracts only. Leave findings that depend on unknown intent unresolved.
3. Fix confirmed issues. Make the required code and test changes directly. Do not request approval for confirmed fixes. Keep changes limited to the findings. Add or correct regression tests that check required behavior, not implementation details. Do not change requirements or weaken assertions to dismiss a finding. Leave blocked or uncertain findings unresolved and continue with independent fixes.
4. Verify the changes. Run relevant checks and the full project test suite unless the user or project instructions exclude it. Verify earlier fixes before marking them fixed. Keep a finding unresolved if its correction or verification is incomplete. Record failed and unrun checks accurately.
5. Report the results. For each finding, state `fixed`, `invalidated`, or `unresolved` with a short reason. Use `fixed` only for verified corrections, including earlier fixes. Use `invalidated` only for disproved claims. Include check results and blockers. If the review is a local file, update each finding's status in place. Preserve its wording, evidence, order, and structure. Use a heading tag when available; otherwise add a status line next to the finding. Replace existing status annotations rather than adding duplicates. For inline reviews, report statuses in chat only. Do not create a report file.
6. Confirm briefly. State the fixes, remaining issues, and check results in chat.

## Constraints

- Preserve unrelated work and follow existing code and test conventions.
- Use version control only for read-only inspection.
- Complete removals, including obsolete tests, imports, references, and fallback code.
- Update related code documentation only when required by a fix. Do not rewrite supplied requirements or maintain pipeline reports.
- Do not install dependencies or change the environment without user approval.
- Leave no TODOs, stubs, or placeholders.
