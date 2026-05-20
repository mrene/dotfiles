---
name: jj-absorb
description: Distribute files from current change into their matching ancestor changes in the stack
argument-hint: [change-id]
---

# Absorb Changes

Distribute files from a change (default: `@`) into ancestor changes that last modified them.
Only targets changes within the current stacked branch (from `jj-stacked-stats`).
Useful after review fixes, bulk edits, or any work touching files across multiple stacked changes.

Source: `$ARGUMENTS` (change to absorb from, defaults to `@`)

Current branch: `!jj-current-branch`

## Instructions

1. Pre-flight then continue

2. 🔳 Survey the stack
   - Run `jj-stacked-stats` to see all stacked branch changes and their files
   - Run `jj diff --stat -r <source>` to see files to distribute
   - If no files to distribute, report and stop

3. 🔳 Match files to targets
   - Only consider changes visible in `jj-stacked-stats` as targets
   - For each file in the source, find the most recent stacked change that modified it
   - NEVER target an earlier change when a more recent one also modified the same file —
     squashing into earlier changes causes cascading conflicts in all descendants.
     "Most recent" is the rule, not "semantically best fit"
   - Files with no direct match: assign to the most semantically related change based on
     its description and the other files it contains
   - Group files by target change

4. 🔳 Present plan
   - Show table: target change (short id + description) → files to absorb
   - Show any unmatched files (will remain in source)
   - Wait for user confirmation before proceeding

5. 🔳 Execute squashes
   - For each target group: `jj squash -u -f <source> -t <target> <files...>`
     `-u` keeps destination message as-is, preventing editor popup that blocks execution
   - After all squashes, run `jj log` to check for conflicts

6. 🔳 Handle conflicts (if any)
   - If conflicts appear, run `/jj-resolve-conflicts`
   - After resolution, verify stack is clean

7. 🔳 Verify final state
   - `jj-stacked-stats` to show final stack
   - Note if source change is now empty (user decides whether to abandon)
   - Report what was absorbed where
