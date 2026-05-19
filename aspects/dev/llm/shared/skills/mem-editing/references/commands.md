# Slash Command Structure

Guidelines for writing slash commands for Claude Code.

## Template

```markdown
---
name: command-name
description: Brief one-line purpose
argument-hint: [optional-arg]
---

# Command Title

Clear purpose statement.

Target: `$ARGUMENTS`

## Instructions

1. STOP, follow pre-flight instructions
   THEN, continue

2. 🔳 Ensure X loaded
   - Skip if already done

3. 🔳 Do main work
   - Details...

4. **STOP AND WAIT** - Await `/proceed` confirmation
```

Note: Per CLAUDE.md, steps with 🔳 automatically become TaskCreate items. All commands include pre-flight step 1 referencing CLAUDE.md pre-flight instructions.

## Command Guidelines

* Front-load critical rules (STOP points, approval gates)
* Use phases for multi-step workflows
* Single emphasis level (CRITICAL or Important, not both)
* Imperative mood throughout

## Optimization Workflow

When optimizing existing instructions:

1. **Analysis Phase**
   * Read target file and all linked files (@docs references)
   * Identify issues: verbosity, unclear structure, weak examples, cross-file redundancy
   * Compare against best practices
   * List specific issues with examples
   * Show before/after for key changes
   * Estimate token savings

2. **Wait for Approval**

3. **Implementation Phase**
   * Apply optimizations systematically
   * Remove meta-commentary
   * Consolidate redundant examples
   * Convert prose to lists/tables where clearer
   * Use imperative mood
   * Front-load critical rules
   * Single emphasis level
   * **Preserve all salient information**
