# Useful bindings

Navigation:

Go back: Ctrl+O 
Go forward: Ctrl+I
Go to last change: `. 

Live grep + find file
<leader>ff Find file
<leader>fg Fast grep

## LSP
Goto def; gd
Goto decl: gD
Hover: K
Goto Impl: gi
Ctrl+K: Signature Help
<space>D Type definition
<space>rn Rename
<space>ca Code action
gr Find References
<space>f Format

# File navigation
Ctrl-e Toggle Tree
Ctrl-f Show current file in tree

### In tree:
q close
g? Show commands

# NERDCommender
<leader>a Toggle comment


# Git
- `:GV` to open commit browser
    - You can pass `git log` options to the command, e.g. `:GV -S foobar -- plugins`.
- `:GV!` will only list commits that affected the current file
- `:GV?` fills the location list with the revisions of the current file

`:GV` or `:GV?` can be used in visual mode to track the changes in the
selected lines.

### Mappings

- `o` or `<cr>` on a commit to display the content of it
- `o` or `<cr>` on commits to display the diff in the range
- `O` opens a new tab instead
- `gb` for `:GBrowse`
- `]]` and `[[` to move between commits
- `.` to start command-line with `:Git [CURSOR] SHA` à la fugitive
- `q` or `gq` to close
