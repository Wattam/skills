---
name: review-code
description: Review code changes against a specification.
disable-model-invocation: true
---

# Review code

## Inputs

- A spec folder path containing a file ending with `SPEC.md`. Expected location: `specs/<kebab-title>/`.
- Up to three **stage reports** the pipeline may have left in that folder, each picked up automatically if present and
  skipped without penalty if absent. Every report lists the files its stage created, edited, and deleted and ties that
  change set to the spec's Acceptance criteria:
    - `IMPLEMENT.md` — the files the implementation changed, plus each Acceptance criterion's verified/unverified/failed
      status.
    - `UNIT-TESTS.md` and `INTEGRATION-TESTS.md` — the test files each stage changed, plus a Coverage table mapping each
      Acceptance criterion to the tests that cover it.
- The code changes to review, provided as one of:
    - A list of file paths or a directory.
    - A git diff range (e.g. `main..HEAD`, a branch name, or a commit SHA).
    - Nothing → default to the uncommitted working tree (`git status` + `git diff HEAD`).

## Workflow

1. **Locate and ingest the spec.** List the folder contents, identify the file ending with `SPEC.md`, and read it in
   full. Treat every section as a binding constraint to check against. Read in full every stage report present (the
   files ending with `IMPLEMENT.md`, `UNIT-TESTS.md`, and `INTEGRATION-TESTS.md`). For each one absent, skip every check
   below that depends on it; its absence is not an issue.
2. **Enumerate the changed files.** Resolve the input to a concrete list of file paths plus their changed line ranges.
   Read each changed file in full from disk so review line numbers stay accurate. Also read the spec's
   Context-referenced files so you can judge pattern compliance, Note constraints, and existing conventions the diff is
   supposed to mirror. For every stage report that was read, compare the files it lists as created, edited, or deleted
   against the resolved list and carry every mismatch into step 4.
3. **Map each change to the spec.** For every changed hunk, determine which spec item it satisfies or violates: Scope
   bullet (feature spec), Expected-behavior bullet (bug-fix spec), Acceptance criterion, Context pointer, Example, or
   Note. Track unmapped changes (defined in step 5).
4. **Identify issues.** Treat each of these as a potential issue:
    - Scope item (feature spec) or Expected-behavior bullet (bug-fix spec) not implemented or only partially
      implemented
    - File or symbol modified that is outside the spec's stated scope — listed under Out of scope (feature spec), or
      unrelated to the Expected behavior or Suspected cause (bug-fix spec)
    - Acceptance criterion not satisfied by the diff (the criterion has no corresponding code, or the code contradicts
      it)
    - Example in the spec not honored (input → output mismatch, before → after mismatch)
    - Existing pattern named in Context not followed (a new ad-hoc pattern introduced instead)
    - Bespoke one-off utility, helper, or inline reimplementation added where an existing canonical utility/helper in
      the codebase already provides the behavior
    - Code placed in the wrong package, module, or service — architectural drift from the codebase's established
      layering and boundaries (e.g. business logic in a controller, persistence calls from a domain type, cross-layer
      reach-around)
    - Note/constraint violated (auth, ordering, idempotency, perf, side effects, role check, null/empty handling)
    - Edge case from the spec not handled
    - For bug-fix specs: repro input still produces the current (wrong) behavior; expected behavior not produced
    - Suspected correctness bug introduced by the diff itself (null deref, off-by-one, swallowed exception, missing
      transaction boundary, leaked resource, SQL/XSS/command injection, broken authorization check)
    - Mismatch between a stage report and the change set: a file the report lists as created, edited, or deleted has no
      corresponding change in the diff, or a changed file is absent from the report's file tables
    - A stage report's claim about an Acceptance criterion that the diff does not bear out — check each criterion
      directly against the code and tests regardless of the report. An `IMPLEMENT.md` `verified` mark does not exempt a
      criterion from step 3's mapping, an `unverified` or `failed` mark must still be checked, and a `UNIT-TESTS.md` or
      `INTEGRATION-TESTS.md` Coverage row may map a criterion to a test that is missing from the diff or does not
      actually exercise it
    - Test changes that reinforce the implementation instead of verifying the specified behavior — tautological or
      change-detector tests. Concrete forms:
        - Assertions hard-coded to the exact output the code currently produces, with no independent derivation from the
          spec's Examples or Acceptance criteria
        - Over-mocking so the test only confirms stubbed interactions or that a method was called, never a real result
        - Assertions on private state, internal call order, or implementation details rather than observable outputs and
          contracts
        - A bug present in the diff encoded as the expected result, locking in the wrong behavior
        - Snapshot/golden files regenerated and committed without inspection
        - Only the happy path the author already knew worked is exercised, leaving the spec's edge cases, error paths,
          and Acceptance criteria unasserted
5. **Ask about unmapped changes.** For each changed hunk that is not covered by the spec and cannot be derived from any
   Scope/Expected-behavior/Context/Note entry, ask one question at a time. Include a classification recommendation
   (intended-but-undocumented, out-of-scope, or incidental refactor) only when evidence supports one; never invent one.
   A stage report's file tables count as evidence: a hunk in a file a report ties to a plan Step, Acceptance criterion,
   or test case supports an intended-but-undocumented recommendation.
   Wait for an answer before asking the next; stop when every unmapped hunk has an answer.
    - Question shape: "`<file>:<line>` — <short description of the change> is not covered by the spec. Is this intended,
      and which Scope bullet, Expected-behavior bullet, or Note item does it belong to?"
    - Based on the answer: drop the hunk from the issue list (intended, simply absent from the spec text) or add it as
      an issue under `## Out-of-scope changes`. If the user declines to answer, treat the hunk as out-of-scope.
6. **Write the review** to a markdown file inside the same folder as the spec. Filename: replace the trailing `SPEC.md`
   with `REVIEW.md` (e.g. `…-SPEC.md` → `…-REVIEW.md`). Overwrite if it exists.
7. **Confirm** with a one-line message naming the file written and the number of issues found.

## Review content rules

- Write in English, optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical
  flourish.
- The review contains **only the issues found and where they occur**. Do not include:
    - Summaries of the spec or diff
    - Praise or "looks good" notes
    - Restatements of acceptance criteria that pass
    - Suggestions unrelated to a concrete issue
    - References to a previous review, change logs, or history
    - Meta-commentary about the review process

  If you catch yourself writing "overall", "previously", "good job", "also", "additionally", or "note that" — delete
  that sentence.
- Every issue must cite the exact file path and line number(s) in its evidence table. Line numbers refer to the file at
  its current revision on disk.
- One numbered heading per logical issue with one table; the same problem at multiple sites is one issue with one row
  per site (repeated rule violations, multiple sites of the same bug, the same Note breached in several files).
  Different problems are separate issues, even when they share a file.
- Below each heading write 1–2 short sentences naming what is wrong and which spec item or rule it violates (Scope
  bullet or Expected-behavior bullet for bug-fix specs, Acceptance criterion, Out-of-scope rule, Context pattern,
  Example, Note, `Correctness` when it is a bug not tied to a spec item, `Stage report` for a mismatch between a stage
  report (`IMPLEMENT.md`, `UNIT-TESTS.md`, or `INTEGRATION-TESTS.md`) and the diff, or `Tests` for a test issue from
  step 4).
  Follow-up prose after the table is allowed only when a single sentence cannot make the issue actionable.
- Use tables for evidence; quote the offending code only when it is shorter than the explanation and clarifies the
  issue.
- No TODOs, no "figure out later", no placeholders like `<TBD>`. If a finding is uncertain, omit it.
- If no issues are found, the review file contains only the title and a single line: `No issues found.`

## Review file structure

The review file has up to three top-level sections, in this fixed order; omit any section that has no entries. Within a
section, number issues sequentially starting at 1.

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

Every issue under every section carries the same `File`/`Lines`/`Code` evidence table shown above.
`## Implementation issues` covers every finding that is neither out-of-scope nor a missed acceptance criterion.

Do not add any other top-level section (no "Spec gaps", no "Files referenced", no "Notes", no "Open questions").

## Stop conditions

- No folder provided → ask for one, then stop.
- Folder contains no file ending with `SPEC.md` → tell the user, then stop.
- Folder contains multiple files ending with `SPEC.md` → ask which one to use, then wait for their answer.
- Spec is unreadable or empty → tell the user, then stop.
- No code changes resolvable from the input (empty diff, no files) → tell the user, then stop.
