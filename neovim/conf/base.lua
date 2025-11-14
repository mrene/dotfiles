-- Misc settings
vim.opt.showmatch = true -- show matching brackets/parenthesis
vim.opt.incsearch = true -- find as you type search
vim.opt.hlsearch = true -- highlight search terms
vim.opt.smartcase = true -- case sensitive when uc present
vim.opt.ignorecase = true -- case insensitive search

vim.opt.autoindent = true -- indent at the same level of the previous line
vim.opt.timeoutlen = 505 -- time to wait for a key code sequence to complete, need to be >500 since whichkey detects recursion with 500ms

vim.opt.textwidth = 100 -- max line length, because we aren't on a mainframe anymore
vim.opt.formatoptions:remove("t") -- don't auto-wrap text (but comments will still auto-wrap (+c))

-- Enable spell checking with camel case support
vim.opt.spell = true
vim.opt.spelloptions = { "camel", "noplainbuffer" }

vim.opt.undofile = true -- Persists the undo across sessions

-- Lower cursor hold time (for highlighting)
-- Should not be too low since it writes to swap with this delay as well
vim.opt.updatetime = 500 -- time to wait for a write to disk

-- Line numbers (see keymap.lua for toggling)
vim.opt.relativenumber = true -- relative line numbers
vim.opt.number = true -- show current absolute number instead of 0

-- Defaults to space indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- disable netrw file explorer (because we use nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- support for .nvim.lua or .nvimrc per project
vim.opt.exrc = true

-- Split behaviour.
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Setup leader key as space.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("", "<Space>", "<Nop>")

function Try(description, fn)
	local success, result = pcall(fn)
	if not success then
		vim.notify("Failed to execute " .. description .. ": " .. result, vim.log.levels.ERROR)
	end
end

-- Executes a function that is suppose to change the current buffer or buffer position (ex: goto definition)
-- and waits until it happens.
function AwaitBufferChange(fn)
	local current_buf = vim.api.nvim_get_current_buf()
	local current_cursor = vim.api.nvim_win_get_cursor(0)

	fn()

	local i = 0
	while true do
		local new_buf = vim.api.nvim_get_current_buf()
		local new_cursor = vim.api.nvim_win_get_cursor(0)
		if new_buf ~= current_buf or new_cursor[1] ~= current_cursor[1] or new_cursor[2] ~= current_cursor[2] then
			break
		end
		vim.wait(50)

		i = i + 1
		if i > 100 then
			vim.notify("Buffer or cursor change timed out", vim.log.levels.ERROR)
			break
		end
	end
end

function FloatingWindowText(content)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))

	-- Open in floating window
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		noremap = true,
		silent = true,
		callback = function()
			vim.api.nvim_win_close(win, true)
		end,
	})

	return buf, win
end

-- Open nvim messages in a floating window
function MessagesBuffer()
	local output = vim.fn.execute("messages")
	FloatingWindowText(output)
end
vim.api.nvim_create_user_command("MessagesBuffer", MessagesBuffer, {})
vim.keymap.set("n", "<Leader>o", MessagesBuffer, { desc = "Open messages in floating window" })

-- pretty print
function PPrint(v)
	print(vim.inspect(v))
end

function PPrintFloat(v)
	FloatingWindowText(vim.inspect(v))
end
