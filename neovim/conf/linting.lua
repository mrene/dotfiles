-- Linting
-- https://github.com/mfussenegger/nvim-lint
-- Most linters are hooked via the respective LSP.
local lint = require("lint")
lint.linters_by_ft = {
	markdown = { "markdownlint" },
	-- go = { "golangcilint" }, -- via go.nvim
}

local auto_linting = true
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	callback = function()
		if auto_linting then
			if vim.bo.readonly then
				return
			end

			-- Skip linting for non-disk-file buffers (virtual buffers, terminals, etc.)
			local bufname = vim.api.nvim_buf_get_name(0)
			if bufname == "" or bufname:match("^%w+://") or vim.fn.filereadable(bufname) == 0 then
				return
			end

			lint.try_lint()
		end
	end,
})

vim.keymap.set("n", "<leader>lt", function()
	lint.try_lint()
end, { desc = "Lint: Run" })

vim.keymap.set("n", "<leader>lT", function()
	local filetype = vim.bo.filetype
	local filename = vim.api.nvim_buf_get_name(0)
	if filename == "" or vim.fn.filereadable(filename) == 0 then
		return
	end

	-- Save the file before fixing
	if not vim.bo.readonly and vim.bo.modifiable and vim.bo.modified then
		vim.cmd("write")
	end

	if filetype == "markdown" then
		vim.fn.system("markdownlint --fix " .. vim.fn.shellescape(filename))
		vim.cmd("edit!") -- Reload the file to show the changes
	else
		vim.notify("Unsupported file type", vim.log.levels.WARN)
	end
end, { desc = "Lint: Fix" })

vim.keymap.set("n", "<leader>Tl", function()
	auto_linting = not auto_linting
	if auto_linting then
		vim.notify("Automatic linting enabled", vim.log.levels.INFO)
	else
		vim.notify("Automatic linting disabled", vim.log.levels.WARN)
	end
end, { desc = "Lint: Toggle" })

-- Override markdownlint args to disable line length check
-- https://github.com/mfussenegger/nvim-lint/blob/2b0039b8be9583704591a13129c600891ac2c596/lua/lint/linters/markdownlint.lua#L6
local markdownlint = lint.linters["markdownlint"]
markdownlint.args = {
	"--stdin",
	"--disable",
	"MD013", -- Disable line length check
	"MD012", -- Disable multiple consecutive blank lines
}
