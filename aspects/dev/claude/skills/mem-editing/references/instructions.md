# Instruction Files Structure

Guidelines for CLAUDE.md, memory files, and structured prompting.

## Structured Prompting

Claude 4.x was trained to understand XML tags as cognitive containers, not just code. Proper structure significantly improves output quality.

### Basic Prompt Structure

For task-oriented prompts, use: **[Role] + [Task] + [Context]**

```
[Role]: You are a code reviewer specializing in security.
[Task]: Review this authentication module for vulnerabilities.
[Context]: This is a Node.js Express app using JWT tokens. Focus on token validation and session handling.
```

This structure front-loads the task (what to do) before context (background information).

### XML Tags vs Markdown Headers

**Use XML tags when**:
* Complex multi-part tasks requiring explicit boundaries
* Constraints that must be enforced (validation rules)
* Preventing context bleed between sections
* Chain-of-thought reasoning needs exposure

**Use Markdown headers when**:
* Simple, linear structure
* Human-readable documentation
* Single-purpose files
* Content flows naturally between sections

### Tag Hierarchy and Priority

Outer tags receive higher priority weighting. Structure critical constraints at outer levels, details nested within:

```xml
<task>
  <constraints>  <!-- High priority - processed first -->
    Never exceed 100 words
    Output must be valid JSON
  </constraints>
  <context>  <!-- Lower priority - provides background -->
    Additional details and background...
  </context>
</task>
```

### Content Isolation

Separate tags prevent context contamination. Better than narrative comparisons:

```xml
<good_example>
Concise, explicit instruction that triggers correct behavior
</good_example>

<bad_example>
Verbose, vague instruction that leads to confusion
</bad_example>
```

### Constraint and Validation Tags

Validation rules within tags become enforceable constraints:

```xml
<output_format>
  <validation>
    - Must be valid JSON
    - Array length between 1-10
    - Each item under 50 characters
  </validation>
</output_format>
```

### Basic Structure Pattern

```xml
<background_information>
Context about the system and conventions
</background_information>

<instructions>
Step-by-step tasks to perform
</instructions>

<examples>
Canonical examples demonstrating expected behavior
</examples>
```

Benefits:
* Helps model parse intent effectively
* Separates concerns (context vs. instructions vs. examples)
* Improves token efficiency through clear boundaries

## CLAUDE.md Structure

**WHY, WHAT, HOW**:
* **WHAT**: Tech stack, project structure, monorepo layout
* **WHY**: Project purpose, component functions, design rationale
* **HOW**: Build commands, test procedures, verification steps

**Progressive Disclosure**:

Create a docs directory for detailed information:

```
agent_docs/
  ├─ building.md
  ├─ testing.md
  ├─ conventions.md
  └─ architecture.md
```

CLAUDE.md points to these files; Claude reads relevant ones per-task.

**What NOT to Include**:

* Don't auto-generate via `/init`. Each line affects every interaction—manually craft content.
* Don't embed code snippets. Prefer `file:line` references over code copies. Snippets become outdated; references stay accurate.

## Memory Files (docs/*.md)

```markdown
# Section Title

Brief context.

## Subsection

* Concise bullet points
* Avoid prose where lists suffice
* One emphasis level (CRITICAL for critical items)

## Examples

<example>
User: scenario
Assistant: ideal response
</example>

## Important Notes

* Front-load critical rules
* Reference other docs: @~/.claude/docs/filename.md
```
