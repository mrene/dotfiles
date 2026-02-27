---
name: pr-import-comments
description: Import unresolved PR review comments as inline code comments with metadata for replies
context: fork
model: haiku
---

# PR Import Comments

Fetch unresolved GitHub PR review comments and import them into the codebase as inline comments with metadata. This allows review comments to be addressed directly in the code and then replied to programmatically.

## Instructions

1. STOP, follow pre-flight instructions
   THEN, continue

2. 🔳 Get PR info
   - Current branch: !`jj-current-branch`
   - Current PR number: !`gh pr view $(jj-current-branch) --json number --jq '.number'`
   - Repo owner: !`gh repo view --json owner --jq '.owner.login'`
   - Repo name: !`gh repo view --json name --jq '.name'`

3. 🔳 Fetch comments
   - Use GitHub GraphQL API to fetch all unresolved review threads
   - Command:

     ```bash
     gh api graphql -f query="
     {
       repository(owner: \"$OWNER\", name: \"$REPO\") {
         pullRequest(number: $PR_NUMBER) {
           reviewThreads(first: 50) {
             nodes {
               isResolved
               comments(first: 1) {
                 nodes {
                   databaseId
                   id
                   body
                   path
                   line
                   author { login }
                   createdAt
                   url
                 }
               }
             }
           }
         }
       }
     }" --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | .comments.nodes[0]'
     ```

4. 🔳 Import comments
   - For each unresolved comment, add sub-task "Import: [path:line]"
   - Read the file at the specified path
   - Insert inline comment at the specified line number using this format:

     ```
     // REVIEW: pr-import-comments (DB: <databaseId>, Node: <nodeId>, PR: <prNumber>) - <author> @ <createdAt>
     // URL: <url>
     // Location: <path>:<line>
     // <comment body line 1>
     // <comment body line 2>
     // ... (continue for all lines in the comment body)
     ```

   - Handle multi-line comment bodies by prefixing each line with `//`
   - Preserve proper indentation matching the surrounding code

5. 🔳 Report results
   - Count of comments imported
   - List of files modified
   - Any errors encountered during import

6. **STOP** - Do not fix, address, or respond to imported comments; this command imports only.

## Important Notes

- Only import unresolved comments (isResolved == false)
- Preserve exact line numbers from the API response
- Handle edge cases like files that don't exist or invalid line numbers gracefully
- Don't modify existing code, only add review comments
