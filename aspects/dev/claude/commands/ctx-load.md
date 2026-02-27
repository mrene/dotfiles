---
name: ctx-load
description: Load comprehensive project context including docs, project info, and branch status
---

# Load Context

Load context about the project and task at hand

## State

* Current branch: !`jj-current-branch`
* Project files: !`claude-proj-docs`

## Instructions

1. STOP, follow pre-flight instructions
   THEN, continue

2. 🔳 Read project docs (use State above - don't re-discover)
   * If project files found:  
     * Read main project doc for context, requirements, progress
     * Read & summarize checkpoint section if exists
   * If "No project files", may be uninitialized
     * STOP, inform user about missing context

3. 🔳 Load current phase docs if referenced in checkpoint or you think relevant for current work
      But be mindful of context window cost

4. 🔳 Check & resolve ambiguity
   * If multiple phases or tasks in progress, use `AskUserQuestion` to clarify focus unless the
     checkpoint is clear on next steps

5. 🔳 Synthesize context
   * Summarize current project state
