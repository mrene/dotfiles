---
name: proj-edit
description: Edit project and phase docs with structure validation
argument-hint: [operation or file]
---

# Edit Project Docs

User-facing command for project/phase doc changes. Analyze first, then gates before applying

Target: `$ARGUMENTS`

## Instructions

1. STOP, follow pre-flight instructions
   THEN, continue

2. 🔳 Load skills using the `Skill` tool
   - `proj-editing` - for doc structure and validation
   - `ctx-plan` - for planning steps

3. 🔳 Ensure scope identified
   - If target unclear, use `AskUserQuestion` to clarify what operation:
     - Create project doc
     - Create phase doc
     - Update task status
     - Update phase status
     - Validate structure

4. 🔳 Analyze current state
   - Read relevant project/phase docs
   - Identify changes needed

5. 🔳 Report proposed changes
   - Show before/after for each change

6. **STOP AND WAIT** - Await `/proceed` confirmation before applying changes

7. 🔳 Apply with proj-editing skill
