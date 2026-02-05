require("which-key").add({
	{ "<leader>S", group = "Swap" },
})

-- Treesitter highlighting
-- See: https://neovim.io/doc/user/treesitter.html#vim.treesitter.start()
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

-- Treesitter textobjects
-- See: https://github.com/nvim-treesitter/nvim-treesitter-textobjects/blob/main/README.md
require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
		selection_modes = {
			["@parameter.outer"] = "v",
		},
		include_surrounding_whitespace = true,
	},
	move = {
		set_jumps = true,
	},
})

-- Select keymaps
-- See: https://github.com/nvim-treesitter/nvim-treesitter-textobjects/blob/main/README.md#text-objects-select
local select = require("nvim-treesitter-textobjects.select")
vim.keymap.set({ "x", "o" }, "ap", function()
	select.select_textobject("@parameter.outer", "textobjects")
end, { desc = "Select outer part of a parameter" })
vim.keymap.set({ "x", "o" }, "ip", function()
	select.select_textobject("@parameter.inner", "textobjects")
end, { desc = "Select inner part of a parameter" })
vim.keymap.set({ "x", "o" }, "af", function()
	select.select_textobject("@function.outer", "textobjects")
end, { desc = "Select outer part of a function" })
vim.keymap.set({ "x", "o" }, "if", function()
	select.select_textobject("@function.inner", "textobjects")
end, { desc = "Select inner part of a function" })
vim.keymap.set({ "x", "o" }, "ac", function()
	select.select_textobject("@class.outer", "textobjects")
end, { desc = "Select outer part of a class" })
vim.keymap.set({ "x", "o" }, "ic", function()
	select.select_textobject("@class.inner", "textobjects")
end, { desc = "Select inner part of a class" })
vim.keymap.set({ "x", "o" }, "ab", function()
	select.select_textobject("@block.outer", "textobjects")
end, { desc = "Select outer part of a block" })
vim.keymap.set({ "x", "o" }, "ib", function()
	select.select_textobject("@block.inner", "textobjects")
end, { desc = "Select inner part of a block" })

-- Swap keymaps
-- See: https://github.com/nvim-treesitter/nvim-treesitter-textobjects/blob/main/README.md#text-objects-swap
local swap = require("nvim-treesitter-textobjects.swap")
vim.keymap.set("n", "<leader>Sp", function()
	swap.swap_next("@parameter.inner")
end, { desc = "Swap with next parameter" })
vim.keymap.set("n", "<leader>Sf", function()
	swap.swap_next("@function.outer")
end, { desc = "Swap with next function" })
vim.keymap.set("n", "<leader>SP", function()
	swap.swap_previous("@parameter.inner")
end, { desc = "Swap with previous parameter" })
vim.keymap.set("n", "<leader>SF", function()
	swap.swap_previous("@function.outer")
end, { desc = "Swap with previous function" })

-- Move keymaps
-- See: https://github.com/nvim-treesitter/nvim-treesitter-textobjects/blob/main/README.md#text-objects-move
local move = require("nvim-treesitter-textobjects.move")
vim.keymap.set({ "n", "x", "o" }, "]f", function()
	move.goto_next_start("@function.outer", "textobjects")
end, { desc = "Next function start" })
vim.keymap.set({ "n", "x", "o" }, "]c", function()
	move.goto_next_start("@class.outer", "textobjects")
end, { desc = "Next class start" })
vim.keymap.set({ "n", "x", "o" }, "]F", function()
	move.goto_next_end("@function.outer", "textobjects")
end, { desc = "Next function end" })
vim.keymap.set({ "n", "x", "o" }, "]C", function()
	move.goto_next_end("@class.outer", "textobjects")
end, { desc = "Next class end" })
vim.keymap.set({ "n", "x", "o" }, "[f", function()
	move.goto_previous_start("@function.outer", "textobjects")
end, { desc = "Previous function start" })
vim.keymap.set({ "n", "x", "o" }, "[c", function()
	move.goto_previous_start("@class.outer", "textobjects")
end, { desc = "Previous class start" })
vim.keymap.set({ "n", "x", "o" }, "[F", function()
	move.goto_previous_end("@function.outer", "textobjects")
end, { desc = "Previous function end" })
vim.keymap.set({ "n", "x", "o" }, "[C", function()
	move.goto_previous_end("@class.outer", "textobjects")
end, { desc = "Previous class end" })
vim.keymap.set({ "n", "x", "o" }, "]d", function()
	move.goto_next("@conditional.outer", "textobjects")
end, { desc = "Next conditional" })
vim.keymap.set({ "n", "x", "o" }, "[d", function()
	move.goto_previous("@conditional.outer", "textobjects")
end, { desc = "Previous conditional" })

-- Treesitter folding
-- See: https://neovim.io/doc/user/treesitter.html#vim.treesitter.foldexpr()
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldenable = false
