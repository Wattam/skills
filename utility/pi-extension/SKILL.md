---
name: pi-extension
description: Create/Update a Pi agent extension.
disable-model-invocation: true
---

# Pi Extension

Create a new extension for the pi coding agent, or update an existing one. A pi extension is a TypeScript
module that pi loads to add tools, commands, keyboard shortcuts, event hooks, custom UI, or model providers.

This file covers what every extension needs regardless of type. It does not cover any single capability in
depth — for that, read the capability's own doc (see [Capabilities](#capabilities-and-where-to-read-more)).

## Inputs

- Whether this creates a new extension or updates an existing one. For an update, the target extension — a
  path or a name under `~/.pi/agent/extensions/` or a project's `.pi/extensions/`.
- What the extension should do (new), or what should change (update), and which capabilities are involved
  (tools, commands, hooks, UI, provider, …).
- For a new extension, where it should live: global (all projects) or project-local (one project). Default to
  global.

Ask only when the goal or the target is ambiguous.

## Reference documentation

The authoritative pi docs ship inside the installed pi package. Find the package root:

```bash
PI_PKG="$(npm root -g)/@earendil-works/pi-coding-agent"
```

If `npm root -g` does not resolve it (custom or non-global install), locate the package another way
(`npm ls -g @earendil-works/pi-coding-agent`, or search the active `node_modules`). Docs are under
`$PI_PKG/docs/`; runnable, copy-pasteable examples are under `$PI_PKG/examples/extensions/` (indexed by its
`README.md`). Existing extensions in `~/.pi/agent/extensions/` are also useful references.

The [Common essentials](#common-essentials) below cover what every extension shares — treat them as the
baseline and do not re-read the whole manual for them. For each capability the extension uses, read only the
relevant section (`extensions.md` opens with a table of contents whose anchors map to its sections), plus any
standalone doc and one matching example listed in [Capabilities](#capabilities-and-where-to-read-more). Open
more of `extensions.md` only when the essentials here are not enough.

## Common essentials

These apply to every extension.

### Placement and discovery

Auto-discovered (hot-reloadable with `/reload`):

| Location                                                                 | Scope                                                   |
|--------------------------------------------------------------------------|---------------------------------------------------------|
| `~/.pi/agent/extensions/*.ts` or `~/.pi/agent/extensions/*/index.ts`     | Global (all projects)                                   |
| `<project>/.pi/extensions/*.ts` or `<project>/.pi/extensions/*/index.ts` | Project-local (loads only after the project is trusted) |

Additional paths and shared packages are configured via `extensions` and `packages` in
`~/.pi/agent/settings.json` (or a project `.pi/settings.json`). See `$PI_PKG/docs/settings.md`.

### Entry point

An extension default-exports a factory function that receives the `ExtensionAPI` object (`pi`). It may be
synchronous or `async`; if it returns a promise, pi awaits it before startup continues (use `async` for
one-time startup work such as fetching remote config or models).

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // Load-time: register capabilities (cheap, no I/O, no background work).
  pi.registerCommand("name", {
    description: "...",
    handler: async (args, ctx) => { /* ... */ },
  });

  // Start session-scoped resources (watchers, sockets, timers, UI) here.
  pi.on("session_start", async (event, ctx) => { /* ... */ });

  // Tear them down here. Make this idempotent.
  pi.on("session_shutdown", async (event, ctx) => { /* ... */ });
}
```

### Imports

| Package                           | Purpose                                                                                                        |
|-----------------------------------|----------------------------------------------------------------------------------------------------------------|
| `@earendil-works/pi-coding-agent` | Extension types and helpers (`ExtensionAPI`, `ExtensionContext`, `CONFIG_DIR_NAME`, tool/truncation utilities) |
| `typebox`                         | `Type` schemas for tool parameters                                                                             |
| `@earendil-works/pi-ai`           | `StringEnum` for enum parameters (works with all providers)                                                    |
| `@earendil-works/pi-tui`          | TUI components for custom rendering                                                                            |

Node built-ins (`node:fs`, `node:path`, …) work. For npm deps, add a `package.json` beside the extension,
run `npm install`, and imports resolve from `node_modules/`.

### Events

Subscribe with `pi.on(event, async (event, ctx) => { ... })`. Some handlers return a value to influence
behavior (e.g. `tool_call` returns `{ block: true, reason }`; `input` returns `{ action: ... }`). The full
lifecycle, event list, and return contracts are in `extensions.md`. The two most extensions use:

- `session_start` — fired on startup, reload, new, resume, and fork. Start resources and reconstruct
  in-memory state here.
- `session_shutdown` — fired before a session is torn down. Release everything `session_start` started.

### ExtensionContext (`ctx`)

Every handler receives `ctx`. Members an extension of any type touches:

- `ctx.ui` — dialogs (`select`, `confirm`, `input`, `editor`), `notify`, and `setStatus` / `setWidget` /
  `setFooter`. Full UI surface is in `tui.md`.
- `ctx.mode` — `"tui" | "rpc" | "json" | "print"`.
- `ctx.hasUI` — `true` in tui and rpc.
- `ctx.cwd` — working directory. Build project-local paths with `CONFIG_DIR_NAME`, not a hardcoded `.pi`.
- `ctx.sessionManager` — read-only session state: `getEntries()`, `getBranch()`, `getLeafId()`.
- `ctx.model` / `ctx.modelRegistry` — active model and registry.
- `ctx.signal` — agent abort signal during active turns; pass it to `fetch`, model calls, and `pi.exec`.
- `ctx.shutdown()` — request a graceful shutdown.

### ExtensionAPI (`pi`)

- `pi.on(event, handler)`
- `pi.registerTool(def)`, `pi.registerCommand(name, opts)`, `pi.registerShortcut(key, opts)`,
  `pi.registerFlag(name, opts)`
- `pi.exec(cmd, args, opts)` → `{ stdout, stderr, code, killed }`
- `pi.sendMessage(...)`, `pi.sendUserMessage(...)`, `pi.appendEntry(customType, data)`
- `pi.events` — shared bus for inter-extension communication
- `pi.getActiveTools()` / `pi.getAllTools()` / `pi.setActiveTools(names)`, `pi.setModel(model)`,
  `pi.getThinkingLevel()` / `pi.setThinkingLevel(level)`
- `pi.registerProvider(name, config)` / `pi.unregisterProvider(name)`

### State persistence

Extensions are reinstantiated on `/reload` and on session switch/fork. Do not rely on in-memory state
surviving. Persist state in tool result `details` or via `pi.appendEntry(customType, data)`, and reconstruct
it in `session_start` by scanning `ctx.sessionManager.getBranch()` / `getEntries()`.

### Modes

| Mode         | `ctx.mode` | `ctx.hasUI` |
|--------------|------------|-------------|
| Interactive  | `"tui"`    | `true`      |
| RPC          | `"rpc"`    | `true`      |
| JSON         | `"json"`   | `false`     |
| Print (`-p`) | `"print"`  | `false`     |

Guard dialog and notification calls with `ctx.hasUI`. Guard `ctx.ui.custom()`, component factories, and
terminal input with `ctx.mode === "tui"`.

### Error handling

Extension errors are logged and the agent continues. A throw from a `tool_call` handler blocks that tool
(fail-safe). A custom tool's `execute` must **throw** to report failure to the LLM — a returned value never
sets the error flag.

## Capabilities and where to read more

Identify the capabilities the extension needs, then read the matching doc and example. Do not reproduce the
capability's details here.

| Capability            | What it does                                                                                                                                                                                                                        | Read                                                                                                    |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| Custom tools          | LLM-callable tools via `pi.registerTool` (must truncate large output; use `StringEnum` for enums; tools run in parallel — serialize file writes with `withFileMutationQueue()` and shared state with `executionMode: "sequential"`) | `extensions.md` → Custom Tools; examples `hello.ts`, `todo.ts`, `tool-override.ts`, `truncated-tool.ts` |
| Slash commands        | User `/name` commands via `pi.registerCommand`                                                                                                                                                                                      | `extensions.md` → ExtensionCommandContext; examples `shutdown-command.ts`, `summarize.ts`               |
| Event hooks & gates   | Block/modify tool calls, transform input, inject context, react to lifecycle via `pi.on`                                                                                                                                            | `extensions.md` → Events; examples `permission-gate.ts`, `protected-paths.ts`, `input-transform.ts`     |
| Custom UI             | Dialogs, widgets, footer, header, autocomplete, custom editor, overlays, components                                                                                                                                                 | `tui.md`; examples `custom-footer.ts`, `widget-placement.ts`, `modal-editor.ts`, `overlay-test.ts`      |
| Keybindings           | Shortcuts via `pi.registerShortcut` and key hints                                                                                                                                                                                   | `keybindings.md`                                                                                        |
| Model providers       | Register/override providers and models via `pi.registerProvider`                                                                                                                                                                    | `custom-provider.md`, `models.md`, `providers.md`; example `custom-provider-anthropic/`                 |
| Compaction            | Customize or replace conversation summarization via `session_before_compact`                                                                                                                                                        | `compaction.md`; examples `custom-compaction.ts`, `trigger-compact.ts`                                  |
| Session state         | Persist/reconstruct state, branching, tree, fork                                                                                                                                                                                    | `session-format.md`, `sessions.md`; examples `todo.ts`, `bookmark.ts`                                   |
| Discovery & config    | Where extensions load from, `settings.json` keys, project trust                                                                                                                                                                     | `settings.md`, `security.md`                                                                            |
| Packaging             | Ship as an installable pi package (npm/git)                                                                                                                                                                                         | `packages.md`; example `with-deps/`                                                                     |
| Non-interactive modes | Behavior under RPC / JSON / print                                                                                                                                                                                                   | `rpc.md`, `json.md`                                                                                     |

## Universal rules

- Never start background resources (watchers, sockets, timers, UI) from the factory — the factory may run in
  invocations that never open a session. Defer them to `session_start` or the event/command/tool that needs
  them.
- Release every session-scoped resource in an idempotent `session_shutdown` handler.
- Reconstruct in-memory state in `session_start`; never assume it survived a reload or session switch.
- Guard UI by mode: `ctx.hasUI` for dialogs/notifications, `ctx.mode === "tui"` for custom components.
- Pass `ctx.signal` to abort-aware async work started during a turn.
- Use `CONFIG_DIR_NAME` for project-local config paths instead of hardcoding `.pi`.

## Workflow

1. **Clarify the goal.** Confirm whether this creates a new extension or updates an existing one, what it
   should do (or what should change), and which capabilities are involved. For an update, locate the target
   (search `~/.pi/agent/extensions/` and any project `.pi/extensions/`) and read the whole extension first,
   including its helper modules, to learn its structure and conventions.
2. **Read what the capabilities need.** Resolve `$PI_PKG`. The essentials above already cover the shared
   model, so do not read the full manual. For each capability involved, read its specific section of
   `extensions.md`, any standalone doc, and one matching example.
3. **For a new extension, choose placement and style.** Single file `name.ts` for small extensions;
   `name/index.ts` (plus helper modules) for multi-file; `name/` with a `package.json` and `npm install` when
   npm deps are needed. Place under `~/.pi/agent/extensions/` (global) or `<project>/.pi/extensions/`
   (project-local). For an update, keep the existing location, file layout, and entry-point shape.
4. **Write the change.** For a new extension, start from the scaffold. For an update, make targeted edits to
   the existing file(s) and match the surrounding naming, idioms, and comment density. Either way, register
   capabilities at load time, defer resources to `session_start`, clean up in `session_shutdown`, and follow
   the universal rules and the capability's doc.
5. **Validate.** Load a new file without installing: `pi -e ./path/to/extension.ts`. For an extension in an
   auto-discovered location — including one you just edited — reload a running session with `/reload`. Confirm
   the factory throws nothing at load and the capability appears or behaves as intended (the tool in the tool
   list, `/command` in the command list, etc.).

Confirm with a one-line message naming the file(s) written or changed and how to load them.
