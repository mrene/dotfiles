---
name: review-plan
description: Research REVIEW comments, present plan, then fix after /implement
---

# Plan and Fix Review Comments

Research REVIEW comments, present prioritized plan, then execute fixes after /implement.

REVIEW comments are my way of communicating issues or improvements to act on right away.
They aren't left for future consideration nor to be ignored.

## Instructions

### Phase 1: Plan

1. STOP, follow pre-flight instructions
   THEN, continue

2. 🔳 Ensure REVIEW comments found
   - Use `/review-search` unless we just searched
   - If launching via forked, ask agents to use `/review-search`
     Never roll your own search

3. 🔳 Research each comment
   - Read surrounding code to understand the issue
   - Check related files if change has broader impact
   - Identify dependencies between review items

4. 🔳 Categorize and prioritize
   - **Priority**: High (critical/security), Medium (important), Low (minor/stylistic)
   - **Effort**: Quick Win, Moderate, Extensive
   - **Dependencies**: Note order requirements

5. 🔳 Check requirements
   - Verify fixes don't contradict existing requirements
   - Update existing requirements if needed (don't create new ones)

6. 🔳 Update project doc
   - Add fixes to Tasks section with priorities

7. 🔳 Present plan
   - Show prioritized list with research findings

8. **STOP AND WAIT** - Wait for `/implement`

### Phase 2: Execute

After `/implement` is called, follow its workflow with these review-specific additions:

1. 🔳 Create tasks from REVIEW comments
   - One TaskCreate per comment: "Fix: [file:line]"

2. 🔳 For each fix
   - Remove REVIEW comment after addressing it
   - Never replace with "// Note:" explanations

3. 🔳 Verify completion
   - Search for remaining REVIEW comments
   - Search for orphaned removals (comments removed without fix)

## Important Rules

* **NEVER** replace REVIEW comments with "// Note:" explanations. Report to user if you
  believe they are unnecessary, keep the comment, and let user decide.

* **NEVER** skip a comment. If you want to pushback, fix other comments first, then clearly
  state which you didn't address and why. User decides.
