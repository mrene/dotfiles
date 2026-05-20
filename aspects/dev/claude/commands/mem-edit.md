---
name: mem-edit
description: Entry point for instruction file changes - edits, fixes, optimization
argument-hint: [files or description]
---

# Edit Instructions

User-facing command for instruction file changes. Analyzes first, then gates before applying

Target: `$ARGUMENTS`

## Instructions

1. Pre-flight then continue

2. 🔳 Load skills using the `Skill` tool
    * `mem-editing` - editing guidelines and supporting files
    * `ctx-plan` - planning steps

3. 🔳 Ensure scope identified
   If target unclear, use `AskUserQuestion` to clarify

4. 🔳 Analyze target files
   * Load context around the target instruction file(s)
     * Load surrounding instructions/commands/skills/agents to understand the pattern and style
   * Apply `mem-editing` guidelines: check for ambiguity, cross-file conflicts, redundancy
   * Use the `<deep-thinking>` procedure

5. **GATE**: Await `/proceed` before applying changes

6. 🔳 Apply changes
   * Follow `mem-editing` guidelines during edits
   * Verify consistency across affected files
