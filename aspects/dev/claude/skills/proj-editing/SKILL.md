---
name: proj-editing
description: Internal skill for project/phase doc editing. Called by /proj-edit command or other commands needing doc edits. No gate - flows with caller.
argument-hint: [operation or file]
---

# Project Doc Editing

Edit project documentation following the structure in @~/.claude/docs/project-doc.md.

Target: `$ARGUMENTS`

## When to Use

- Creating or modifying project docs (`00-*.md`)
- Creating or modifying phase docs (`01-*.md`, `02-*.md`, etc.)
- Validating doc structure
- Updating task status, requirements, or phases

## Key Structures

Reference these XML blocks from @~/.claude/docs/project-doc.md:

- `<project-doc-sections>` - Sections for project doc (Context, Checkpoint, Requirements, Questions, Phases, Files)
- `<phase-doc-sections>` - Sections for phase docs (Context, Requirements, Questions, Tasks, Files)
- `<phase-format>` - How to reference phases in project doc
- `<task-format>` - Task indicators `[ ]`, `[~]`, `[x]`

## Core Rules

1. **Tasks only in phase docs** - Project doc has Phases section (references), NOT Tasks section (items)
2. **Every phase gets a phase doc** - No exceptions, even for small projects
3. **Requirements in project doc** - Phase docs only expand with R5.A, R5.B notation
4. **Checkpoint in project doc only** - Phase docs don't have checkpoints

## Operations

### Create Project Doc

1. Read `<project-doc-sections>` structure
2. Create `00-<name>.md` with all sections
3. Phases section references first phase doc

### Create Phase Doc

1. Read `<phase-doc-sections>` structure
2. Create `NN-<phase-name>.md`
3. Context references project doc
4. All task `[ ]` items go here

### Update Task Status

1. Find task in **phase doc** (NOT project doc)
2. Update: `[ ]` → `[~]` → `[x]`
3. If all tasks done, ask user about phase ✅

### Update Phase Status

1. In **project doc** Phases section
2. Update: `⬜` → `🔄` → `✅` (user decides ✅)

### Validate Structure

1. Check project doc follows `<project-doc-sections>`
2. Check phase docs follow `<phase-doc-sections>`
3. Verify no task items in project doc
4. Verify all phases have phase docs
