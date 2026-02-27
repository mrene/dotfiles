# General

* Name: AP
* Environment:
  * OS: NixOS + MacOS (home manager, nix darwin)
  * Shell: fish

## Top-level instructions

* No superlatives, excessive praise, excessive verbosity - ALWAYS assume tokens are expensive

* ALWAYS optimize for TOTAL present and future tokens
  * Use the <deep-thinking> procedure to think through before acting

* NEVER NEVER NEVER NEVER call `TaskOutput` to get agent output or read agent transcript files — for
  both foreground and background agents, these return raw execution transcripts, not summaries.
  Agents provide their summary directly in the Task tool result. Background agents deliver their
  summary automatically when done
  Only call `TaskOutput` or read transcript if user explicitly asks for it, and try to use a
  sub-agent to do it if possible
  If an agent's summary is insufficient, use the `resume` parameter on the Task tool to re-engage
  the agent and ask targeted follow-up questions — never use TaskOutput as a workaround

* When a skill or agent returns output, ALWAYS present it to the user. Never dismiss and redo
  the work. If output needs reformatting, reformat — don't start from scratch

* When starting a new conversation, ALWAYS make sure to load the relevant project context using `/ctx-load`

* NEVER implement until you receive this exact signal: "🚀 Engage thrusters"
  * NEVER ask via `AskUserQuestion` if you can proceed - wait for signal
  * STOP and WAIT before proceeding after asking a question - wait for signal

* ALWAYS use `AskUserQuestion` to ask questions. Never ask directly in response

* ALWAYS go for the simplest and most maintainable solution that meets the requirements
  instead of over-engineering. KISS & Occam's razor principles

* Planning is mandatory for ALL implementations, no matter how trivial
  * NEVER engage the native plan mode `EnterPlanMode`. Refer to workflows for planning instructions
  * When agreed on a plan, ALWAYS follow it and ALWAYS stop & ask if you deviate or the plan fails

## Sub-instructions files

* Workflows: @~/.claude/docs/workflows.md
* Project doc structure: @~/.claude/docs/project-doc.md
* Version control: @~/.claude/docs/version-control.md
* Development: @~/.claude/docs/development.md
* Code style: @~/.claude/docs/code-style.md

## Pre-flight instructions

Before executing instructions of any command/skill/agent instructions:

* When you receive instructions, before executing anything ALWAYS create tasks using `TaskCreate`
   for each instruction step that has 🔳 annotation BEFORE executing anything
  * Create one or more tasks per 🔳 step, 1:n mapping using the `TaskCreate` tool
  * No ad-hoc replacements or broader grouping
  * THEN execute the instructions & tasks in order
  * Marking in-progress/completed as you proceed, always make sure you do so and make as completed
    previous tasks if you forgot to mark them on a later step

* ALWAYS use project & phase docs to plan and track work @~/.claude/docs/project-doc.md using the
  proper project editing skills

## Bash instructions

* Avoid operations that bypass my allow list uselessly:
  * Avoid prefixing commands with env set (`VAR=value command`) unless necessary
  * NEVER use `find` in bash — use the Glob tool for file discovery and Grep tool for content search
    `find` bypasses the allow list; Glob + Grep handle all common patterns including combined file matching and content search

* Avoid writing random python/node/bash scripts to do file operations
  I'll need to approve them which leads to unnecessary back and forth

## Context understanding

Always ensure 10/10 understanding checklist: explore code + web search + `AskUserQuestion`
Always report on understanding at any decision point - verbalize WHAT you understand for each item, not just that you checked it. User validates your understanding

<full-understanding-checklist>
* [ ] Clear on goal/user need: [state the goal]
* [ ] Identified similar use cases: [list them]
* [ ] Understand existing patterns: [describe patterns]
* [ ] Re-read file structure: [list key files]
* [ ] List existing functions/classes: [name them]
* [ ] Have test strategy used to iterate: [describe approach]
* [ ] Know which files to modify: [list files]
* [ ] Know success criteria: [state criteria]
</full-understanding-checklist>

## Destructive Operations

Before deleting files/content: ALWAYS make sure we can restore by any means
Always assume you are not alone working on the same code at same time

* ALWAYS preserve unknown code and ask instead of deleting / restoring it

## Problem Solving

ALWAYS use this methodology to solve problems, issues, and bugs:

<problem-solving-checklist>
1. Understand WHY (trace data flow, logging, changes)
2. Fix root cause, not symptom. Generic solution over specific case and bespoke fixes
3. Ask user before destructive changes
4. Test bugs: verify new test catches issue or update existing test to catch it
</problem-solving-checklist>

## Deep Thinking

When a command/skill/agent requires thorough analysis, apply these steps:

<deep-thinking>
1. STOP rushing - invest thinking tokens now to save iteration tokens later
2. Re-read all relevant context - don't rely on memory
3. Analyze thoroughly (ultra think, be pedantic)
4. Externalize your thinking - speak your mind LOUDLY, don't just use thinking blocks
5. Think as a fresh agent - what could be misinterpreted? What's ambiguous?
6. Question assumptions - what haven't you verified?
</deep-thinking>
