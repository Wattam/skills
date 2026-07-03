---
name: pi-extension
description: Create/update a pi agent extension by working through the official pi docs.
disable-model-invocation: true
---

# Pi Extension

Create a new extension for the pi coding agent, or update an existing one. A pi extension is a TypeScript module that pi loads to add tools, commands, keyboard shortcuts, event hooks, custom UI, or
model providers.

This skill does not explain the extension API. The authoritative source is the documentation shipped inside the installed pi package; this skill tells you where that documentation is and which parts
to read for the task at hand. Never write extension code from memory of the API — read the matching doc and example first, every time.

## Inputs

- Whether this creates a new extension or updates an existing one. For an update, the target extension — a path or a name under `~/.pi/agent/extensions/` or a project's `.pi/extensions/`.
- What the extension should do (new), or what should change (update), and which capabilities are involved (tools, commands, hooks, UI, provider, …).
- For a new extension, where it should live: global (all projects) or project-local (one project). Default to global.

Ask only when the goal or the target is ambiguous.

## Locating the documentation

The docs ship inside the installed pi package. Find the package root:

```bash
PI_PKG="$(npm root -g)/@earendil-works/pi-coding-agent"
```

If `npm root -g` does not resolve it (custom or non-global install), locate the package another way (`npm ls -g @earendil-works/pi-coding-agent`, or search the active `node_modules`). Docs are under
`$PI_PKG/docs/`; runnable, copy-pasteable examples are under `$PI_PKG/examples/extensions/` (indexed by its `README.md`). Existing extensions in `~/.pi/agent/extensions/` are also useful references.

## Documentation map

### Core (start here for every task)

| Document                                | What it covers                                                                                                                                                                    |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `$PI_PKG/docs/extensions.md`            | **Main extension authoring guide**: lifecycle events, `ExtensionAPI`, `ExtensionContext`, custom tools, custom UI, commands, state management, error handling, examples reference |
| `$PI_PKG/examples/extensions/README.md` | Catalog of working extension examples with descriptions and key patterns                                                                                                          |
| `$PI_PKG/README.md`                     | Pi overview, customization surface (extensions, skills, prompts, themes, packages), CLI reference, modes, sessions, settings                                                      |

`extensions.md` opens with a table of contents whose anchors map to its sections. Always read its sections on the extension entry point, discovery/placement, the lifecycle events, state management,
and error handling — they apply to every extension. Then read only the sections the task's capabilities need; open more of the manual only when those are not enough.

### Per capability

Identify the capabilities the extension needs, then read the matching doc sections and at least one matching example.

| Capability            | What it does                                                                             | Read                                                                                                    |
|-----------------------|------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| Custom tools          | LLM-callable tools via `pi.registerTool`                                                 | `extensions.md` → Custom Tools; examples `hello.ts`, `todo.ts`, `tool-override.ts`, `truncated-tool.ts` |
| Slash commands        | User `/name` commands via `pi.registerCommand`                                           | `extensions.md` → ExtensionCommandContext; examples `shutdown-command.ts`, `summarize.ts`               |
| Event hooks & gates   | Block/modify tool calls, transform input, inject context, react to lifecycle via `pi.on` | `extensions.md` → Events; examples `permission-gate.ts`, `protected-paths.ts`, `input-transform.ts`     |
| Custom UI             | Dialogs, widgets, footer, header, autocomplete, custom editor, overlays, components      | `tui.md`; examples `custom-footer.ts`, `widget-placement.ts`, `modal-editor.ts`, `overlay-test.ts`      |
| Keybindings           | Shortcuts via `pi.registerShortcut` and key hints                                        | `keybindings.md`                                                                                        |
| Model providers       | Register/override providers and models via `pi.registerProvider`                         | `custom-provider.md`, `models.md`, `providers.md`; example `custom-provider-anthropic/`                 |
| Compaction            | Customize or replace conversation summarization via `session_before_compact`             | `compaction.md`; examples `custom-compaction.ts`, `trigger-compact.ts`                                  |
| Session state         | Persist/reconstruct state, branching, tree, fork                                         | `session-format.md`, `sessions.md`; examples `todo.ts`, `bookmark.ts`                                   |
| Discovery & config    | Where extensions load from, `settings.json` keys, project trust                          | `settings.md`, `security.md`                                                                            |
| Packaging             | Ship as an installable pi package (npm/git)                                              | `packages.md`; example `with-deps/`                                                                     |
| Non-interactive modes | Behavior under RPC / JSON / print                                                        | `rpc.md`, `json.md`                                                                                     |

### Adjacent topics

Read these only when the task touches them.

| Document                           | What it covers                                                                                                      |
|------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| `$PI_PKG/docs/sdk.md`              | Embedding pi in other apps with `createAgentSession`, `AgentSessionRuntime`, `SessionManager`, model registry, auth |
| `$PI_PKG/examples/sdk/README.md`   | SDK examples: custom tools, extensions, skills, sessions, settings, full control                                    |
| `$PI_PKG/docs/themes.md`           | Writing and packaging custom themes                                                                                 |
| `$PI_PKG/docs/skills.md`           | Writing and packaging skills                                                                                        |
| `$PI_PKG/docs/prompt-templates.md` | Writing and packaging prompt templates                                                                              |
| `$PI_PKG/docs/development.md`      | Setting up a pi development environment, forking, debugging                                                         |

## Rules

- Do not write against the API from memory. Every registration call, event name, context member, and return contract you use must come from a doc section or example you read in this session.
- Follow the constraints the docs state (resource lifecycle, UI/mode guards, state persistence, error reporting, output truncation) as written there; when a doc and an example disagree, the doc wins.
- Annotate every variable in generated TypeScript with an explicit type; do not rely on inference for declared variables.
- Indent generated TypeScript with 4 spaces by default; for an update, follow the existing file's style.

## Workflow

1. **Clarify the goal.** Confirm whether this creates a new extension or updates an existing one, what it should do (or what should change), and which capabilities are involved. For an update, locate
   the target (search `~/.pi/agent/extensions/` and any project `.pi/extensions/`) and read the whole extension first, including its helper modules, to learn its structure and conventions.
2. **Read the core docs.** Resolve `$PI_PKG`. Read the table of contents of `extensions.md`, then its sections on the entry point, discovery/placement, lifecycle events, state management, and error
   handling.
3. **Read what the capabilities need.** For each capability involved, read its doc(s) from the per-capability table and at least one matching example from `$PI_PKG/examples/extensions/`.
4. **For a new extension, choose placement and layout** using what the discovery/placement docs say, honoring the requested scope (global vs project-local). For an update, keep the existing location,
   file layout, and entry-point shape.
5. **Write the change.** For a new extension, start from the closest example. For an update, make targeted edits to the existing file(s) and match the surrounding naming, idioms, and comment density.
   Follow the rules above and the constraints from the docs you read.
6. **Validate** the way `extensions.md` describes (loading a file directly, reloading a running session). Confirm the extension loads without errors and the capability appears or behaves as intended
   (the tool in the tool list, `/command` in the command list, etc.).

Confirm with a one-line message naming the file(s) written or changed and how to load them.
