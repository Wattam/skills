---
name: cross-check
description: Cross-check a specification, implementation plan, and test documents for inconsistencies.
disable-model-invocation: true
---

# Cross-check

## Inputs

- A folder path containing a file ending with `SPEC.md` and a file ending with `PLAN.md`.
- Pre-implementation tests, picked up automatically:
    - The folder's `UNIT-TESTS.md` and/or `INTEGRATION-TESTS.md` docs, if present, plus the test files they index.
    - Optionally, test files or directories the user names in the invocation.

## Workflow

1. **Precondition.** If no `CLAUDE.md` exists in the current working directory, tell the user the skill requires project
   context from `CLAUDE.md` and stop.
2. **Locate and ingest the spec and plan.** List the folder contents. Identify the file ending with `SPEC.md` and the
   file ending with `PLAN.md`, and read both in full. Treat the spec as the authority on intended behavior (WHAT) and
   the plan as the authority on the intended changes (HOW).
3. **Resolve and read the pre-implementation tests.** If the folder contains `UNIT-TESTS.md` and/or
   `INTEGRATION-TESTS.md`, read them in full, then read each test file listed in their `Created`, `Edited`, and
   `Deleted` tables. Also read any test files or directories the user named in the invocation. If a test file an index
   claims to exist cannot be read, treat its claimed coverage as unmet and record the affected items as inconsistencies
   in step 4; do not stop. If no test doc is present and the user named no test paths, treat tests as absent and skip
   the **Spec ↔ tests** and **Plan ↔ tests** cross-checks.
4. **Cross-check the documents.** Compare the documents against one another along three axes. For each finding, capture
   the exact location in each document (spec section/criterion, plan Step number, test `file::test_name`) and the
   conflicting statements. Treat each of these as a potential inconsistency:
    - **Spec ↔ plan**
        - A Scope item (feature spec) or Expected-behavior bullet (bug-fix spec) in the spec has no corresponding plan
          Step.
        - A plan Step introduces behavior not traceable to any Scope item, Expected-behavior bullet, Note, or Context
          entry in the spec (the plan does more than the spec asks).
        - A spec Acceptance criterion is addressed by no plan Step and by no plan Acceptance criterion.
        - A plan Acceptance criterion contradicts a spec Acceptance criterion or has no basis in the spec.
        - Identifier mismatch: a file path, symbol, signature, endpoint, table, or column is named one way in the spec's
          Context and a different way in the plan's Steps.
        - Behavior contradiction: a spec Example or stated behavior gives an input → output that a plan Step contradicts
          for the same input.
        - A spec Note/constraint (auth, ordering, idempotency, perf, side effects, null/empty handling) is reflected by
          no plan Step, or is contradicted by one.
        - The spec lists something under Out of scope, but a plan Step changes it.
        - A spec or plan `Open questions` entry is unresolved and a mapped item depends on it.
    - **Spec ↔ tests**
        - A spec Acceptance criterion is mapped in no test doc's Coverage table and asserted by no read test.
        - A test asserts an input → output that contradicts a spec Example or Acceptance criterion.
        - A test exercises behavior the spec lists under Out of scope, or behavior traceable to no spec item.
        - A spec edge case (null, empty, unauthorized, oversized, concurrent, …) is asserted by no test.
        - For bug-fix specs: no test reproduces the Current behavior to prove the fix, or the Expected behavior is
          asserted by no test.
    - **Plan ↔ tests**
        - A test targets a symbol, signature, or path that differs from what the plan introduces or modifies.
        - A test asserts behavior that contradicts a plan Step.
        - A plan Step removes a symbol, branch, or behavior that a test still exercises, with no corresponding test
          deletion recorded.
        - A plan Step that introduces or modifies a symbol is exercised by no test.
        - A test doc's Coverage table cites a plan Acceptance criterion the plan does not contain.
5. **Ask about ambiguous divergences.** For each apparent divergence where the evidence cannot decide whether it is a
   real inconsistency or an intended difference (e.g. the plan deliberately narrows the spec, or a test covers behavior
   beyond the spec by design):
    - Ask one question at a time.
    - Question shape: "<artifact A location> states <X>; <artifact B location> states <Y>. Is this divergence
      intended?"
    - Include a recommendation only when evidence supports one; never invent one.
    - Wait for an answer before asking the next question.
    - Based on the answer: drop the divergence (intended) or record it as an inconsistency in the matching section. If
      the user declines to answer, record it as an inconsistency.
    - Stop when every ambiguous divergence has an answer.
6. **Write the cross-check** to a markdown file inside the same folder. Filename: replace the trailing `SPEC.md` with
   `CROSS-CHECK.md` (e.g. `add-promotion-archive-job-SPEC.md` → `add-promotion-archive-job-CROSS-CHECK.md`). Overwrite
   if it exists.
7. **Confirm** with a one-line message naming the file written and the number of inconsistencies found.

## Content rules

- Write in English, optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical
  flourish.
- The file contains **only the inconsistencies found and where they occur**. Do not include:
    - Summaries of the spec, plan, or tests
    - Items that agree across the documents
    - Praise or "looks good" notes
    - Restatements of acceptance criteria that are satisfied everywhere
    - Meta-commentary about the cross-check process

  If you catch yourself writing "overall", "consistent", "matches", "as expected", "good", "also", "additionally", or
  "note that" — delete that sentence.
- **Report the conflict, never the fix.** State which documents disagree and what each says. Do not prescribe how to
  reconcile them, which document to change, or what to write instead — that is the next stage's work. If you catch
  yourself writing "should change", "fix by", "instead", "in order to", or "so that" — delete that sentence.
- Every inconsistency must be **self-contained**: inline the conflicting statement from each document. Naming the
  document and the location is required, but a citation never substitutes for the statement itself — never write "see
  the spec" or "see Step 4" in place of the content.
- One numbered heading per logical inconsistency. The same inconsistency observed at multiple sites is one issue with
  one table (one row per site or per document). Different inconsistencies are separate issues even when they involve the
  same document.
- Use a table for evidence; quote the offending text only when it is shorter than the explanation and clarifies the
  issue.
- No TODOs, no "figure out later", no placeholders like `<TBD>`. A genuinely uncertain divergence is either asked about
  in step 5 or omitted.
- If no inconsistencies are found, the file contains only the title and a single line: `No inconsistencies found.`

## Investigation discipline

- Read nothing beyond the sources named in steps 2 and 3.
- Do not read production code, build files, or CI configuration. The plan describes changes not yet applied, so
  production code does not reflect it and is not a valid reference at this stage.
- Do not run tests, install dependencies, or trigger any code execution.
- Do not modify the spec, the plan, the test docs, or the test files. The only file this skill writes is its own
  `CROSS-CHECK.md` report.

## Cross-check file structure

The file has exactly three top-level sections, in this order. Each section holds zero or more numbered inconsistencies.
Within a section, number them sequentially starting at 1 and reset the counter at each section.

```md
# Cross-check: <short title taken from the spec>

## Spec ↔ plan

### 1. <inconsistency title>

<1–2 sentences: what disagrees and which items are involved.>

| Artifact | Location        | Statement                       |
|----------|-----------------|---------------------------------|
| <A>      | <location in A> | <quoted or paraphrased content> |
| <B>      | <location in B> | <quoted or paraphrased content> |

## Spec ↔ tests

### 1. <inconsistency title> — same entry shape as above

## Plan ↔ tests

### 1. <inconsistency title> — same entry shape as above
```

Every entry has a title, 1–2 sentences naming what disagrees, then one evidence table whose two `Artifact` rows are
that section's pair — Spec/Plan, Spec/Tests, or Plan/Tests. Each `Location` is a spec section/criterion, a plan
`Step <n>`, or a test `<file>::<test_name>`. Omit any section that has no entries; when tests are absent, the
**Spec ↔ tests** and **Plan ↔ tests** sections are omitted. Do not add any other top-level section.

## Stop conditions

- No folder provided → ask for one, then stop.
- Folder contains no file ending with `SPEC.md` → tell the user, then stop.
- Folder contains no file ending with `PLAN.md` → tell the user, then stop.
- Folder contains multiple files ending with `SPEC.md` → ask which one to use, then wait for their answer.
- Folder contains multiple files ending with `PLAN.md` → ask which one to use, then wait for their answer.
- Spec or plan is unreadable or empty → tell the user, then stop.
