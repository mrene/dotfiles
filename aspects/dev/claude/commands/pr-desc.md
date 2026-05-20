---
name: pr-desc
description: Generate PR-ready summary of branch changes with per-component analysis and Summary + Implementation Notes
model: sonnet
context: fork
---

# PR Description

Generate a detailed changelog-style summary of branch changes for reference. Uses project context
and branch diff to create multi-level breakdown. Don't use sub-agents to do the work, since you're
already a forked context.

## Instructions

1. Pre-flight then continue

2. 🔳 Ensure context loaded
   - Run `/ctx-load` to load project context (project doc, branch state, recent commits)

3. 🔳 Analyze changes
   - Get changed files: `jj-diff-branch --stat`
   - Read diffs for understanding: `jj-diff-branch --git <file>`
   - Use the <deep-thinking> procedure
   - If user specified a focus area, prioritize those components
   - You can inspire from project doc, but code remains the source of truth

4. 🔳 Generate report in one message, without any following messages:
   - Load the `human-writer` skill using the `Skill` tool for tone (no AI filler, no superlatives)
   - Wrap identifiers (types, functions, files, fields) in backticks

   Emit two sections in order:

   Per-component breakdown — analysis scaffolding, not the final PR text:
   - Group changes by logical component (directory, module, or feature area)
   - For each component, list changes by category (skip empty):
     - Added: New files, features, capabilities
     - Changed: Modified behavior, refactored code
     - Fixed: Bug fixes, corrections
     - Removed: Deleted files, deprecated features

   PR-ready markdown — what the user copies into the PR description. Wrap in a ```markdown
   fenced block so it's trivial to select:

       ## Summary

       - [Observable/user-facing change — behavior, API surface, error responses, bug fixes]
       - [One bullet per distinct change, 1-3 lines, with concrete identifiers]

       ### Implementation Notes

       - **[Component or pattern]**: [How it is built — named types, algorithm, data flow]
       - **[Another component]**: [Detail]

   Split rule:
   - Summary: WHAT changed for a consumer (behavior, API, errors, fixes). Avoid internal
     identifiers unless consumer-visible
   - Implementation Notes: HOW it was built (types, refactors, algorithms, structural changes)
