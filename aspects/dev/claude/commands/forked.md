---
name: Forked
description: Fork a skill's work to sub-agents for parallel execution
argument-hint: [/skill1 & /skill2 ...] [instructions]
---

# Forked

Fork one or more skills, understand their instructions and orchestrate their execution across sub-agents

Main agent should ONLY be responsible for:

- Task decomposition based on skill instructions and current context
- Launching sub-agents
- Updating project docs along the way
- `jj` operations as per skill requirements

Everything else must be done by sub-agents launched to handle specific tasks (research,
implementation, reviews, etc.). This applies to ALL tasks: trivial, obvious or not

NEVER make judgment calls on if something is simple enough to be done by main agent

## Instructions

1. Pre-flight then continue

2. 🔳 Make sure task at hand clear. If not, use `AskUserQuestion` to clarify

3. 🔳 Parse `$ARGUMENTS` to identify skills and additional context
   - Unless already loaded in your context, load each skill from ~/.claude/skills or
     ~/.claude/commands
   - Extract instructions & tasks from loaded skills
   - Think how to best decompose work into independent sub-tasks by agents
   - Make sure if more than one skill involved, dependencies between skills managed
   - Should not be too granular to avoid overhead, but not too broad to cause conflicts
   - If skill has multiple phases (ex: plan+implement) you MUST launch multiple sub agents to
     properly separate their context

4. For each agent to be launched, create tasks:
   - Launch agent to do X
   - Analyse results
   - Update project docs if applicable using `/ctx-save` procedure (on main agent)

5. If skill requires to create `jj` change, make sure to create before launching sub-agents

6. 🔳 Launch sub-agents in sequence OR parallel, based on task dependencies
   - Sub-agent instruction prompt:
     - Give as much details as possible on the context, what needs to be implemented, which project
       docs to load, which section of the plan to follow, and any other relevant information

     - Tell the sub-agent they NEED skill(s) via the `Skill` tool, create tasks from its 🔳 steps,
       and follow its full process (checklists, validation). Tell the sub-agent that it should NEVER
       do the steps that are parent-only responsibilities (listed above, jj/docs/etc.). Give the
       exact step number as well to prevent confusion


     - Tell agent can stop early for clarifications from user, you can send a follow-up message after

     - You need to make sure that across all sub-agents, ALL of the steps that were instructed in the
       skills were covered and accomplished

   - Sub-agent output otpimization:
     - Instruct sub-agent to debrief concisely in one final message
       (target: ~500 tokens research, ~1000 implementation):
       - Lead with actionable findings, not the process
       - Changed files with one-line description each
       - Results (pass/fail) and next steps or blockers

     - We should have enough information in the debrief to orchestrate next steps and update
       documentation, but should always aim for context window optimization

   - Your context window is very precious
     - NEVER do any validation or verification yourself
       No tests, builds, browser snapshots, code inspection or any other form of checking
       Listing chaninged files is ok, but not diffing or reading their content
       Route ALL verification to a sub-agent

     - NEVER call `TaskOutput` or read agent output files. Foreground agents return results in the
       tool response. Background agents deliver summaries automatically

     - If an agent's debrief is insufficient, send it a follow-up message to re-engage and ask
       targeted follow-up questions

7. 🔳 Collect debriefs, analyse results and report on overall progress

      If a debrief lacks needed detail, send the agent a follow-up message rather than reading raw
      transcripts

      Make sure progress reflected in project docs as per instructions in the skill using `/ctx-save` procedure

      Handle `jj` operations as per skill and development instructions requirements
