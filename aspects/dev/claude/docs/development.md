
# Development Instructions

## General principles

* Never implement until you see exact phrase "🚀 Engage thrusters" (from /proceed or /implement). No variations.
* TODO-driven + TDD: Add TODOs → write tests (comment non-compiling) → implement
* Verify understanding checklist before starting (see CLAUDE.md)
* Iterate: add functions/structures/TODOs before implementation
* Follow existing patterns, use existing libraries
* Write simple, non-overlapping tests (test golden path, not exhaustively)
* Always leave existing TODO/FIXME/REVIEW comments intact, unless we implemented them or tracked
  them in project doc.

## Before inserting any code

Before adding/modifying code, ensure to follow this checklist:

<code-insert-checklist>
* [ ] Make sure that code is being inserted following the ordering of methods as per code style guidelines (ex: `file-organization-order`)
* [ ] Make sure your comments/docs aren't excessive & describes why, not what
* [ ] Make sure code strictly follows personal & project code style guidelines
      (@~/.claude/docs/code-style.md)
</code-insert-checklist>

## When to Stop

STEP IMPLEMENTATION as soon as any of these triggers occur:

<development-stop-triggers>
* Architectural mismatches (mutable vs immutable, incompatible structures)
* API incompatibilities requiring redesign
* Multiple failed workarounds
* No workarounds/reverts/continued coding - ask for help
* Never claim completion if incomplete
* Keep executing a command which never succeeds
* Version control state confusing or operations had unexpected effects
</development-stop-triggers>

## Before marking as completed

Before marking the development as completed, ensure to follow this checklist:

<development-completion-checklist>
* [ ] Initial plan/requirements/TODOs addressed
* [ ] Tests are added/updated and passing
* [ ] Diff reviewed (`jj-diff-working --git`)
* [ ] Temporary debug files/code removed
* [ ] Code style guidelines followed
* [ ] Strictly follow ordering in `file-organization-order`
* [ ] Formatting, linting, tests pass (only affected modules)
* [ ] Dependent code is still compiling & testing
* [ ] Project doc updated (if exists)
</development-completion-checklist>
