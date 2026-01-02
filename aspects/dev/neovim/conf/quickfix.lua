require("which-key").add({
	{ "<leader>k", group = "Quickfix" },
})

-- Quickfix
local function toggle_quickfix()
	local quickfix_open = false
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			quickfix_open = true
			break
		end
	end

	if quickfix_open then
		vim.cmd("cclose")
	else
		vim.cmd("copen")
	end
end

-- Close quicklist before quitting since we auto-save session
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		vim.cmd("cclose")
	end,
})

vim.keymap.set("n", "<leader>ko", "<cmd>copen<cr>", { desc = "Quickfix: Open" })
vim.keymap.set("n", "<leader>kq", "<cmd>cclose<cr>", { desc = "Quickfix: Close" })
vim.keymap.set("n", "<leader>kk", toggle_quickfix, { desc = "Quickfix: Toggle" })
vim.keymap.set("n", "<leader>kn", "<cmd>cnext<cr>", { desc = "Quickfix: Next" })
vim.keymap.set("n", "[k", "<cmd>cprev<cr>", { desc = "Quickfix: Prev" })
vim.keymap.set("n", "]k", "<cmd>cnext<cr>", { desc = "Quickfix: Next" })
vim.keymap.set("n", "<leader>kp", "<cmd>cprev<cr>", { desc = "Quickfix: Previous" })
vim.keymap.set("n", "<leader>kc", "<cmd>cc<cr>", { desc = "Quickfix: Clear" })
