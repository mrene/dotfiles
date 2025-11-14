require("which-key").add({
	{ "<leader>r", group = "Execute" },
	{ "<leader>T", group = "Toggle" },
	{ "<leader>m", group = "Marks" },
	{ "<leader>q", group = "Quit..." },
	{ "<leader>y", group = "Clipboard" },
})

vim.keymap.set("n", "<Leader>qq", ":q<CR>", { silent = true, desc = "Quit current split/window" })
vim.keymap.set("n", "<Leader>qa", ":qa!<CR>", { silent = true, desc = "Quit nvim" })
vim.keymap.set("n", "<Leader>qs", ":SessionDelete<CR>:qa<CR>", { silent = true, desc = "Clear session & quit nvim" })

-- Marks (m[a-z0-9A-Z], 'a-z0-9A-Z)
vim.keymap.set("n", "<Leader>mk", ":delmarks a-z0-9A-Z<CR>", { silent = true, desc = "Marks: delete all" })

-- Command-line mappings for "sudo save" and quick quit commands
vim.cmd([[
  cnoremap w!! w !sudo tee % >/dev/null
  cnoremap wq wqa
  cnoremap Wq wqa
  cnoremap Wqa wqa
  cnoremap WQ wqa
  cnoremap WQa wqa
  cnoremap wqaa wqa
  cnoremap WQaa wqa
  cnoremap Qw wqq
  cnoremap qw wqq
]])

-- Misc
local function exec_shell_in_floating(script)
	local output = vim.fn.system({ "sh", "-c", script })

	local buf_content = script .. "\n\n" .. output
	FloatingWindowText(buf_content)
end

local function get_selected_visual()
	-- Get the current mode to check if we're in visual mode
	local mode = vim.api.nvim_get_mode().mode

	-- If we're in visual mode, we need to exit it to set the marks properly
	if mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" or mode == "\22" then -- v, V, or <C-v>
		-- Exit visual mode to set the marks
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)
	end

	local srow, scol = unpack(vim.api.nvim_buf_get_mark(0, "<"))
	local erow, ecol = unpack(vim.api.nvim_buf_get_mark(0, ">"))
	if srow <= 0 or erow <= 0 then
		vim.notify("No selection found", vim.log.levels.WARN)
		return ""
	end

	-- Get the selected text
	local lines = vim.api.nvim_buf_get_text(0, srow - 1, scol, erow - 1, ecol + 1, {})
	return table.concat(lines, "\n")
end

local function send_visual_to_sh()
	local script = get_selected_visual()
	exec_shell_in_floating(script)
end

local function send_block_to_sh()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("vib", true, false, true), "x", true)

	send_visual_to_sh()
end

local function send_file_to_sh()
	local buf = vim.api.nvim_get_current_buf()
	local file_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local file_content = table.concat(file_lines, "\n")
	exec_shell_in_floating(file_content)
end

vim.keymap.set("n", "<Leader>rf", send_file_to_sh, { silent = true, desc = "Execute current file" })
vim.keymap.set("v", "<Leader>rl", send_visual_to_sh, { silent = true, desc = "Execute selected lines" })
vim.keymap.set("n", "<Leader>rb", send_block_to_sh, { silent = true, desc = "Execute code block" })
vim.keymap.set("n", "<C-_>", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlight" }) -- C-/

-- Clipboard / yanking
local function copy_selection_to_clipboard()
	local selected = get_selected_visual()

	-- Write to a temp file
	local temp_file = os.tmpname()
	local file = io.open(temp_file, "w")
	if not file then
		vim.notify("Failed to open temp file for writing", vim.log.levels.ERROR)
		return
	end
	file:write(selected)
	file:close()

	-- Copy the temp file to the clipboard
	vim.fn.system("pbcopy < " .. temp_file)

	-- Remove the temp file
	os.remove(temp_file)
end
vim.keymap.set("v", "<Leader>yy", copy_selection_to_clipboard, { desc = "Clipboard: Copy to system clipboard" })
vim.keymap.set("n", "<Leader>yp", ":read !pbpaste<CR>", { desc = "Clipboard: Paste from system clipboard" })
vim.keymap.set("n", "<Leader>yc", "yygccp", { remap = true, desc = "Clipboard: Copy line & comment it" })

-- Toggling
local function toggle_wrap()
	if vim.wo.wrap then
		vim.wo.wrap = false
		vim.wo.linebreak = false
	else
		vim.wo.wrap = true
		vim.wo.linebreak = true
	end
end
vim.keymap.set("n", "<Leader>Tw", toggle_wrap, { silent = true, desc = "Toggle line wrap" })
vim.keymap.set("n", "<Leader>Tm", function()
	if vim.o.mouse == "a" then
		vim.o.mouse = ""
		vim.o.relativenumber = false
		vim.o.number = false
	else
		vim.o.mouse = "a"
		vim.o.relativenumber = true
		vim.o.number = true
	end
end, { silent = true, desc = "Toggle mouse support" })

local function toggle_numbers()
	if vim.wo.relativenumber then
		vim.wo.relativenumber = false
		vim.wo.number = false
	else
		vim.wo.relativenumber = true
		vim.wo.number = true
	end
end
vim.keymap.set("n", "<Leader>Tn", toggle_numbers, { silent = true, desc = "Toggle line numbers" })

-- Spellcheck
vim.keymap.set("n", "<Leader>Ts", ":set spell!<CR>", { silent = true, desc = "Toggle spellcheck" })

-- Window navigation from terminal mode
-- local function term_nav_keymap(lhs, rhs)
-- 	vim.keymap.set("t", lhs, "<C-\\><C-n>" .. rhs, { noremap = true, silent = true })
-- end
-- term_nav_keymap("<C-w>h", "<C-w>h")
-- term_nav_keymap("<C-w>j", "<C-w>j")
-- term_nav_keymap("<C-w>k", "<C-w>k")
-- term_nav_keymap("<C-w>l", "<C-w>l")
-- term_nav_keymap("<C-w><Left>", "<C-w>h")
-- term_nav_keymap("<C-w><Down>", "<C-w>j")
-- term_nav_keymap("<C-w><Up>", "<C-w>k")
-- term_nav_keymap("<C-w><Right>", "<C-w>l")

-- Multicursors
-- https://github.com/smoka7/multicursors.nvim
require("multicursors").setup({})
vim.keymap.set({ "n", "v" }, "<C-n>", "<cmd>MCstart<cr>", { silent = true })
