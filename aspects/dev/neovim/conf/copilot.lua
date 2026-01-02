-- copilot-lsp (for NES bellow, not used directly)
-- https://github.com/copilotlsp-nvim/copilot-lsp/
vim.g.copilot_nes_debounce = 2000
require("copilot-lsp").setup({
	nes = {
		move_count_threshold = 2, -- Clear after 2 cursor movements
	},
})

-- copilot
-- https://github.com/zbirenbaum/copilot.lua
require("copilot").setup({
	suggestion = {
		enabled = true,
		auto_trigger = true,
		keymap = {
			accept = false, -- See below
			accept_word = "<M-l>",
			accept_line = "<M-o>",
			next = "<M-j>",
			prev = "<M-k>",
			dismiss = "<C-]>",
		},
	},
	copilot_model = "",

	nes = {
		enabled = false,
		keymap = {
			accept_and_goto = "<M-n>",
			accept = false,
			dismiss = "<Esc>",
		},
	},

	-- Logged to ~/.local/state/nvim/copilot-lua.log
	logger = {
		file_log_level = vim.log.levels.TRACE,
		trace_lsp = "debug",
	},

	filetypes = {
		-- overrides defaults
		markdown = true,
		yaml = true,
	},
})

local function passthrough_keymap(keymap)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keymap, true, false, true), "n", true)
end

-- Add completion on tab (if visible), but real tab via shift-tab
local cpsug = require("copilot.suggestion")
local cpnes = require("copilot.nes.api")
local luasnip = require("luasnip")
vim.keymap.set("i", "<Tab>", function()
	if cpsug.is_visible() then
		-- Copilot Inline suggestion
		cpsug.accept()
	elseif cpnes.nes_apply_pending_nes() then
		-- Copilot Next Edit Suggestion
		cpnes.nes_walk_cursor_end_edit()
	elseif luasnip.expand_or_jumpable() then
		luasnip.expand_or_jump()
	else
		passthrough_keymap("<Tab>")
	end
end, { noremap = true, silent = true })

vim.keymap.set({ "n", "v" }, "<Tab>", function()
	if cpnes.nes_apply_pending_nes() then
		-- Copilot Next Edit Suggestion
		cpnes.nes_walk_cursor_end_edit()
	else
		passthrough_keymap("<Tab>")
	end
end, { noremap = true, silent = true })

vim.keymap.set("i", "<S-Tab>", function()
	passthrough_keymap("<Tab>")
end, { noremap = true, silent = true })

vim.keymap.set("i", "<M-J>", function()
	vim.cmd("Copilot panel")
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>Tp", function()
	if require("copilot.client").is_disabled() then
		require("copilot.command").enable()
		vim.notify("Copilot enabled", vim.log.levels.INFO)
	else
		require("copilot.command").disable()
		vim.notify("Copilot disabled", vim.log.levels.WARN)
	end
end, { desc = "Copilot: Toggle" })
