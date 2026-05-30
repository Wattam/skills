---
name: review-code
description: Review code changes against a specification (folder path containing a file ending with SPEC.md) and write the findings to a markdown file inside that same spec folder.
disable-model-invocation: true
---

# Review

## Inputs

- A spec folder path containing a file ending with `SPEC.md`.
- The code changes to review, provided as one of:
    - A list of file paths or a directory.
    - A git diff range (e.g. `main..HEAD`, a branch name, or a commit SHA). Use `git diff --name-only <range>` and
      `git diff <range>` to enumerate and read.
    - Nothing → default to the uncommitted working tree (`git status` + `git diff HEAD`). Confirm this default with the
      user before proceeding.

## Workflow

1. **Precondition.** If no `CLAUDE.md` exists in the current working directory, tell the user the skill requires project
   context from `CLAUDE.md` and stop.
2. **Locate and ingest the spec.** List the folder contents, identify the file ending with `SPEC.md`, and read it in
   full. Treat every section as a binding constraint to check against.
3. **Enumerate the changed files.** Resolve the input to a concrete list of file paths plus their changed line ranges.
   Read each changed file in full from disk so review line numbers stay accurate. Also read the spec's
   Context-referenced files so you can judge pattern compliance, Note constraints, and existing conventions the diff is
   supposed to mirror.
4. **Map each change to the spec.** For every changed hunk, determine which spec item it satisfies or violates: Scope
   bullet (feature spec), Expected-behavior bullet (bug-fix spec), Acceptance criterion, Context pointer, Example, or
   Note. Track unmapped changes — code that is altered but is neither mentioned in nor derivable from the spec.
5. **Identify issues.** Treat each of these as a potential issue. For every one found, record the exact file path and
   line number(s):
    - Scope item (feature spec) or Expected-behavior bullet (bug-fix spec) not implemented or only partially
      implemented
    - File or symbol modified that is outside the spec's stated scope — listed under Out of scope (feature spec), or
      unrelated to the Expected behavior or Suspected cause (bug-fix spec)
    - Acceptance criterion not satisfied by the diff (the criterion has no corresponding code, or the code contradicts
      it)
    - Example in the spec not honored (input → output mismatch, before → after mismatch)
    - Existing pattern named in Context not followed (a new ad-hoc pattern introduced instead)
    - Note/constraint violated (auth, ordering, idempotency, perf, side effects, role check, null/empty handling)
    - Edge case from the spec not handled
    - For bug-fix specs: repro input still produces the current (wrong) behavior; expected behavior not produced
    - Suspected correctness bug introduced by the diff itself (null deref, off-by-one, swallowed exception, missing
      transaction boundary, leaked resource, SQL/XSS/command injection, broken authorization check)
6. **Ask about unmapped changes.** For each changed hunk that is not covered by the spec and cannot be derived from any
   Scope/Expected-behavior/Context/Note entry:
    - Ask one question at a time. Use plain text in the chat — do not use AskUserQuestion.
    - Question shape: "`<file>:<line>` — <short description of the change> is not covered by the spec. Is this intended,
      and which Scope bullet, Expected-behavior bullet, or Note item does it belong to?"
    - Include a classification recommendation (intended-but-undocumented, out-of-scope, or incidental refactor) only
      when evidence supports one; never invent one.
    - Wait for the user's answer before asking the next.
    - Based on the answer: drop the hunk from the issue list (intended, simply absent from the spec text) or add it as
      an issue under `## Out-of-scope changes`. If the user declines to answer, treat the hunk as out-of-scope.
    - Stop when every unmapped hunk has an answer.
7. **Write the review** to a markdown file inside the same folder as the spec. Filename: replace the trailing `SPEC.md`
   with `REVIEW.md` (e.g. `add-promotion-archive-job-SPEC.md` → `add-promotion-archive-job-REVIEW.md`). Overwrite if it
   exists.
8. **Confirm** with a one-line message naming the file written and the number of issues found.

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
- Every issue must cite the exact file path and line number(s) in its evidence table. Use a single line number (e.g.
  `37`) or a range (e.g. `320, 328–331` or `256–269`). Line numbers refer to the file at its current revision on disk.
- One numbered heading per logical issue. Same problem at multiple sites = one issue with one table (one row per site).
  Different problems = separate issues, even when they share a file.
- Group similar findings — repeated rule violations, multiple sites of the same bug, the same Note breached in several
  files — into that single table. Each row is one piece of evidence: `File`, `Lines`, `Code`.
- Below each heading write 1–2 short sentences naming what is wrong and which spec item or rule it violates (Scope
  bullet or Expected-behavior bullet for bug-fix specs, Acceptance criterion, Out-of-scope rule, Context pattern,
  Example, Note, or `Correctness` when it is a bug not tied to a spec item). Follow-up prose after the table is allowed
  only when a single sentence cannot make the issue actionable.
- Use tables for evidence; quote the offending code only when it is shorter than the explanation and clarifies the
  issue.
- No TODOs, no "figure out later", no placeholders like `<TBD>`. If a finding is uncertain, omit it.
- If no issues are found, the review file contains only the title and a single line: `No issues found.`

## Review file structure

The review file has exactly three top-level sections, in this order. Each section holds zero or more numbered issues.
Within a section, number issues sequentially starting at 1 and reset the counter at each section.

```md
# Review: <short title taken from the spec>

## Out-of-scope changes

### 1. <issue title>

<1–2 sentences: what changed and why it is out of scope per the spec.>

| File                | Lines  | Code                       |
|---------------------|--------|----------------------------|
| `path/to/file.ext`  | 12–34  | `<offending snippet>`      |
| `path/to/other.ext` | 88     | `<offending snippet>`      |

## Acceptance criteria not met

### 1. <criterion text quoted from the spec>

<1–2 sentences: what is missing or wrong.>

| File               | Lines    | Code                       |
|--------------------|----------|----------------------------|
| `path/to/file.ext` | 256–269  | `<offending snippet>`      |

## Implementation issues

### 1. <issue title>

<1–2 sentences: what is wrong, naming the Context pattern, Note, edge case, or `Correctness` rule it violates.>

| File                | Lines        | Code                       |
|---------------------|--------------|----------------------------|
| `path/to/file.ext`  | 37           | `<offending snippet>`      |
| same                | 320, 328–331 | `<offending snippet>`      |
| `path/to/other.ext` | 270–273      | `<offending snippet>`      |
```

`## Implementation issues` covers every finding that is neither out-of-scope nor a missed acceptance criterion.

Omit any section that has no entries. Do not add any other top-level section (no "Spec gaps", no "Files referenced",
no "Notes", no "Open questions").

## Stop conditions

- No folder provided → ask for one, then stop.
- Folder contains no file ending with `SPEC.md` → tell the user, then stop.
- Folder contains multiple files ending with `SPEC.md` → ask the user which one to use, then wait for their answer.
- Spec is unreadable or empty → tell the user, then stop.
- No code changes resolvable from the input (empty diff, no files) → tell the user, then stop.
- User declines to answer an unmapped-change question → record the hunk under `## Out-of-scope changes` and continue.
