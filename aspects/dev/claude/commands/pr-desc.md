---
name: pr-desc
context: fork
description: Generate detailed changelog-style summary of branch changes
model: haiku
---

# PR Description

Generate a detailed changelog-style summary of branch changes for reference. Uses project context
and branch diff to create multi-level breakdown.

## Instructions

1. STOP, follow pre-flight instructions
   THEN, continue

2. 🔳 Ensure context loaded
   - Run `/ctx-load` to load project context (project doc, branch state, recent commits)

3. 🔳 Analyze changes
   - Get changed files: `jj-diff-branch --stat`
   - Read diffs for understanding: `jj-diff-branch --git`
   - Use the <deep-thinking> procedure
   - If user specified a focus area, prioritize those components

4. 🔳 Generate report in one message, without any following messages:
   - **High-level summary** (2-3 sentences):
     - What was the main goal/accomplishment
     - Key technical approach taken

   - **Per-component breakdown**:
     - Group changes by logical component (directory, module, or feature area)
     - For each component, list changes by category:
       - **Added**: New files, features, capabilities
       - **Changed**: Modified behavior, refactored code
       - **Fixed**: Bug fixes, corrections
       - **Removed**: Deleted files, deprecated features
     - Skip empty categories
