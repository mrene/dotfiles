---
name: introspect
description: Reflect on an error or undesired behavior to propose instruction improvements
argument-hint: [description of issue]
---

# Introspect

Reflect on what went wrong and propose instruction changes to prevent recurrence.

Issue: `$ARGUMENTS`

## Instructions

1. STOP, follow pre-flight instructions
   THEN, continue

2. If issue empty, use `AskUserQuestion` to get description

3. Analyze the issue:
   * Use the <deep-thinking> procedure
   * What specific error/behavior occurred?
   * Trace back: what instruction was missing, unclear, or conflicting?
   * Which files might have related concepts? Search for them
   * We don't want specific fixes/root cause, we want to identify the generic underlying issue that
     caused this and how to prevent it in the future

4. Summarize findings:
   * Root cause
   * Files that need changes (including files with related concepts)
   * Conceptual changes needed
   * Need to be generic, not specific to this case

5. Use `AskUserQuestion` to confirm analysis and suggest:
   "Run `/mem-edit` to implement these changes with proper analysis workflow"

**STOP** - Do not implement changes directly. Use /mem-edit for implementation.
