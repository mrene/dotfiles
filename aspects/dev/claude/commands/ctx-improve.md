---
name: ctx-improve
description: Improve context by asking clarifying questions
effort: xhigh
---

# Improve Context

Use the full understanding checklist and verify our full (10/10) understanding of the task at hand.

Important: any modifications to project or phase docs need to be done via `proj-editing` skill.

## Instructions

1. Pre-flight then continue

2. 🔳 Check current understanding
   - If 10/10 understanding, tell me and stop here
   - Otherwise, tell me your current understanding on a 10 scale

3. 🔳 Research context
   - Launch sub-agents to explore codebase, find patterns
   - Search web for external dependencies or unfamiliar concepts
   - Use <deep-thinking> procedure
   - For each unknown discovered, add sub-task to investigate

4. 🔳 Ask clarifying questions
   - Use `AskUserQuestion` for each ambiguity
   - Research and ask until 10/10 understanding
   - Clarification is not approval - do not jump to implementation
   - Go back to step 2 after each answers that require further analysis
     Should add more tasks 🔳 to track progress

5. 🔳 Update project doc
   - If working on a planned task, update with new context
   - Add/update requirements as R-numbered items (R1, R2, R1.1) for task traceability
   - Add ACs to tasks: specific verifiable conditions that define done per task
   - Requirements describe behavior (WHAT), not implementation (HOW)

6. Report 10/10 understanding achieved. User decides next action (may run /implement, /ctx-plan, or give direction).
