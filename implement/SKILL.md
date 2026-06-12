---
name: implement
description: Execute an implementation plan.
disable-model-invocation: true
---

# Implement

## Inputs

- A folder path containing a file ending with `PLAN.md`, or a direct path to a file ending with `PLAN.md`. Expected
  folder location: `specs/<kebab-title>/`.

## Workflow

1. **Locate and ingest the plan.** If the input is a file path ending with `PLAN.md`, read it. If the input is a folder,
   list its contents, identify the file ending with `PLAN.md`, and read it in full. Treat Context, Steps, and Acceptance
   criteria as the binding source of work to perform.
2. **Determine the test policy.** Scan the full plan text (Context, Steps, Acceptance criteria, and any Open questions)
   for any mention of tests: test files, test cases, test directories, a test framework or runner, a test command, test
   assertions, a step that writes or changes tests, or a test-related acceptance criterion.
    - Plan mentions tests → you may read, create, edit, and run test files exactly as the plan directs.
    - Plan does NOT mention tests → for the entire run you are **forbidden** to read, open, create, edit, delete, or run
      any test file, and forbidden to navigate into test directories.
3. **Investigate the codebase.** For each file, symbol, signature, path, or command named in the plan's Context and
   Steps, search and read the codebase to confirm its current state, exact location, and surrounding patterns before
   editing. Respect the test policy from step 2.
4. **Identify gaps.** Scan the plan and the investigation for missing information that blocks execution. A plan from the
   `plan` skill is meant to be self-contained, so gaps should be rare. Treat each of these as a potential gap:
    - **Plan open questions** — the plan's own `## Open questions` section lists an unresolved item that a Step depends
      on.
    - **Missing target** — a Step names a file, symbol, or path that does not exist and the plan does not say to create
      it.
    - **Ambiguous action** — a Step's action, signature, payload, SQL, or command is not concrete enough to apply
      without choosing among alternatives.
    - **Unrunnable check** — an Acceptance criterion names a command or assertion that cannot be run in this
      environment.
5. **Ask one question at a time.** Include a recommendation only when evidence supports one; never invent one. Wait for
   an answer before asking the next; stop when no gaps remain.
6. **Execute the Steps in sequential order.** Do not reorder, skip, batch ahead, or parallelize. Complete a Step's
   action — file edit, file creation, file deletion, or command — and confirm it succeeded before starting the next
   Step.
7. **Verify the Acceptance criteria.** After the last Step, check each Acceptance criterion using the exact command or
   assertion the plan supplies. Under the test policy from step 2, leave any criterion that can only be verified by
   tests unverified.
8. **Confirm** with a summary message: files created, edited, and deleted; Steps completed (and the first blocked Step,
   if any); each Acceptance criterion marked verified, unverified, or failed.

## Execution discipline

- **Version control is off-limits for writes.** Do not create, switch, rename, or check out branches; do not commit,
  stage, push, pull, merge, rebase, stash, or reset. Use `git` only for read-only inspection (e.g. `git status`,
  `git diff`) when an edit needs it.
- **Stay inside the plan.** Make only the changes the Steps describe. Do not add out-of-plan refactors, renames,
  reformatting, dependency upgrades, or "while I'm here" improvements.
- **No partial placeholders.** A Step is either completed fully or reported as blocked. Do not leave TODOs, stubs, or
  commented-out scaffolding in the code.
- Write code and comments in English, matching the conventions and style of the surrounding code being edited.

## Stop conditions

- No folder or file provided → ask for one, then stop.
- Input folder contains no file ending with `PLAN.md` → tell the user, then stop.
- Input folder contains multiple files ending with `PLAN.md` → ask which one to use, then wait for their answer.
- Provided file does not end with `PLAN.md` → tell the user, then stop.
- Plan is unreadable or empty → tell the user, then stop.
- A Step cannot be completed (missing dependency, conflicting code, failing command, or a gap the user declined to
  resolve in step 5) → stop at that Step. Report what blocked it, which Steps completed, and which Steps remain. Do not
  proceed to later Steps, since they may depend on the blocked one.
