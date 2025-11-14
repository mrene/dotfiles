require("which-key").add({
	{ "<leader>b", group = "Buffers" },
	{ "<leader>n", group = "Tabs" },
	{ "<leader>w", group = "Save" },
})

-- Buffer deletion
local minibufremove = require("mini.bufremove")
minibufremove.setup({})

local function bufdelcurrent()
	minibufremove.delete(nil, true)
end

local function bufdelothers()
	local current = vim.api.nvim_get_current_buf()
	local bufs = vim.api.nvim_list_bufs()
	for _, buf in ipairs(bufs) do
		if buf ~= current then
			minibufremove.delete(buf, true)
		end
	end
end

local function bufdelall()
	WinCloseOthers()

	local bufs = vim.api.nvim_list_bufs()
	for _, buf in ipairs(bufs) do
		minibufremove.delete(buf, true)
	end
end

-- Buffer management (b)
require("mini.tabline").setup()
vim.keymap.set("n", "<Leader>bc", ":enew<CR>", { silent = true, desc = "Buf: New" })
vim.keymap.set("n", "<Leader>bq", bufdelcurrent, { silent = true, desc = "Buf: Close current" })
vim.keymap.set("n", "<Leader>bqq", bufdelcurrent, { silent = true, desc = "Buf: Close current" })
vim.keymap.set("n", "<Leader>bqo", bufdelothers, { silent = true, desc = "Buf: Close others" })
vim.keymap.set("n", "<Leader>bqa", bufdelall, { silent = true, desc = "Buf: Close all" })
vim.keymap.set("n", "<Leader>bu", ":e!<CR>", { silent = true, desc = "Buf: Undo changes (reload from disk)" })
vim.keymap.set("n", "<Leader>w", ":w<CR>", { silent = true, desc = "Buf: Save" })
vim.keymap.set("n", "<Leader>ww", ":w<CR>", { silent = true, desc = "Buf: Save" })
vim.keymap.set("n", "<Leader>wa", ":wa<CR>", { silent = true, desc = "Buf: Save all" })
vim.keymap.set("n", "<Leader>bm", ":MessagesBuffer<CR>", { silent = true, desc = "Buf: Create buffer from messages" })

-- Tab management (n)
vim.keymap.set("n", "<Leader>nc", ":tabnew<CR>", { silent = true, desc = "Tab: New" })
vim.keymap.set("n", "]n", ":tabnext<CR>", { silent = true, desc = "Tab: Next" })
vim.keymap.set("n", "[n", ":tabprev<CR>", { silent = true, desc = "Tab: Previous" })
vim.keymap.set("n", "<Leader>n1", ":tabfirst<CR>", { silent = true, desc = "Tab: Switch to 1" })
vim.keymap.set("n", "<Leader>n2", ":tabfirst<CR>:tabnext<CR>", { silent = true, desc = "Tab: Switch to 2" })
vim.keymap.set("n", "<Leader>n3", ":tabfirst<CR>:tabnext<CR>:tabnext<CR>", { silent = true, desc = "Tab: Switch to 3" })
vim.keymap.set("n", "<Leader>n4", ":tabfirst<CR>:tabnext<CR>:tabnext<CR>:tabnext<CR>", { silent = true, desc = "Tab: Switch to 4" })
vim.keymap.set("n", "<Leader>n5", ":tabfirst<CR>:tabnext<CR>:tabnext<CR>:tabnext<CR>:tabnext<CR>", { silent = true, desc = "Tab: Switch to 5" })
vim.keymap.set("n", "<Leader>n6", ":tabfirst<CR>:tabnext<CR>:tabnext<CR>:tabnext<CR>:tabnext<CR>:tabnext<CR>", { silent = true, desc = "Tab: Switch to 6" })
vim.keymap.set("n", "<Leader>nq", ":tabclose<CR>", { silent = true, desc = "Tab: Close current" })
vim.keymap.set("n", "<Leader>n<Tab>", "g<Tab>", { silent = true, desc = "Tab: Switch to last tab" })
