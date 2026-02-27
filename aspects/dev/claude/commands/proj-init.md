---
name: proj-init
description: Initialize project folder with project doc and first phase doc
argument-hint: [task-description]
---

# Project Initialization

Create project folder with project doc and phase doc(s). Structure from @/.claude/docs/project-doc.md.

Task: $ARGUMENTS
Current date: !`date +%Y/%m/%d`

## Instructions

1. STOP, follow pre-flight instructions
   THEN, continue

2. 🔳 Load `proj-editing` skill using the `Skill` tool
   - Read @/.claude/docs/project-doc.md completely for full understanding of doc structure

3. 🔳 Ensure **high level** task description is clear so that we can name it properly
   - If empty, use `AskUserQuestion` to clarify
   - Don't go into a full planning mode, that will be done in a next step after creating files

4. 🔳 Set up project folder
   - Derive name from `jj-current-branch`, confirm with `AskUserQuestion`
   - Create directory per `File Location` in @/.claude/docs/project-doc.md
   - Create symlink: `ln -s <project-folder> proj`
   - Commit symlink: `jj commit -m "private: proj - <project-name>"`

5. 🔳 Clarify project details if needed so that we can fill the project squeleton
   - If more thorough understanding needed, ask user if we can invoke `/ctx-plan`
   - If shallow planning needed
     - Use `/ctx-improve` until 10/10 understanding per `full-understanding-checklist`
     - Update docs after each clarification

6. 🔳 Create project doc (00-<name>.md)
   - Follow project doc structure from @/.claude/docs/project-doc.md
   - Add phase references in Phases section

7. 🔳 Create phase doc(s) (01-<name>.md, etc.)
   - Follow phase doc structure from @/.claude/docs/project-doc.md
   - Confirm phase name(s) with `AskUserQuestion`
   - Commit docs: `jj commit -m "private: claude: docs - <project-name>"`

8. **STOP AND WAIT** - User decides when to `/implement`
