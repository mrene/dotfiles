# Agent Structure

Guidelines for writing Claude Code agents (subagents).

## Agent Structure

```yaml
---
name: agent-name
description: Brief description of what the agent does and when to use it
---

# Agent Title

## Context

Role definition with personality traits and standards. Agents often use emphatic language
to reinforce thoroughness ("uncompromising standards", "ruthlessly pedantic", "fanatically
pedantic").

## Instructions

Numbered steps with 🔳 notation. Steps should be explicit about:
* What to load/search
* How to process each item
* What output to produce

## Agent Specific Checklist

Bullet list of domain-specific checks the agent performs, wrapped in XML tags for referencing.
```

## Description Guidelines

* Make specific and discoverable
* Describe the domain (code style, architecture, correctness)
* Include trigger phrases for when to use the agent
* Bad: "Reviews code"
* Good: "Reviews code for logic correctness, potential bugs, and runtime issues"

## Task Tracking for Agents

Per CLAUDE.md, steps with 🔳 automatically become TaskCreate items. Agents use this for:

* Multi-step workflows with distinct phases
* Per-item processing (files, rules, requirements)
* Steps where skipping is a risk

### Dynamic Task Creation

For per-item work (reviewing rules, processing files), create tasks dynamically:

```markdown
3. 🔳 Create rule/file tasks
   - For each rule in checklist: `TaskCreate` with subject "Check: [rule]"
   - For each file to process: `TaskCreate` with subject "Process: [filename]"

4. 🔳 Execute tasks
   - For each task: do work, mark complete
```

**Benefits:**
* Each item becomes a task that can't be skipped
* Cross-file issues surface naturally (one rule across all files at once)
* Prevents checklist fatigue

### Key Differences from Commands

| Aspect | Command | Agent |
|--------|---------|-------|
| Gate | **STOP AND WAIT** - user confirms | None (🚀 Engage thrusters) |
| User interaction | AskUserQuestion | Return to caller |
| Task purpose | User visibility + gating | Internal discipline |

## Common Patterns

### Context Loading

Agents typically start by loading project context:

```markdown
1. STOP, follow pre-flight instructions
   THEN, continue

2. Load the `ctx-load` skill using the `Skill` tool to get project context, branch state, and project docs.

🚀 Engage thrusters - As a sub-agent, proceed immediately after loading context.
```

### Guideline Discovery

Search for project-specific guidelines before reviewing:

```markdown
2. Search project-specific [domain] guideline files (from the root of the repository) and read
   them (ex: `**/*style*.md`, `**/*guide*.md`, etc.)
```

### REVIEW Comment Pattern

Agents insert review comments directly in code:

```markdown
**INSERT** a `// REVIEW: agent-name - <comment>` comment in the code where the issue is found.
Include description of the problem, potential consequences, and suggested fix. Don't replace any
existing code, simply add the comment.
```

### Comprehensive Summary

Always return a summary even if no issues found:

```markdown
**IMPORTANT**: Always return a comprehensive summary of your review, even if you added review
comments to the code. Even if no issues are found, you MUST identify areas for improvement.
If truly no issues exist, provide a detailed explanation of what was examined.
```

### Sub-agent Communication

If agent is a sub-agent, don't notify user directly:

```markdown
Since you're a sub-agent, **NEVER** notify the user of the completion of your task. This will be
done via the parent agent. Just return the result as specified.
```

## Reviewer Agent Checklist Template

For code review agents, include domain-specific checks wrapped in XML tags:

```markdown
## Agent Specific Checklist

<agent-name-checklist>
* Rule 1
* Rule 2
...
</agent-name-checklist>
```

**Code Style**: readability, naming, formatting, comments, imports, dead code
**Architecture**: patterns, coupling, modularity, interfaces, scalability
**Correctness**: error handling, null checks, bounds, concurrency, security
