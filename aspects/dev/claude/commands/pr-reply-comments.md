---
name: pr-reply-comments
description: Reply to imported PR review comments and clean up inline comments
---

# PR Reply Comments

## Prerequisites

Must have imported comments using `pr-import-comments` command first.

## Instructions

1. STOP, follow pre-flight instructions
   THEN, continue

2. 🔳 Find imported comments
   - Search for REVIEW: pr-import-comments pattern:
     ```bash
     rg "REVIEW: pr-import-comments \(DB: (\d+), Node: ([^,]+), PR: (\d+)\)" -o --replace='DB: $1, Node: $2, PR: $3'
     ```

3. 🔳 Reply to comments
   - For each imported comment, add sub-task "Reply: [DB_ID]"
   - Extract comment info:
     ```bash
     DATABASE_ID=1234567890    # From "DB: 1234567890"
     PR_NUMBER=1234           # From "PR: 1234"
     ```
   - Craft reply (must start with robot emoji):
     ```bash
     REPLY_BODY="🤖 Generated with Claude 🤖

     Here's a fix that addresses [specific issue]:

     \`\`\`rust
     // Your code fix here
     \`\`\`

     This [explanation of why the fix works].

     Thanks for catching this!"
     ```
   - Send reply via correct endpoint with PR number:
     ```bash
     gh api repos/OWNER/REPO/pulls/${PR_NUMBER}/comments/${DATABASE_ID}/replies \
       -X POST \
       -f body="${REPLY_BODY}"
     ```
   - Verify response includes:
     - `"in_reply_to_id": 1234567890` (matches your DATABASE_ID)
     - Reply appears in PR conversation thread
   - Clean up by removing inline comment after successful reply

4. 🔳 Report
   - List all replies sent

## Troubleshooting

* **404 Error**: Missing PR number in endpoint or wrong DATABASE_ID
* **Not threaded**: Check `"in_reply_to_id"` field in response
* **New inline comment**: Used wrong endpoint format
