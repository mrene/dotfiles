# OpenCode Port Plan

## Goal

Port the existing Claude Code setup to OpenCode while sharing durable workflow logic between both tools instead of duplicating it.

## Current State

- Claude config lives in `aspects/dev/claude/` with symlinks into `~/.claude/`.
- OpenCode module at `aspects/dev/opencode/default.nix` only installs the package from `llm-agents`.
- `llm-agents` flake input is currently declared inside the Claude module.
- `packages/nonono/` already provides a bubblewrap + nono shell wrapper.
- Reference OpenCode HM module at `/nix/store/.../home-manager/modules/opencode/` shows a solid pattern of generated JSON configs, two wrappers, nono integration, and symlinked agent/command dirs.

## Target Shape

- Keep tool-specific runtime config in `aspects/dev/claude/` and `aspects/dev/opencode/`.
- Move reusable instructions, docs, skills, and workflow text into a shared tree `aspects/dev/llm/shared/`.
- Make both Claude and OpenCode Home Manager modules symlink shared files into their native config directories.
- Keep tool-specific command and agent wrappers where tool APIs differ.
- Follow the generated-JSON + wrapper patterns from the reference module.
- Use `nono` for sandboxing, not `maybe`.

---

## Phase 1: Shared Source Layout

Create a shared directory for reusable content:

- `aspects/dev/llm/shared/docs/`
- `aspects/dev/llm/shared/skills/`
- Optional shared prompt fragments for review agents and commands.

Move reusable Claude docs and skills there first:

- `aspects/dev/claude/docs/*` (except Claude-only docs like CLAUDE.md itself)
- `aspects/dev/claude/skills/*`

Update references inside moved files from Claude-specific paths (`@~/.claude/docs/...`) to tool-neutral paths that resolve in both contexts.

## Phase 2: Nix Module Reuse

Add a shared LLM module at `aspects/dev/llm/default.nix` to own common setup:

- Declare `flake-file.inputs.llm-agents` once (remove from Claude module).
- Define shared path assumptions such as the dotfiles checkout path.
- Avoid a broad abstraction unless it clearly reduces duplication.

Update Claude module:

- Remove the duplicated `llm-agents` input declaration.
- Keep Claude-specific files: `settings.json`, `statusline.sh`, `CLAUDE.md`.
- Symlink shared `docs` and `skills` into `~/.claude/`.

Update OpenCode module:

- Install `inputs.llm-agents.packages.${system}.opencode`.
- Symlink shared `docs` and `skills` into `~/.config/opencode/`.
- Add `OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1` in the wrapper if both Claude and OpenCode skill paths would otherwise be discovered twice.

## Phase 3: OpenCode Config Generation (nix)

Build configs in Nix using `pkgs.writers.writeJSON`, following the reference module pattern.

### `baseConfig`

```nix
baseConfig = {
  "$schema" = "https://opencode.ai/config.json";
  autoupdate = false;
  shell = "fish";
  instructions = [
    "~/.config/opencode/docs/*.md"
  ];
  agent = {
    bigbrain = {
      mode = "subagent";
      model = "openai/gpt-5.5";
      description = "To be used for complex tasks (similar to opus)";
    };
    normal = {
      mode = "subagent";
      model = "opencode-go/deepseek-v4-pro";
      description = "To be used for general tasks (similar to sonnet)";
    };
    lightweight = {
      mode = "subagent";
      model = "opencode-go/deepseek-v4-flash";
      description = "To be used for lightweight tasks (similar to haiku)";
    };
  };
  permission = {
    external_directory = {
      "~/.claude/**" = "allow";
    };
    skill = {
      "*" = "ask";
      ctx-load = "allow";
      ctx-save = "allow";
      mem-editing = "allow";
      proj-editing = "allow";
    };
  };
};
```

### `mainConfig` (normal operation)

```nix
mainConfig = lib.recursiveUpdate baseConfig {
  permission = {
    "*" = "ask";
    read = "allow";
    edit = "allow";
    grep = "allow";
    bash = {
      "*" = "ask";
      # <port from claude settings.json permissions.allow Bash patterns>
      # ...
    };
    webfetch = "ask";
    websearch = "allow";
  };
};
```

### `openCodeNonoConfig` (sandboxed operation)

```nix
openCodeNonoConfig = lib.recursiveUpdate baseConfig {
  permission = {
    "*" = "allow";
    bash = "allow";
    webfetch = "allow";
    websearch = "allow";
  };
};
```

Write both with `pkgs.writers.writeJSON`.

### `tui.json`

```nix
pkgs.writers.writeJSON "tui.json" {
  "$schema" = "https://opencode.ai/tui.json";
  theme = "tokyonight";
};
```

## Phase 4: Wrappers

### `opencode`

```nix
pkgs.writeShellScriptBin "opencode" ''
  export OPENCODE_ENABLE_EXA=1
  exec ${pkgs.opencode}/bin/opencode "$@"
'';
```

### `nono-opencode`

```nix
pkgs.writeShellScriptBin "nono-opencode" ''
  export OPENCODE_ENABLE_EXA=1
  export OPENCODE_CONFIG=${openCodeNonoJson}
  exec nono shell --allow-cwd -p ${openCodeNonoProfile} -- ${pkgs.opencode}/bin/opencode "$@"
'';
```

Where `openCodeNonoProfile` is a JSON profile file at `aspects/dev/opencode/nono-profile.json`.

### nono Profile

```json
{
  "extends": "coding-agent",
  "filesystem": {
    "read": ["$HOME/.claude"],
    "allow": [
      "$HOME/.config/opencode",
      "$HOME/.local/share/opencode",
      "$HOME/.cache/opencode",
      "$HOME/.local/state/opencode"
    ]
  },
  "network": {
    "block": false
  }
}
```

## Phase 5: Symlinks

```nix
home.file =
  (mkOpencodeConfSymlinks ".config/opencode" "opencode" [
    "commands"
    "agents"
  ])
  // {
    ".config/opencode/opencode.json".source = opencodeJson;
    ".config/opencode/opencode-nono.json".source = openCodeNonoJson;
    ".config/opencode/tui.json".source = tuiJson;
  };
```

Where `mkOpencodeConfSymlinks` uses `config.lib.file.mkOutOfStoreSymlink` pointing to `dotfilesPath/aspects/dev/opencode/...`.

## Phase 6: OpenCode AGENTS.md

Create `aspects/dev/opencode/AGENTS.md` as the OpenCode entrypoint.

It should:

- Preserve the important personal rules from `CLAUDE.md`.
- Replace Claude tool names with OpenCode names where needed.
- Keep references to shared docs.
- Avoid relying on OpenCode's Claude compatibility fallback, since we are creating native OpenCode config.

Rules engine: add `instructions` in `opencode.json` pointing at `~/.config/opencode/docs/*.md` so shared docs are loaded without `@` reference parsing.

## Phase 7: Commands

Port Claude commands into `aspects/dev/opencode/commands/`. Start from the reference module's already-ported command set. Port remaining Claude commands only when missing.

For each command:

- Use filename as command name.
- Use only OpenCode-supported frontmatter: `description`, `agent`, `model`, `subtask`.
- Remove Claude-only frontmatter: `name`, `argument-hint`.
- Replace Claude tool names:
  - `TaskCreate` → `todowrite`
  - `AskUserQuestion` → `question`
  - `EnterPlanMode` references → use OpenCode `plan` agent wording
  - `TaskOutput` guidance → rely on Task tool summaries
- Adjust `!`command`` shell expansions carefully (both tools support them).
- New commands to add (from reference module): `/jj-absorb`, `/jj-resolve-conflicts`.

## Phase 8: Agents

Port Claude agents into `aspects/dev/opencode/agents/`. Use the reference module's agents as starting point (already ported).

Agents to port:

- `code-style-reviewer`
- `code-correctness-reviewer`
- `architecture-reviewer`
- `requirements-reviewer`
- `branch-diff-summarizer`

For each:

- Add `mode: subagent` in frontmatter.
- Remove Claude-only frontmatter like `name`.
- Set read/review permissions, usually `edit: deny`.
- Replace `@~/.claude/docs/reviewing-agent.md` with `~/.config/opencode/docs/reviewing-agent.md`.
- Preserve REVIEW comment format.

## Phase 9: Hooks And Plugins

Handle Claude-only settings explicitly:

- `statusline.sh`: leave Claude-only unless OpenCode has a direct supported equivalent.
- Notification hook: prefer OpenCode TUI attention settings if enough; otherwise add a small local plugin.
- Compact/session-start hook: implement an OpenCode plugin using compaction/session events if needed to remind the agent to reload context.
- Claude enabled plugins: do not blindly port; map only known equivalents.

## Phase 10: Optional Sandboxed Wrapper Parity

If parity with `claude-sandboxed` matters, create `opencode-sandboxed`.

Reuse only the obvious Docker helper logic:

- passthrough env vars
- Docker profile exports
- Docker env args
- volume policy

Avoid extracting a generic sandbox framework unless both wrappers remain simple after extraction.

---

## File Manifest

### New files

| File | Purpose |
|---|---|
| `aspects/dev/llm/default.nix` | Shared LLM module (llm-agents input, dotfiles path) |
| `aspects/dev/llm/shared/docs/*` | Shared docs (code-style.md, development.md, project-doc.md, reviewing-agent.md, version-control.md, workflows.md) |
| `aspects/dev/llm/shared/skills/mem-editing/SKILL.md` | Shared mem-editing skill |
| `aspects/dev/llm/shared/skills/proj-editing/SKILL.md` | Shared proj-editing skill |
| `aspects/dev/opencode/AGENTS.md` | OpenCode entrypoint instructions |
| `aspects/dev/opencode/nono-profile.json` | nono sandbox profile for OpenCode |
| `aspects/dev/opencode/commands/*` | Ported command files (24 from reference, ~3 more) |
| `aspects/dev/opencode/agents/*` | Ported agent files (5 review agents) |

### Modified files

| File | Change |
|---|---|
| `aspects/dev/claude/default.nix` | Remove llm-agents input decl; import shared LLM module; symlink shared docs/skills |
| `aspects/dev/opencode/default.nix` | Full rewrite: generated configs, wrappers, symlinks, nono profile |

### Unchanged files

| File | Reason |
|---|---|
| `aspects/dev/claude/CLAUDE.md` | Keep as Claude entrypoint |
| `aspects/dev/claude/settings.json` | Claude-specific runtime config |
| `aspects/dev/claude/statusline.sh` | Claude-specific |
| `packages/nonono/package.nix` | Already handles nono + bubblewrap |

---

## Validation

- [ ] Nix formatting (`nix fmt` or equivalent)
- [ ] `nix flake check`
- [ ] `home-manager switch --flake .` (dry-run first)
- [ ] `opencode debug config` after activation
- [ ] Start `opencode` — confirm:
  - global config loads
  - commands appear in autocomplete
  - agents appear in autocomplete
  - skills are listed once (not duplicated from claude compatibility)
  - `/ctx-load` works
  - permissions match expected behavior
- [ ] Start `nono-opencode` — confirm:
  - runs under nono sandbox
  - sandboxed config applies (permissive)
  - network functional
- [ ] All ported review agents produce `// REVIEW:` comments correctly
