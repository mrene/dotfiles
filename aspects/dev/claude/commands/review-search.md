---
name: review-search
description: Search for REVIEW comments in the codebase
---

# Search Review Comments

1. STOP, follow pre-flight instructions
   THEN, continue

2. Search for REVIEW comments using the `Grep` tool:

   ```
   Grep(pattern="(//|#|--|/\\*|\\*)\\s*REVIEW:", output_mode="content")
   ```

   * Ignore results in `proj/` (project documentation)
   * Do NOT use Bash rg with glob exclusions - they fail silently
   * A review comment with `>>` and `<<` indicates a multi-line comment;
     lines between `>>` and `<<` are part of the review comment

3. If no comments found, verify you're at repository root and pattern matches the language
   Otherwise, STOP and report no findings

**If invoked directly by user, STOP** after reporting findings. If invoked from another command,
continue with that command's workflow
