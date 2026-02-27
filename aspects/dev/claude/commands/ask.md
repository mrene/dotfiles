---
name: ask
description: Think about a topic and provide feedback without acting
argument-hint: [question or topic]
---

# Ask

Provide thoughtful analysis on a given question or topic without taking further action

**NEVER**: Never modify files, run side-effect commands, or start implementation

## Instructions

1. STOP, follow pre-flight instructions
   THEN, continue

2. If topic empty or unclear, use `AskUserQuestion` to clarify

3. 🔳 Research (code, web search, web fetch) if question requires or context is missing
   * You need to use sub-agents to explore or read codebase, do research, etc.
     Your context is precious, don't waste it
   * Analyze thoroughly
   * Apply <deep-thinking> procedure

4. 🔳 Provide analysis, opinions, alternatives. Challenge assumptions

5. **STOP**: User will decide next steps
