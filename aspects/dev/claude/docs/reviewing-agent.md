# Code Review Agent Guidelines

Shared infrastructure for code review agents. All review agents follow this workflow

## Reviewer Workflow

1. STOP, follow pre-flight instructions
   THEN, continue

2. 🔳 Load context
   - Run `/ctx-load` for project context, branch state, project docs
   - 🚀 Engage thrusters - As sub-agent, proceed immediately after loading

3. 🔳 Gather guidelines (merge in priority order)
   - Project guidelines: Find via Scope patterns (highest salience)
   - User guidelines: Only if explicitly referenced in agent's Scope section
   - General Guidelines: Agent's built-in criteria (in agent file)

4. 🔳 Create rule tasks
   - From merged guidelines (project > user > general), for EACH rule create `TaskCreate`:
     - Subject: "Check: [rule name]"
     - Description: What to look for + good/bad examples
   - 🔳 Create one task using `TaskCreate` for EACH rule

5. 🔳 Load changed files
   - Run `jj-diff-branch --stat` to list modified files
     - Exclude reviewing docs themselves and generated files (e.g., *.pb.go)
   - For each file to be reviewed:
     - Load diff: `jj-diff-branch --git <file>`
     - Load surrounding context if needed to understand changes

6. 🔳 Execute rule checks
   - For EACH check task:
     - Mark task in-progress
     - Examine changed hunks for this issue
       - Apply `<deep-thinking>` procedure
       - Focus on changed code, not unrelated areas (unless blatant problem)
     - For EACH violation found, IMMEDIATELY call the `Edit` tool to insert a comment:
       `// REVIEW: [agent-name] - <description of issue, consequences, suggested fix>`
       - Place the comment on the line above or next to the issue
       - Edit tool is the ONLY way to report issues — text in your response does not count
       - If Edit fails (parallel agent modified file), re-read the file and retry Edit
       - Insert ALL violations, minor or major
     - Mark task complete before next rule

7. 🔳 Cross-file synthesis
   - Look back at all files and rules, add comments for issues that span multiple files that may
     have been missed

8. 🔳 Verify insertions
   - Search changed files for `// REVIEW:` using the Grep tool
   - If you found issues but grep returns no matches, go back to step 6 and insert via Edit
   - Every reported issue MUST have a corresponding comment in the code

9. 🔳 Return summary in one SINGLE LAST message
   - Overall assessment to parent agent
   - If issues found: list each as `file:line - brief description` (comment text is in the code)
   - If no issues: explain what was examined

## Sub-agent Rules

- NEVER notify user directly - return results to parent agent
  - Results returned via comprehensive summary message
  - Parent agent handles aggregation and user communication

- NEVER modify the code directly for fixes
  - Only insert REVIEW comments
  - User will decide on actual code changes

- NEVER create `jj` changes since multiple reviewers run in parallel
  - Parent agent manages `jj` operations after collecting all reviews

- Do NOT use external tools (bash, formatter, linters, etc.)
  Rely solely on your training and the guidelines provided

- Other reviewer agents may run in parallel
  - It's normal for code to change, and you may have to-read for latest changes
  - Ensure that you are inserting comments on the correct version of the code
