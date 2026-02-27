# Skill Structure

Guidelines for writing skills for Claude Code. Based on Anthropic's skill guide and observed patterns.

## File Structure

```
skill-name/                  # kebab-case, no spaces/capitals/underscores
├── SKILL.md                 # Required - exact casing
├── references/              # Optional - docs loaded as needed
│   └── detailed-guide.md
├── scripts/                 # Optional - executable code
│   └── validate.sh
├── examples/                # Optional - working examples
│   └── example.sh
└── assets/                  # Optional - templates, icons, fonts
    └── template.md
```

### Naming Rules

* Folder: kebab-case only (`notion-project-setup`, not `Notion_Project_Setup`)
* Main file: exactly `SKILL.md` (case-sensitive, no variations)
* No README.md inside skill folder - all docs go in SKILL.md or references/

## YAML Frontmatter

### Required Fields

```yaml
---
name: skill-name-here
description: What it does. When to use it. Key capabilities.
---
```

* `name`: kebab-case, must match folder name
* `description`: under 1024 chars, no XML angle brackets (`<` or `>`)

### Optional Fields

| Field | Purpose | Example |
|-------|---------|---------|
| license | Open source license | `MIT`, `Apache-2.0` |
| compatibility | Environment requirements | `"Claude Code only"` |
| allowed-tools | Restrict tool access | `"Bash(python:*) WebFetch"` |
| metadata | Custom key-value pairs | `author: Name`, `version: 1.0.0` |

### Security Restrictions

* No XML angle brackets in frontmatter (appears in system prompt, could inject instructions)
* Names with "claude" or "anthropic" prefix are reserved

## Description Field

The description determines when Claude loads the skill. Structure it as:

`[What it does] + [When to use it / trigger phrases] + [Key capabilities]`

<good-example>
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDFs or mentioning "document extraction", "PDF conversion", or "fill PDF form".
</good-example>

<bad-example>
description: Helps with documents.
</bad-example>

<bad-example>
description: Creates sophisticated multi-page documentation systems.
</bad-example>

### Negative Triggers

When a skill over-triggers on unrelated queries, add exclusions:

```yaml
description: Advanced data analysis for CSV files. Use for statistical modeling, regression, clustering. Do NOT use for simple data exploration (use data-viz skill instead).
```

### Triggering Diagnostics

Under-triggering (skill doesn't load when it should):
* Description too vague or generic
* Missing trigger phrases users would actually say
* Missing file types or technical terms
* Fix: add specific phrases, file types, domain keywords

Over-triggering (skill loads for unrelated queries):
* Description too broad
* Overlapping scope with other skills
* Fix: add negative triggers, narrow scope, clarify boundaries

Debug: ask Claude "When would you use the [skill name] skill?" - it quotes the description back.

## Progressive Disclosure

Skills use a three-level loading system:

1. **YAML frontmatter** - always in context (~100 words). Just enough for Claude to decide relevance
2. **SKILL.md body** - loaded when skill triggers. Core instructions and workflow
3. **Linked files** - loaded on-demand as Claude needs them (references/, scripts/, etc.)

### Size Guidance

* SKILL.md body: 1,500-2,000 words ideal, under 5,000 max
* Move detailed content to references/ when SKILL.md exceeds target
* Each reference file can be large (2,000-5,000+ words)

### What Goes Where

SKILL.md (always loaded on trigger):
* Purpose statement and quick-start guidance
* Essential instructions and workflow steps
* References to supporting files with @references/filename.md

references/ (loaded as needed):
* Extended documentation and detailed patterns
* Additional examples and API specifications
* Edge cases and troubleshooting

scripts/ (executed without loading into context):
* Validation tools, testing helpers
* Deterministic tasks that would otherwise be rewritten each time

assets/ (used in output, not loaded into context):
* Templates, fonts, icons, boilerplate

### Avoiding Duplication

* Keep detailed principles in supporting files
* SKILL.md provides brief overview with cross-references
* Pattern: "Apply principles from @references/best-practices.md" instead of repeating them
* Information lives in ONE place - either SKILL.md or references, not both

## SKILL.md Template

```yaml
---
name: skill-name-here
description: Specific capability with trigger phrases. Include file types, concrete capabilities, and natural phrases users would say. Keep under 1024 chars.
---

# Skill Title

Brief purpose statement.

## When to Use

Specific triggers and scenarios.

## Core Principles

Key guidelines (reference supporting docs with @references/filename.md).

## Workflow

Clear steps for different scenarios.

## Supporting Files

* @references/referenced-file.md: Purpose
```

## Instruction Best Practices

* Be specific and actionable - "Run `scripts/validate.py --input {file}`" not "Validate the data"
* Include error handling for common failures
* Reference bundled resources clearly - "Consult `references/api-patterns.md` for rate limiting"
* Front-load critical instructions at the top of SKILL.md
* Use verification steps - "Run X to confirm Y"
