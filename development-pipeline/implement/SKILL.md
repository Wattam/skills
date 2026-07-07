---
name: implement
description: Execute an implementation plan.
disable-model-invocation: true
---

## Inputs

A folder path containing a file ending with `PLAN.md`, or a direct path to that file. Expected folder location: `specs/<kebab-title>/`.

## Workflow

1. **Locate and ingest the plan.** If the input is a folder, list its contents and identify the file ending with `PLAN.md`. Read it in full. Treat Context, Steps, and Acceptance criteria as the
   binding source of work to perform.
2. **Investigate the codebase.** For each file, symbol, signature, path, or command named in the plan, search and read the codebase to confirm its current state, exact location, and surrounding
   patterns before editing.
3. **Identify gaps.** Scan the plan and the investigation for missing information that blocks execution. Treat each of these as a potential gap:
    - **Missing target** — a Step names a file, symbol, or path that does not exist and the plan does not say to create it.
    - **Ambiguous action** — a Step's action, signature, payload, SQL, or command is not concrete enough to apply without choosing among alternatives.
4. **Interview me about every gap.** One question at a time, until none remain. Include a recommendation for a gap when evidence supports one; never invent one.
5. **Execute the Steps in sequential order.** Do not reorder, skip, batch ahead, or parallelize. Complete a Step and confirm it succeeded before starting the next.
6. **Verify the Acceptance criteria.** After the last Step, check each Acceptance criterion using the exact command or assertion the plan supplies. Running the project's full test suite — every
   test, not only the ones related to the change — is always one of the Acceptance criteria unless the plan or the user says not to. Record for each criterion the check used and its result.
7. **Write the report** to a markdown file inside the same folder as the plan. Filename: replace the trailing `PLAN.md` with `IMPLEMENT.md`. Overwrite if it exists. Write the report also when the
   run stops at a blocked Step (see Stop conditions).
8. **Confirm** with a one-line message naming the report file, the counts of files created, edited, and deleted, and the counts of Acceptance criteria verified, unverified, and failed.

## Execution discipline

- **Version control is off-limits for writes.** Do not create, switch, rename, or check out branches; do not commit, stage, push, pull, merge, rebase, stash, or reset. Use `git` only for read-only
  inspection (e.g. `git status`, `git diff`).
- **Stay inside the plan.** Make only the changes the Steps describe. No out-of-plan refactors, renames, reformatting, dependency upgrades, or "while I'm here" improvements.
- **No partial placeholders.** A Step is either completed fully or reported as blocked. No TODOs, stubs, or commented-out scaffolding in the code.
- Match the conventions and style of the surrounding code being edited.
- The only file this skill writes outside the plan's Steps is its own `IMPLEMENT.md` report.

## Content rules

- Optimized for LLM consumption: short declarative sentences, explicit identifiers, no rhetorical flourish.
- The report is a **record of what was changed and verified**, not a plan or rationale. Do not describe WHY an edit was made.
- The report must be **self-contained**. Inline every file path, the full text of every Acceptance criterion, and the exact command or assertion used to check it; never substitute a reference like
  "see the plan" for the information itself.
- Status values: `verified` (the criterion's check ran and passed), `failed` (it ran and did not pass), `unverified` (it could not be run).
- Do not include source code or diffs in the report.
- No TODOs or `<TBD>` placeholders.

## File structure

```md
# Implement: <short title taken from the plan>

## Files

| File               | Change                     | Plan step |
|--------------------|----------------------------|-----------|
| `path/to/file.ext` | created / edited / deleted | Step <n>  |

## Acceptance criteria

| Criterion                    | Status                         | Check                                                |
|------------------------------|--------------------------------|------------------------------------------------------|
| <criterion text>             | verified / unverified / failed | <command or assertion used, or why it could not run> |

## Blocked

<include only if the run stopped at a blocked Step>

- Step <n>: <what blocked it>. Steps completed: <list>. Steps not executed: <list>.
```

Omit `## Blocked` when no Step blocked. Do not introduce other top-level sections.

## Stop conditions

- No folder or file provided.
- Input folder contains no file ending with `PLAN.md`, or contains multiple.
- Provided file does not end with `PLAN.md`.
- Plan is unreadable or empty.
- A Step cannot be completed (missing dependency, conflicting code, failing command, unresolved gap) — stop at that Step, execute no later Steps, and still write the report: criteria not checked
  because of the block are `unverified`, and `## Blocked` names the blocked Step, what blocked it, the Steps completed, and the Steps not executed.
