---
name: think
description: Trigger deep thinking mode for complex problems
argument-hint: [problem or context]
effort: xhigh
---

# Think

Thorough, rigorous analysis for complex problems where shallow thinking isn't cutting it.

**NEVER**: Never modify files, run side-effect commands, or start implementation

Context: `$ARGUMENTS`

## Instructions

1. Pre-flight then continue

2. If context empty or unclear, use `AskUserQuestion` to clarify

3. 🔳 Research and understand
   * Apply <deep-thinking> procedure
   * Use sub-agents to explore codebase, read files, do research
   * What is really being asked? What would success look like?
   * Map full scope: files involved, related files, cross-file concepts

4. 🔳 Analyze and evaluate
   * Question assumptions: what haven't you verified? Simplest explanation?
   * Consider 2-3 alternative approaches, why one is better
   * Draft solution mentally, then critique it. What could go wrong?

5. 🔳 Present findings with structure
   * Show reasoning, what was considered, why this approach
   * Challenge assumptions

6. **STOP**: User will decide next steps
