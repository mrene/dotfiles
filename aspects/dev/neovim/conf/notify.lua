-- nvim-notify
-- https://github.com/rcarriga/nvim-notify
local notify = require("notify")
notify.setup({})

---@diagnostic disable-next-line: inject-field
vim.notify = notify

vim.keymap.set("n", "<leader>qn", function()
	require("notify").dismiss()
end, { desc = "Dismiss all notifications" })

-- lsp-notify
-- Show LSP related messages and progress
-- https://github.com/brianhuster/nvim-lsp-notify
if not vim.g.minimal_nvim then
	require("lsp-notify").setup({
		excludes = {
			"buf_ls", -- spams on each change
		},
	})
end
