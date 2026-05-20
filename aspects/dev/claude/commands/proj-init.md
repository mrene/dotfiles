---
name: proj-init
description: Initialize project folder with project doc and first phase doc
argument-hint: [task-description]
---

# Project Initialization

Create project folder with project doc and phase doc(s). Structure follows project-doc.md rules.

Task: $ARGUMENTS
Current date: !`date +%Y/%m/%d`

## Instructions

1. Pre-flight then continue

2. 🔳 Load `proj-editing` skill using the `Skill` tool
   - Reference the project-doc.md rules for the standard structure

3. 🔳 Ensure **high level** task description is clear so that we can name it properly
   - If empty, use `AskUserQuestion` to clarify
   - Don't go into a full planning mode, that will be done in a next step after creating files

4. 🔳 Set up project folder
   - Derive name from `jj-current-branch`, confirm with `AskUserQuestion`
   - Create directory per `File Location` in the project-doc rules
   - Create symlink: `ln -s <project-folder> proj`
   - Commit symlink: `jj commit -m "private: proj - <project-name>"`

5. 🔳 Clarify project details if needed so that we can fill the project squeleton
   - If more thorough understanding needed, ask user if we can invoke `/ctx-plan`
   - If shallow planning needed
     - Use `/ctx-improve` until 10/10 understanding per `full-understanding-checklist`
     - Update docs after each clarification

6. 🔳 Create project doc (00-<name>.md)
   - Follow the project-doc.md rules for project doc structure
   - Add phase references in Phases section

7. 🔳 Create phase doc(s) (01-<name>.md, etc.)
   - Follow the project-doc.md rules for phase doc structure
   - Confirm phase name(s) with `AskUserQuestion`
   - Commit docs: `jj commit -m "private: claude: docs - <project-name>"`

8. **GATE**: User decides when to `/implement`
