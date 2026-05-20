---
name: review-launch
description: Launch review agents for code style, architecture and correctness.
effort: high
---

# Launch Review

Goal is to launches 4 specialized review agents in parallel to review code changes

They have all of the necessary instructions internally to figure out what to review, don't instruct
them on otherwise since you may bias them, unless the user explicitly asks you to review something
specific. The only thing you can press is to follow their internal instructions to the letter

The parent agent should launch the agent with NO EXTRA PROMPT since agents already have all the
context loading capabilities

## Instructions

1. Pre-flight then continue

2. Create a new jj change: `jj new -m "private: claude: agents review"`

3. Launch 4 specialized agents in BACKGROUND PARALLEL:
    * Agent 1: launch the "code-style-reviewer" agent
    * Agent 2: launch the "code-correctness-reviewer" agent
    * Agent 3: launch the "architecture-reviewer" agent
    * Agent 4: launch the "requirements-reviewer" agent

   Again, they already have internal instructions. Don't provide them any extra prompt, unless the
   user explicitly asks you to (ex: review something specific). By default, they will use the
   command to diff the branch with jj (`jj-diff-branch`), and you should not instruct them
   otherwise, unless the user explicitly asks you to review something specific. You should tell them
   to follow their internal instructions to the letter, without biasing them with any extra
   instructions

   Note: If an agent doesn't return any results but has finished, don't assume that it failed and
   just consider it as "no issues found". Don't restart the agents as they consume many tokens.

4. Collect results from agent summaries (returned directly for foreground agents, or delivered
   automatically for background agents). NEVER call `TaskOutput` or read agent output files.
   If an agent's summary lacks detail, send it a follow-up message to ask specific questions.
   Don't act on review comments — agents insert `// REVIEW:` comments in code directly.
   Summarize findings from agent summaries.
