---
name: ctx-usage
description: Break down Messages portion of context window - conversation turns, tool calls/results by tool, largest items, optimization hints. Complements /context which covers static categories.
---

# Context Usage

Analyze the **Messages** portion of context window in detail.
Complements `/context` which covers static categories (memory files, skills, agents).

**Requires**: Run `/context` first for static overview. Will STOP if not done.

## Instructions

1. Pre-flight then continue

2. 🔳 Verify `/context` was run
   - Look in conversation history for `/context` output (local-command-stdout with token breakdown)
   - If not found: **STOP** - tell user to run `/context` first, then re-run `/ctx-usage`

3. 🔳 Analyze messages and report breakdown
   Scan the full conversation history. Estimate tokens as chars ÷ 4.

   **By Type**
   | Type | Count | Est. Tokens | % of Messages |
   |------|-------|-------------|---------------|
   | Tool results | | | |
   | Assistant msgs | | | |
   | User messages | | | |
   | System reminders | | | |
   | Tool calls | | | |
   | **Total** | | | 100% |

   **Tool Results by Tool** (aggregate)
   | Tool | Calls | Est. Tokens | Avg/call |
   |------|-------|-------------|----------|

   **Largest Individual Items** (top ~7, any type)
   | Turn | Type | Description | Est. Tokens |
   |------|------|-------------|-------------|

4. 🔳 Optimization hints
   Give specific, actionable suggestions based on the breakdown:
   - Large Task agent results → use `/forked` to isolate agent work from parent context
   - Many Read results → stale reads accumulate; fresh session + `/ctx-load` if nearing limit
   - Repeated system reminder injections → note which memory files trigger most frequently
   - Long assistant messages with thinking → reduce if not needed
   - Messages > ~60k tokens → recommend fresh session with `/ctx-load`
