# Core Instruction Writing Principles

Foundational guidelines for writing effective Claude Code instructions.

## Self-Verification (Highest Leverage)

**Give Claude ways to verify its work.** Single highest-leverage technique for instruction quality.

* Include tests, expected outputs, or success criteria in instructions
* Add verification steps at the end of workflows ("Run X to confirm Y")
* Provide screenshots or examples of correct output for UI work
* Define what "done" looks like explicitly

<good-example>
After implementing, run `npm test` and verify all tests pass. The output should show "42 passing, 0 failing".
</good-example>

<bad-example>
Implement the feature and make sure it works.
</bad-example>

## Minimal, High-Signal Information

**Find the smallest set of high-signal tokens that maximize desired outcomes.** Every token depletes attention budget.

* Start with minimal prompt using best available model
* Add clarity and examples based on observed failures
* Don't anticipate every edge case upfront
* Remove meta-commentary and verbose explanations

**Reference, Don't Duplicate**: When instructions define content in XML tags (e.g., `<checklist>`), reference the tag name instead of copying content.

<bad-example>
Verify each item: [ ] Plan addressed [ ] Diff reviewed [ ] Tests pass...
</bad-example>

<good-example>
Verify each item in `development-completion-checklist`. State each item aloud.
</good-example>

**Instruction Budget**: LLMs reliably follow only 150-200 instructions. Claude Code's system prompt uses ~50, so CLAUDE.md should stay well under 150 instructions.

**Line Count**: Keep CLAUDE.md under 300 lines; under 60 lines is optimal. Put detailed docs in separate files.

## Front-Load Critical Instructions

Put most important instruction at the very top. Claude processes instructions sequentially; early content gets more attention weight.

* State the task clearly before providing context
* Critical constraints go before background information
* Structure: [Role/Task] → [Constraints] → [Context] → [Examples]

## Provide Context and Motivation

Explain *why* instructions matter—helps Claude understand goals.

**Good**: "Your response will be read aloud by text-to-speech engine, so never use ellipses since the engine won't know how to pronounce them."

**Bad**: "NEVER use ellipses."

## Universal Applicability

CLAUDE.md loads in every conversation. Include only instructions that apply to most tasks.

* Move task-specific guidance to separate files Claude reads on-demand
* If instruction applies to <50% of sessions, it doesn't belong in CLAUDE.md
* The more irrelevant content, the more Claude filters out everything uniformly

## Hooks vs Instructions

**Hooks** are shell commands that execute automatically on events (PreToolUse, PostToolUse, etc.). Use hooks instead of instructions when:

* **Action must happen every time with zero exceptions** - hooks enforce mechanically, instructions can be ignored
* **Claude already does it correctly without instruction** - delete the instruction, the behavior is trained-in
* **Instruction is frequently ignored** - convert to hook for enforcement

**Keep as instructions when:**
* Behavior requires judgment or context-sensitivity
* Action varies based on situation
* Hook implementation would be complex or brittle

**Pruning strategy:** If Claude consistently follows a rule without the instruction, remove it. Instructions that duplicate trained-in behavior waste attention budget.

## Writing Style

### Be Explicit and Direct

Claude 4.x excels with clear, specific instructions.

**System prompt sensitivity**: Claude 4.x is highly responsive to system prompts. Dial back aggressive language—where you might have said "CRITICAL: You MUST...", use normal prompting like "Use this tool when...".

**Good**: "Include as many relevant features and interactions as possible. Go beyond basics to create fully-featured implementation."

**Bad**: "Create an analytics dashboard" (too vague)

### Action Language

* Use "Change X" not "Can you suggest changes to X"
* Default to imperative mood: "Do X" not "You should do X"
* Avoid tentative phrasing: "Fix the bug" not "Maybe you could look at fixing the bug"

### Reverse Negatives

**Bad**: "Don't use markdown"

**Good**: "Write in clear, flowing prose using complete paragraphs and sentences"

### Match Style to Output

The formatting style of your prompt influences response formatting.

* Remove markdown from prompts to reduce markdown in responses
* Use prose in prompts to encourage prose in responses
* "Write in prose rather than lists unless presenting truly discrete items where list format is best option"
* Avoid bold (`**text**`) in instruction files -- it adds tokens without increasing salience for Claude. Use plain text, CAPS for emphasis, or XML tags for boundaries.

### Minimize Verbosity

Claude 4.5 is naturally concise. Reinforce when needed:

* "Provide fact-based progress reports without unnecessary verbosity"
* "No superlatives or excessive praise"
* "Never say 'You're absolutely right!' - just do the work"

## Examples

### Canonical Examples Over Edge Cases

Provide diverse, representative examples rather than exhaustive exception lists.

* Claude 4.x pays close attention to details in examples
* Ensure examples align perfectly with desired behaviors
* Models are highly sensitive to subtle patterns in examples
* 1-2 well-chosen examples better than many redundant ones

**Format**:

```xml
<example>
User: [realistic user input]
Assistant: [ideal response demonstrating all principles]
</example>
```

Or contrast good vs. bad:

```xml
<good-example>
Concise, explicit instruction that triggers correct behavior
</good-example>

<bad-example>
Verbose, vague instruction that leads to confusion
</bad-example>
```

### Scrutinize Your Examples

* Do they demonstrate the exact behavior you want?
* Are there subtle patterns that could mislead?
* Do they cover the most common use cases (not rare edge cases)?

## Quality & Reliability

### Prevent Hallucinations

"Never speculate about code you have not opened. If the user references a specific file, read the file before answering."

### Avoid Hard-Coding

"Implement general-purpose solutions using standard tools, not workarounds tailored to specific test cases."

### Token Budget Awareness

"Your context window will be automatically compacted as it approaches its limit, allowing you to continue working indefinitely."

### Tool Design Principles

For skills that use tools:

* Tools should be self-contained and robust to error
* Avoid overlapping tool functionality
* Curated minimal viable set enables better maintenance
* Use `allowed-tools` to restrict access when appropriate

## Common Anti-Patterns

| Anti-Pattern | Fix |
|--------------|-----|
| Verbose: "It is important to note that you should..." | Direct: "Use X for Y" |
| Multiple emphasis: "CRITICAL: Important: Note that..." | Single level: "Do X" |
| Tentative: "You might want to consider..." | Imperative: "Do X" |
| Many redundant examples | 1-2 diverse, canonical examples |
| Prose for discrete items | Lists for steps |
| Vague descriptions: "Helps with files" | Specific: "Parse CSV files, convert to JSON" |
| Split numbered lists across headers | Continuous list or separate lists per section |
| Skill path reference: "Load skill `@~/.claude/skills/foo/SKILL.md`" | "Load `foo` skill using the `Skill` tool" |

## References

* [Claude 4.x Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices)
* [Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
* [Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
