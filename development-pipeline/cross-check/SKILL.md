---
name: cross-check
disable-model-invocation: true
---

## Main Objective

Cross-check a specification, implementation plan, and test documents for inconsistencies.

## Inputs

A folder path (expected location: `specs/<kebab-title>/`) containing up to four docs ending with:

- `SPEC.md` — mandatory.
- `PLAN.md` — mandatory.
- `UNIT-TESTS.md` — optional.
- `INTEGRATION-TESTS.md` — optional.

## Workflow

1. **Locate and ingest the spec and plan.** List the folder contents, identify the file ending with `SPEC.md` and the file ending with `PLAN.md`, and read both in full. The spec is the authority on
   intended behavior (WHAT); the plan is the authority on intended changes (HOW).
2. **Read the test docs.** If the folder contains `UNIT-TESTS.md` and/or `INTEGRATION-TESTS.md`, read them in full, then read each test file listed in their `Created`, `Edited`, and `Deleted` tables.
   If a listed test file cannot be read, treat its claimed coverage as unmet and record the affected items as inconsistencies in step 3. If no test doc is present, skip the **Spec ↔ tests** and
   **Plan ↔ tests** axes.
3. **Cross-check the documents** along three axes. For each finding, capture the exact location in each document (spec section/criterion, plan Step number, test `file::test_name`) and the conflicting
   statements. Treat each of these as a potential inconsistency:
    - **Spec ↔ plan**
        - A Scope item (feature spec) or Expected-behavior bullet (bug-fix spec) has no corresponding plan Step.
        - A plan Step introduces behavior not traceable to any Scope item, Expected-behavior bullet, Note, or Context entry (the plan does more than the spec asks).
        - A spec Acceptance criterion is addressed by no plan Step and by no plan Acceptance criterion.
        - A plan Acceptance criterion contradicts a spec Acceptance criterion or has no basis in the spec.
        - Identifier mismatch: a file path, symbol, signature, endpoint, table, or column is named one way in the spec and a different way in the plan.
        - Behavior contradiction: a spec Example or stated behavior gives an input → output that a plan Step contradicts for the same input.
        - A spec Note/constraint (auth, ordering, idempotency, perf, side effects, null/empty handling) is reflected by no plan Step, or is contradicted by one.
        - The spec lists something under Out of scope, but a plan Step changes it.
    - **Spec ↔ tests**
        - A spec Acceptance criterion is mapped in no Coverage table and asserted by no read test.
        - A test asserts an input → output that contradicts a spec Example or Acceptance criterion.
        - A test exercises behavior the spec lists under Out of scope, or behavior traceable to no spec item.
        - A spec edge case (null, empty, unauthorized, oversized, concurrent, …) is asserted by no test.
        - For bug-fix specs: no test reproduces the Current behavior to prove the fix, or the Expected behavior is asserted by no test.
    - **Plan ↔ tests**
        - A test targets a symbol, signature, or path that differs from what the plan introduces or modifies.
        - A test asserts behavior that contradicts a plan Step.
        - A plan Step removes a symbol, branch, or behavior that a test still exercises, with no corresponding test deletion recorded.
        - A plan Step that introduces or modifies a symbol is exercised by no test.
        - A Coverage table cites a plan Acceptance criterion the plan does not contain.
4. **Interview me about every ambiguous divergence** — one where the evidence cannot decide whether it is a real inconsistency or an intended difference (e.g. the plan deliberately narrows the spec).
   One question at a time, until none remain. Include a recommendation when evidence supports one; never invent one. Based on the answer, drop the divergence (intended) or record it as an
   inconsistency.
5. **Write the cross-check**, only if at least one inconsistency was found, to a markdown file inside the same folder. Filename: replace the trailing `SPEC.md` with `CROSS-CHECK.md`. Overwrite if it
   exists. If no inconsistencies were found, write no file.
6. **Confirm** with a one-line message: the file written and the number of inconsistencies found, or that none were found and no file was written.

## Content rules

- Optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical flourish.
- **Report the conflict, never the fix.** State which documents disagree and what each says; how to reconcile them is the next stage's work.
- Every inconsistency must be **self-contained**: inline the conflicting statement from each document. Never write "see the spec" or "see Step 4" in place of the content.
- One numbered heading per logical inconsistency; the same inconsistency observed at multiple sites is one issue with one row per site. Use a table for evidence.
- Do not include summaries of the documents, items that agree, praise, or meta-commentary.
- No TODOs or `<TBD>` placeholders — a genuinely uncertain divergence is either asked about in step 4 or omitted.

## Investigation discipline

- Read nothing beyond the sources named in steps 1 and 2 — in particular no production code, build files, or CI configuration. The plan describes changes not yet applied, so production code is not a
  valid reference at this stage.
- Do not run tests, install dependencies, or trigger any code execution.
- Do not modify the spec, the plan, the test docs, or the test files. The only file this skill writes is its own `CROSS-CHECK.md` report.

## File structure

Up to three top-level sections, in this fixed order, and no others; omit any section that has no entries. Within a section, number inconsistencies sequentially starting at 1.

```md
# Cross-check: <short title taken from the spec>

## Spec ↔ plan

### 1. <inconsistency title>

<1–2 sentences: what disagrees and which items are involved.>

| Artifact | Location           | Statement                       |
|----------|--------------------|---------------------------------|
| Spec     | <location in spec> | <quoted or paraphrased content> |
| Plan     | <location in plan> | <quoted or paraphrased content> |

## Spec ↔ tests

### 1. <inconsistency title> — same entry shape; `Artifact` rows are Spec and Tests

## Plan ↔ tests

### 1. <inconsistency title> — same entry shape; `Artifact` rows are Plan and Tests
```

## Stop conditions

- No folder provided.
- Folder is missing a file ending with `SPEC.md` or `PLAN.md`, or contains multiple of either.
- Spec or plan is unreadable or empty.
