---
name: review-code
description: Review code changes against a specification.
disable-model-invocation: true
---

## Inputs

- A spec folder path containing a file ending with `SPEC.md`. Expected location: `specs/<kebab-title>/`.
- Picked up automatically from that folder when present, skipped without penalty when absent:
    - `PLAN.md` — the stage reports grade Acceptance criteria against the **plan's** criteria, not the spec's; the plan is what maps their statuses back to the spec.
    - `IMPLEMENT.md` — files changed plus each plan Acceptance criterion's verified/unverified/failed status.
    - `UNIT-TESTS.md` and `INTEGRATION-TESTS.md` — test files changed plus a Coverage table mapping plan Acceptance criteria to tests.
- The code changes to review, provided as one of:
    - A list of file paths or a directory.
    - A git diff range (e.g. `main..HEAD`, a branch name, or a commit SHA).
    - Nothing → default to the uncommitted working tree (`git status` + `git diff HEAD`).

## Workflow

1. **Locate and ingest the docs.** List the folder contents, identify the file ending with `SPEC.md`, and read it in full; treat every section as a binding constraint. Read `PLAN.md` and every stage
   report present in full. For each absent doc, skip every check below that depends on it; its absence is not an issue.
2. **Enumerate the changed files.** Resolve the input to a concrete list of file paths plus their changed line ranges. Read each changed file in full from disk so review line numbers stay accurate.
   Also read the spec's Context-referenced files to judge pattern compliance, Note constraints, and existing conventions. Compare the files each stage report lists as created, edited, or deleted
   against the resolved list and carry every mismatch into step 4.
3. **Map each change to the spec.** For every changed hunk, determine which spec item it satisfies or violates: Scope bullet (feature spec), Expected-behavior bullet (bug-fix spec), Acceptance
   criterion, Context pointer, Example, or Note. Track unmapped changes (defined in step 5).
4. **Identify issues.** Treat each of these as a potential issue:
    - Scope item (feature spec) or Expected-behavior bullet (bug-fix spec) not implemented or only partially implemented
    - File or symbol modified that is outside the spec's stated scope — listed under Out of scope, or unrelated to the Expected behavior or Suspected cause (bug-fix spec)
    - Acceptance criterion not satisfied by the diff (no corresponding code, or the code contradicts it)
    - Example in the spec not honored (input → output mismatch, before → after mismatch)
    - Existing pattern named in Context not followed (a new ad-hoc pattern introduced instead)
    - Bespoke one-off utility, helper, or inline reimplementation added where an existing canonical utility in the codebase already provides the behavior
    - Code placed in the wrong package, module, or service — architectural drift from the codebase's established layering (e.g. business logic in a controller, persistence calls from a domain type)
    - Note/constraint violated (auth, ordering, idempotency, perf, side effects, role check, null/empty handling)
    - Edge case from the spec not handled
    - For bug-fix specs: the reproduction input still produces the wrong behavior, or the expected behavior is not produced
    - Suspected correctness bug introduced by the diff itself (null deref, off-by-one, swallowed exception, missing transaction boundary, leaked resource, SQL/XSS/command injection, broken
      authorization check)
    - Mismatch between a stage report and the change set: a file the report lists as created, edited, or deleted has no corresponding change in the diff, or a changed file is absent from the report
    - A stage report's claim about an Acceptance criterion that the diff does not bear out. Map each plan-graded status back to the spec criterion it serves, then check every spec criterion directly
      against the code and tests regardless of the report: a `verified` mark exempts nothing, an `unverified` or `failed` mark must still be checked, and a Coverage row may cite a test that is missing
      from the diff or does not actually exercise the criterion
    - A plan Acceptance criterion that contradicts a spec Acceptance criterion or has no basis in the spec (only when a plan is present); a `verified` plan criterion can hide a spec criterion the
      diff never satisfies — report the spec criterion under `## Acceptance criteria not met`
    - Test changes that reinforce the implementation instead of verifying the specified behavior — tautological or change-detector tests. Concrete forms:
        - Assertions hard-coded to the exact output the code currently produces, with no independent derivation from the spec's Examples or Acceptance criteria
        - Over-mocking so the test only confirms stubbed interactions or that a method was called, never a real result
        - Assertions on private state, internal call order, or implementation details rather than observable outputs and contracts
        - A bug present in the diff encoded as the expected result, locking in the wrong behavior
        - Snapshot/golden files regenerated and committed without inspection
        - Only the happy path exercised, leaving the spec's edge cases, error paths, and Acceptance criteria unasserted
5. **Interview me about every unmapped change** — a changed hunk not covered by the spec and not derivable from any Scope, Expected-behavior, Context, or Note entry. One question at a time, until
   none remain. Include a classification recommendation (intended-but-undocumented or out-of-scope) when evidence supports one; never invent one. Based on the answer, drop the hunk (intended, simply
   absent from the spec text) or record it as an issue under `## Out-of-scope changes`.
6. **Write the review**, only if at least one issue was found, to a markdown file inside the same folder as the spec. Filename: replace the trailing `SPEC.md` with `REVIEW.md`. Overwrite if it
   exists. If no issues were found, write no file.
7. **Confirm** with a one-line message: the file written and the number of issues found, or that none were found and no file was written.

## Content rules

- Optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical flourish.
- The review contains **only the issues found and where they occur**. Do not include summaries of the spec or diff, praise, restatements of criteria that pass, suggestions unrelated to a concrete
  issue, references to a previous review, or meta-commentary.
- An issue that points to specific code must cite the exact file path and line number(s) in its evidence table. Line numbers refer to the file at its current revision on disk.
- One numbered heading per logical issue with one table; the same problem at multiple sites is one issue with one row per site. Different problems are separate issues, even when they share a file.
- Below each heading write 1–2 short sentences naming what is wrong and which spec item or rule it violates (Scope bullet, Expected-behavior bullet, Acceptance criterion, Out-of-scope rule, Context
  pattern, Example, Note, `Correctness` for a bug not tied to a spec item, `Stage report` for a report/diff mismatch, or `Tests` for a test issue from step 4).
- Use tables for evidence; quote the offending code only when it is shorter than the explanation and clarifies the issue.
- No TODOs or `<TBD>` placeholders. If a finding is uncertain, omit it.

## Investigation discipline

- Do not run tests, install dependencies, or trigger any code execution.
- Do not modify the code under review, the spec, the plan, or the stage reports. The only file this skill writes is its own `REVIEW.md` report.

## File structure

Up to three top-level sections, in this fixed order, and no others; omit any section that has no entries. Within a section, number issues sequentially starting at 1.

```md
# Review: <short title taken from the spec>

## Out-of-scope changes

### 1. <issue title>

<1–2 sentences: what changed and why it is out of scope per the spec.>

| File                | Lines        | Code                       |
|---------------------|--------------|----------------------------|
| `path/to/file.ext`  | 12–34        | `<offending snippet>`      |
| same                | 320, 328–331 | `<offending snippet>`      |
| `path/to/other.ext` | 88           | `<offending snippet>`      |

## Acceptance criteria not met

### 1. <criterion text quoted from the spec>

<1–2 sentences: what is missing or wrong.>

## Implementation issues

### 1. <issue title>

<1–2 sentences: what is wrong, naming the Context pattern, Note, edge case, or `Correctness` rule it violates.>
```

Every issue that cites specific code carries the same `File`/`Lines`/`Code` evidence table; an Acceptance criterion the diff never addresses may stand on its 1–2 sentences with no table.
`## Implementation issues` covers every finding that is neither out-of-scope nor a missed acceptance criterion.

## Stop conditions

- No folder provided.
- Folder contains no file ending with `SPEC.md`, or contains multiple.
- Spec is unreadable or empty.
- No code changes resolvable from the input (empty diff, no files).
