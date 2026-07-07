---
name: standalone-review
description: Review code changes.
disable-model-invocation: true
---

## Main Objective

Review code changes against loose context and write a `REVIEW.md`.

## Inputs

- **Context (optional, loose).** The intent the changes are meant to fulfill, provided as one of:
    - Inline plain text in the chat — a description, a pasted ticket or issue, requirements, constraints, examples.
    - A path to a file or document to read in full and treat the same way.
    - Nothing → review for correctness, convention compliance, and internal consistency only.
- **The code changes to review**, provided as one of:
    - A list of file paths or a directory.
    - A git diff range (e.g. `main..HEAD`, a branch name, or a commit SHA).
    - Nothing → default to the uncommitted working tree (`git status` + `git diff HEAD`).

## Workflow

1. **Ingest the context.** Take inline context verbatim; read a context path in full. Extract every concrete expectation it states — intended behavior, requirements, constraints, scope boundaries,
   examples — and treat each as a binding constraint. If no context is provided, skip every check below that depends on stated intent; its absence is not an issue.
2. **Enumerate the changed files.** Resolve the input to a concrete list of file paths plus their changed line ranges. Read each changed file in full from disk so review line numbers stay accurate.
   Also read the surrounding code the diff touches — callers, callees, sibling modules, and any file whose convention the diff is supposed to mirror.
3. **Map each change to the context.** For every changed hunk, determine which stated expectation it satisfies or violates, or whether it is unrelated to the stated intent. Track unmapped changes
   (defined in step 5). If no context was provided, skip this mapping.
4. **Identify issues.** Treat each of these as a potential issue:
    - A stated expectation not implemented or only partially implemented (the intent has no corresponding code, or the code contradicts it)
    - File or symbol modified that is outside the stated scope (only when context was provided)
    - An example in the context not honored (input → output mismatch, before → after mismatch)
    - Existing pattern in the surrounding codebase not followed (a new ad-hoc pattern introduced instead)
    - Bespoke one-off utility, helper, or inline reimplementation added where an existing canonical utility in the codebase already provides the behavior
    - Code placed in the wrong package, module, or service — architectural drift from the codebase's established layering (e.g. business logic in a controller, persistence calls from a domain type)
    - Stated constraint violated (auth, ordering, idempotency, perf, side effects, role check, null/empty handling)
    - Edge case implied by the context not handled
    - Suspected correctness bug introduced by the diff itself (null deref, off-by-one, swallowed exception, missing transaction boundary, leaked resource, SQL/XSS/command injection, broken
      authorization check)
    - Test changes that reinforce the implementation instead of verifying behavior — tautological or change-detector tests. Concrete forms:
        - Assertions hard-coded to the exact output the code currently produces, with no independent derivation from the context's expectations or examples
        - Over-mocking so the test only confirms stubbed interactions or that a method was called, never a real result
        - Assertions on private state, internal call order, or implementation details rather than observable outputs and contracts
        - A bug present in the diff encoded as the expected result, locking in the wrong behavior
        - Snapshot/golden files regenerated and committed without inspection
        - Only the happy path exercised, leaving edge cases and error paths unasserted
5. **Interview me about every unmapped change** — a changed hunk not covered by the stated intent and not derivable from any expectation, constraint, or example in it (only when context was
   provided). One question at a time, until none remain. Include a classification recommendation (intended-but-undocumented or out-of-scope) when evidence supports one; never invent one. Based on the
   answer, drop the hunk (intended, simply absent from the context) or record it as an issue under `## Out-of-scope changes`.
6. **Write the review**, only if at least one issue was found, to `REVIEW.md` in the current working directory. Overwrite if it exists. If no issues were found, write no file.
7. **Confirm** with a one-line message: the file written and the number of issues found, or that none were found and no file was written.

## Content rules

- Optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical flourish.
- The review contains **only the issues found and where they occur**. Do not include summaries of the context or diff, praise, restatements of expectations that pass, suggestions unrelated to a
  concrete issue, references to a previous review, or meta-commentary.
- An issue that points to specific code must cite the exact file path and line number(s) in its evidence table. Line numbers refer to the file at its current revision on disk.
- One numbered heading per logical issue with one table; the same problem at multiple sites is one issue with one row per site. Different problems are separate issues, even when they share a file.
- Below each heading write 1–2 short sentences naming what is wrong and which item or rule it violates: a stated expectation (`Intent`), the out-of-scope rule (`Out of scope`), an existing-codebase
  pattern (`Convention`), a stated constraint (`Constraint`), `Correctness` for a bug not tied to stated intent, or `Tests` for a test issue from step 4.
- Use tables for evidence; quote the offending code only when it is shorter than the explanation and clarifies the issue.
- No TODOs or `<TBD>` placeholders. If a finding is uncertain, omit it.

## Investigation discipline

- Do not run tests, install dependencies, or trigger any code execution.
- Do not modify the code under review or the context document. The only file this skill writes is its own `REVIEW.md` report.

## File structure

Up to three top-level sections, in this fixed order, and no others; omit any section that has no entries. Within a section, number issues sequentially starting at 1.

```md
# Review: <short title describing the change set>

## Out-of-scope changes

### 1. <issue title>

<1–2 sentences: what changed and why it is out of scope per the stated intent.>

| File                | Lines        | Code                       |
|---------------------|--------------|----------------------------|
| `path/to/file.ext`  | 12–34        | `<offending snippet>`      |
| same                | 320, 328–331 | `<offending snippet>`      |
| `path/to/other.ext` | 88           | `<offending snippet>`      |

## Stated intent not met

### 1. <expectation quoted or paraphrased from the context>

<1–2 sentences: what is missing or wrong.>

## Implementation issues

### 1. <issue title>

<1–2 sentences: what is wrong, naming the `Convention`, `Constraint`, edge case, `Correctness`, or `Tests` rule it violates.>
```

Every issue that cites specific code carries the same `File`/`Lines`/`Code` evidence table; a stated expectation the diff never addresses may stand on its 1–2 sentences with no table.
`## Out-of-scope changes` and `## Stated intent not met` appear only when context was provided. `## Implementation issues` covers every finding that is neither out-of-scope nor an unmet expectation.

## Stop conditions

- No code changes resolvable from the input (empty diff, no files).
- A context path is provided but unreadable or empty.
