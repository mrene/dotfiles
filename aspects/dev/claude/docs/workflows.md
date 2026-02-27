# Workflows

These are commands, internal skills, and agents designed to streamline workflows

You should always prioritize those throughout our interactions

## Commands

### Actions

Main workflows for quick interaction.

- `/ask`: Analyze without acting
- `/think`: Deep thinking for complex problems
- `/implement`: Start implementing tasks that we have planned
  - Loads tasks from phase doc, executes, validates, runs `/ctx-save`
- `/forked <skill>`: Fork to sub-agents
  - Decomposes skill work, launches parallel agents, collects results
  - Parent agent does everything to prevent overloading its context window
- `/proceed`: Continue from STOP points
- `/continue`: Resume interrupted work

### Project Management

- `/proj-init`: Initialize project folder
- `/proj-edit`: Edit project/phase docs
- `/proj-tidy`: Validate doc consistency

### Context Management

- `/ctx-load`: Load project context
- `/ctx-save`: Save progress to project docs
- `/ctx-plan`: Create development plan
  - Research → plan → write to docs → STOP waits for `/implement`
- `/ctx-check`: Output uncertainty disclosure
- `/ctx-improve`: Clarify understanding via exploration, reasearch and questions
- `/ctx-usage`: Break down Messages portion of context window (tool results by tool, largest items, hints)
  - Run `/context` first for static overview, then `/ctx-usage` for message-level detail

### Reviewing

- `/review-launch`: Launch review agents
  - Spawns 4 agents in parallel (style, correctness, architecture, requirements)
- `/review-search`: Find REVIEW comments
- `/review-plan`: Plan fixes for REVIEW comments
  - Phase 1: Research → prioritize → STOP
  - Phase 2: After `/implement`, executes fixes

### Instructions

- `/mem-edit`: Edit instruction files
  - Will use the `mem-editing` skill, plan using `ctx-plan`
  - Once user approves with `/proceed`, will execute edits

- `/introspect`: Reflect on errors
  - Analyzes issue → proposes changes → suggests `/mem-edit`

### Pull Requests

- `/pr-desc`: Generate PR description
- `/pr-import-comments`: Import PR comments
- `/pr-reply-comments`: Reply to PR comments

## Internal Skills

- `mem-editing`: Guidelines for editing instruction files (commands, skills, agents, docs)
- `proj-editing`: Should be used for any edit to project or phase docs

## Agents

- `branch-diff-summarizer`: File-by-file change summaries
- `code-style-reviewer`: Style, formatting, syntax
- `code-correctness-reviewer`: Logic, bugs, runtime issues
- `architecture-reviewer`: Architecture, patterns
- `requirement-analyzer`: Requirement gaps
