---
name: ctx-save
description: Update project and phase docs with current state and progress
effort: medium
---

# Save Context

Save project state for perfect resumption. Detail level should allow anyone, including a junior
intern, to pick up where you left off. You may not be the one resuming it, be thorough and clear

Project files: !`claude-proj-docs`

## Instructions

1. Pre-flight then continue

2. 🔳 Load `proj-editing` skill using the `Skill` tool
      It's is crucial to use this skill to edit project and phase docs and strictly follow the
      project documentation structure

3. 🔳 Find docs via `proj/` symlink. Identify current phase from checkpoint or ask user

4. 🔳 Update current phase doc(s):
   * Tasks: mark completed `[x]`, add new tasks discovered
     * If all done, confirmed via `AskUserQuestion`, update phase in next step
   * Capture unresolved uncertainties and completed investigations in Questions & Investigations section
   * Files: update with changes
     * Use `branch-diff-summarizer` agent if needed not aware of files or may be missing some from
       your context)

5. 🔳 Update main project doc:
   * Checkpoint
     * Update summary of work done
     * Reference current phase and tasks
     * Next step if decided/obvious
   * Requirements
     * Read current requirements carefully
     * Update or add new ones if needed based on work done
   * Questions & Investigations
     * Add resolved questions if any
     * Add new questions if arose during work
   * Phases
     * Update status if all tasks completed + user confirmed done via `AskUserQuestion`
   * Files
     * Update with summary, with phase reference

6. 🔳 Update other phase docs:
   * Any changes in context, requirements, design choices may impact multiple phases, make sure to
     review and update them all accordingly
   * If change impacting previous/next phases, make sure they are updated accordingly
     Docs need to reflect the current state, not the historical one
   * Check modified files, good indicator of impacted phases
     Generic review/docs phases are usually impacted by any changes
     When we just conducting review, it usually involves changes in multiple phases

7. 🔳 Write project doc Checkpoint:
   * 1-2 paragraph summary of work completed
   * Reference current phase and tasks worked on
   * Next step if decided/obvious

8. 🔳 Commit doc changes:
   * Use the Version Control guidelines from the project doc instructions
