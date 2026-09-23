---
name: cross-check
description: Cross-check a specification, implementation plan, and test document for inconsistencies, then resolve each one interactively.
disable-model-invocation: true
---

Flow: `spec → plan → test → cross-check → implement → review-code → address-review`. `test` runs before `implement` (test-first) or after it. Stages may be skipped; `spec → plan → implement` is a valid short flow.

## Inputs

A folder path with the expected location `specs/<kebab-title>/`. The folder contains these documents:

- Exactly one file ending with `SPEC.md` — mandatory.
- Exactly one file ending with `PLAN.md` — mandatory.
- The matching test document — optional. Derive its filename by replacing the trailing `SPEC.md` in the spec filename with `TEST.md`.

## Workflow

1. Locate and ingest the spec and plan. List the folder contents. Identify the files ending with `SPEC.md` and `PLAN.md`. Read both in full. The spec is the authority on intended behavior. The plan is the authority on intended changes.
2. Read the test document. Derive its filename by replacing the trailing `SPEC.md` in the spec filename with `TEST.md`. If the folder contains that file, read it in full. Read each existing test file cited in its `Changes` and `Coverage` tables. Verify that each deleted file or named test is absent. Treat an unreadable expected file or an incomplete deletion as an inconsistency in step 4. If the matching test document is absent, skip the **Spec ↔ Tests** and **Plan ↔ Tests** axes.
3. Investigate the codebase. Search and read the codebase to locate the files, symbols, test suites, and existing patterns relevant to the check.
4. Cross-check the documents along three axes. For each finding, capture the exact location in each document. Use a spec section or criterion, a plan Step or criterion, and a test `file::test_name`. Capture the conflicting statements. Tag the finding as a **confirmed inconsistency** when the evidence shows a disagreement. Tag it as an **ambiguous divergence** when the evidence cannot show if the difference is intended. Collect all findings before the interview. Do not fix files yet. Treat each item as a potential inconsistency:
    - **Spec ↔ Plan**
        - A Scope item or Expected-behavior bullet has no matching plan Step.
        - A plan Step introduces behavior that does not trace to a Scope item, Expected-behavior bullet, Note, or Context entry.
        - A spec Acceptance criterion is addressed by no plan Step and no plan Acceptance criterion.
        - A plan Acceptance criterion contradicts a spec Acceptance criterion or has no basis in the spec.
        - A file path, symbol, signature, endpoint, table, or column has different identifiers in the two documents.
        - A plan Step contradicts a spec Example for the same input.
        - A spec constraint for authorization, ordering, idempotency, performance, side effects, or null and empty input has no matching plan Step or is contradicted by one.
        - A plan Step changes an item that the spec lists as out of scope.
    - **Spec ↔ Tests**
        - A Scope item, Expected-behavior bullet, Example, edge case, or spec Acceptance criterion has no Coverage row and no assertion in a read test.
        - A test asserts behavior that contradicts a spec Example or Acceptance criterion.
        - A test exercises behavior that the spec lists as out of scope or that does not trace to a spec item.
        - For a bug fix, no test uses the reproduction input from the Current behavior or Examples and asserts the corrected result defined by the Expected behavior. At least one test must cover both. It must not assert the old incorrect result.
        - A Coverage row cites a spec location or requirement that the spec does not contain.
    - **Plan ↔ Tests**
        - A test target has a symbol, signature, path, endpoint, or data shape that differs from the plan.
        - A test assertion contradicts a plan Step or plan Acceptance criterion.
        - A plan Step removes a target that a test still exercises, and no test deletion is recorded.
        - A testable behavior or target introduced or modified by a plan Step is exercised by no test.
        - A plan Acceptance criterion has no Coverage row and no assertion in a read test.
        - A Coverage row cites a plan Step or criterion that the plan does not contain.
5. Resolve every finding with me, one at a time. Include confirmed inconsistencies and ambiguous divergences. For each finding:
    - Present the conflict. Name the documents and quote each statement. State the open question for an ambiguous divergence. Include a recommendation when evidence supports one. Do not invent a recommendation.
    - Use my answer to reconcile the files. Determine the authoritative content and the required corrections.
    - Apply the fix immediately. Edit the spec, plan, test document, or test files as required. Keep the test document and test files synchronized. Clear one disagreement before you present the next.
    - Leave the finding open when no reconciliation is reached.
6. Write the cross-check only when step 5 leaves at least one finding open. Write it in the spec folder. Replace the trailing `SPEC.md` with `CROSS-CHECK.md` for the filename. Overwrite the file if it exists. List only open findings. Do not write a file when all findings are resolved. Delete an existing cross-check file when all findings are resolved, because it is stale.
7. Confirm with one line. Name the files fixed. Give the counts of findings fixed, dropped as intended, and left open. Name the report file, or state that no report was written because no finding remains open and name any stale report deleted.

## Content rules

- Use short declarative sentences and explicit identifiers.
- The report lists only open findings.
- Make each open finding self-contained. Include the conflicting statement from each document. Do not use a reference such as "see the spec" or "see Step 4" in place of the statement.
- Use one numbered heading for each logical inconsistency. Use one row for each location when the same inconsistency occurs at more than one location.
- Do not include document summaries, agreements, praise, or meta-commentary.

## Fix discipline

- Do not run tests, install dependencies, or trigger code execution.
- Do not modify production code.
- Use version control only for read-only inspection.

## File structure

The report contains only findings left open in step 5. Use the three top-level sections in this fixed order. Omit a section with no open findings. Number findings from 1 in each section.

```md
# Cross-check: <short title taken from the spec>

## Spec ↔ Plan

### 1. <inconsistency title>

<one or two sentences that identify the disagreement and the affected items.>

Open question: <decision required to reconcile the files.>

| Artifact | Location           | Statement                       |
|----------|--------------------|---------------------------------|
| Spec     | <location in spec> | <quoted or paraphrased content> |
| Plan     | <location in plan> | <quoted or paraphrased content> |

## Spec ↔ Tests

### 1. <inconsistency title>

<use the same entry structure with Spec and Tests artifact rows>

## Plan ↔ Tests

### 1. <inconsistency title>

<use the same entry structure with Plan and Tests artifact rows>
```

## Stop conditions

- No folder is provided.
- The folder does not contain exactly one file ending with `SPEC.md` and exactly one file ending with `PLAN.md`.
- The spec or plan is unreadable or empty.
