---
name: proj-tidy
description: Validate and fix project doc consistency against standard structure
context: fork
---

# Project Tidy

Validate project doc against standard structure in @~/.claude/docs/project-doc.md and fix inconsistencies.

Current project files: !`claude-proj-docs`

## Instructions

1. STOP, follow pre-flight instructions
   THEN, continue

2. 🔳 Load `proj-editing` skill using the `Skill` tool
   - Read @~/.claude/docs/project-doc.md completely for standard structure reference

3. 🔳 Read project docs
   - Read project doc (`00-*.md`) and all phase docs (`01-*.md`, etc.)

4. 🔳 Validate structure
   - Project doc follows `<project-doc-sections>` structure
   - Phase docs follow `<phase-doc-sections>` structure
   - Tasks only in phase docs (project doc should NOT have `[ ]`, `[~]`, `[x]`)
   - Every phase in project doc has corresponding phase doc
   - Cross-references between docs are valid

5. 🔳 Check requirement consistency
   - Flag overlapping requirements as potential conflicts
   - Phase doc requirements must derive from parent R-numbers (e.g., `R5.A:` not `R1:`)
   - Project doc references phase doc when phase expands requirements

6. 🔳 Check completable items
   - Flag phases where all tasks `[x]` but phase still 🔄
   - Flag requirements where linked work done but still 🔄
   - Use `AskUserQuestion` before marking ✅

7. 🔳 Triage Inbox items (if section exists)
   - For each item, propose: convert to requirement, add as phase task, move to Questions, or discard
   - Use `AskUserQuestion` to confirm triage decisions
   - Clear triaged items from Inbox

8. 🔳 Present findings
   - Group issues by category
   - Show current state and proposed fix for each
   - Use `AskUserQuestion` to confirm before applying

9. 🔳 Apply fixes after user confirmation
