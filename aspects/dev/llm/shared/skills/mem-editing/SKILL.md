---
name: mem-editing
description: Instructions to be used as soon as any instruction, CLAUDE.md, command, skill or agent file needs to be changed.
argument-hint: [files or description]
---

# Instruction Editing Guidelines

Guidelines for editing Claude Code instruction files (CLAUDE.md, commands, skills, agents, docs).
Load supporting files as needed for the specific component type being edited.

## File Locations

All my personal instruction files live in `~/nixworld/dotfiles/aspects/dev/claude/`:

- `CLAUDE.md`, `commands/`, `skills/`, `agents/`, `docs/`
- `~/.claude/` paths are symlinks to this location — always edit at the dotfiles source

## When to Use

Any time instruction files are created or modified: optimization, bug fixes, adding rules,
refactoring, new commands/skills/agents.

## Editing Principles

- Preserve all salient information - never silently drop content
- Check for redundancy and conflicts across files before editing
- Apply principles from supporting docs below (match the component type)
- Consider surrounding style: load neighboring commands/skills/agents to match patterns
- Use `AskUserQuestion` for ambiguities

## What to Check

- Ambiguity - what could a fresh agent misinterpret?
- Cross-file conflicts - do related files have contradicting rules?
- Redundancy - is this duplicated elsewhere?
- Missing context - does this assume knowledge not provided?

## Supporting Files

- @references/core.md: Core principles (self-verification, minimal info, writing style)
- @references/skills.md: Skill structure, naming, progressive disclosure, description guidelines
- @references/commands.md: Slash command structure and optimization workflow
- @references/instructions.md: CLAUDE.md, memory files, structured prompting
- @references/agents.md: Agent structure and patterns
