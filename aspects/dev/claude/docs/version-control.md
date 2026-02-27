# Version Control (Jujutsu)

We are using `jj` (collocated with git), which is always detached head state
Never use `git`, unless absolutely necessary

## Commands

| Purpose | Command |
|---------|---------|
| Commit current | `jj commit -m "private: claude: description"` |
| Commit specific files of current | `jj commit -m "private: claude: description" <files...>` |
| New empty change | `jj new -m "private: claude: description"` |
| Rename current change | `jj describe -m "private: claude: description"` |
| Squash current into parent, changing parent message | `jj squash -m "private: claude: description"` |
| Squash current into parent, keep parent message | `jj squash -u` |
| Squash specific files to parent | `jj squash -u <files...>` |
| Diff (git style) | `jj diff --git` |
| Diff working | `jj-diff-working --git` (`--stat` for files) |
| Diff branch | `jj-diff-branch --git` |
| Current branch | `jj-current-branch` |
| Main branch | `jj-main-branch` |
| Previous branch | `jj-prev-branch` |
| Stacked branches | `jj-stacked-branches` |
| Stacked stats | `jj-stacked-stats` |

## Creating Changes

Commands:

* `jj commit -m "msg"` - Finalize CURRENT changes with message, create new empty change
* `jj new -m "msg"` - Create NEW empty change with message (current changes stay in parent)
* `jj describe -m "msg"` - Set message on current `@` without creating a new change

Use `commit` after changes. Before starting new work, check if `@` is already empty:

* `@` is empty → `jj describe -m "..."` (avoid `jj new` which creates an orphaned empty intermediate)
* `@` has changes → `jj new -m "..."`

Run `jj ls` before committing to verify changes are in expected place

When to create changes:

* Before starting implementation (after planning)
* After tests pass
* Before refactoring working code
* Before addressing review comments
* When switching to different area of codebase
* Skip for: read-only ops, iteration within same logical step

Default to more changes - easier to squash than split
Never clean up commit history (squash, abandon empty changes, reorder). User handles that

## Commit Messages

Prefix commits with `"private: claude: "` so they can be easily identified and squashed before PR
Always use `-m "message"` for commands that expect a message since they could open editor:
  `jj commit -m ...`
  `jj new -m ...`
  `jj squash -m ...` => will change destination message, use -u to keep destination

<good-example>
jj commit -m "private: claude: fix validation bug"
jj commit -m "private: claude: feat(workspace): add collections API"
</good-example>

<bad-example>
jj commit -m "fix validation bug"
jj commit -m "feat(workspace): add collections API"
</bad-example>

## State Verification

Before any jj write operation, run `jj ls`:

* Expected: Clean working copy OR only changes you made in this session
* Unexpected: Pre-existing changes, unknown modifications, conflicts

If state is unexpected: STOP immediately

* Do NOT attempt to fix — report what you found and ask for clarification

## Dangerous Operations

Before using any of these, run `jj diff --stat -r <change>` to verify the change is truly empty/safe:

* `jj abandon` - Removes change from history. Descendants re-parent onto abandoned change's parent
* `jj restore` (without paths) - Wipes all changes in target revision
* `jj squash --into <non-parent>` - Moves content across non-adjacent changes, graph shifts unpredictably
* `jj rebase -r` - Extracts change from chain, descendants lose its contribution

If the change has content or you're unsure: STOP and ask user

<bad-example>
jj squash --into @--    # Moved content across non-adjacent changes
jj abandon @--          # Destroyed change with actual content (didn't verify first)
# Result: cascading abandonments, all implementation work lost
</bad-example>

## Revset Safety

* `@` and `@-`: safe for standard operations (commit, new, squash into parent)
* `@--` and beyond: NEVER use for write operations — relative targets shift after graph modifications
* After any graph-modifying operation: re-run `jj log` before using relative revsets
* For destructive operations: capture the change ID from `jj log`, use it directly

## Recovery

If something goes wrong, STOP and report before attempting recovery:

* `jj undo` - Reverses last operation. NOT stackable (second undo = redo)
* `jj op log` - Shows all operations with IDs
* `jj --at-op <op_id> log` - Inspect repo state at a past operation (read-only)
* `jj op restore <op_id>` - Restores repo to a specific past state

For multi-step recovery: `jj op log` → `jj --at-op` to inspect → `jj op restore`. Not repeated `jj undo`

## Notes

* Use `--git` flag for readable diff output
* For `gh` commands: use `$(jj-current-branch)` since always detached
