
# Code Style

## Comments

* Explain "why" not "what" - avoid obvious/redundant
* Comments describe current state, not evolution
  * no "now uses", "changed to", "updated to" (that's git history's job)
  * no references to specific bugs or investigations that motivated the code — describe the
    general design intent (specific fix context belongs in git history)
* Docstrings describe generic capability, not specific use cases - document WHAT it does, not WHY it was created for a particular feature
* Don't mark sections with comments ("// Test Helpers", "// Public Methods", ASCII art). File structure should be self-evident. If markers seem needed, split the file.

## Errors

* Error handling is descriptive and actionable
  * In Go, no bare `return nil, err` - always wrap

## Code organization in files

Before writing any code, always ensure organization follows this order:

<file-organization-order>
1. **Main/Primary** - Core purpose
2. **Public before private** - APIs before implementation
3. **Dependencies at bottom** - Helpers, utilities. Topological sort
</file-organization-order>
