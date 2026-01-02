-- Auto formatting on save
-- https://github.com/stevearc/conform.nvim
local auto_formatting = true
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		sh = { "shfmt" },
		rust = { "rustfmt", lsp_format = "fallback" },
		go = { "hfgofmt", "gofmt", "goimports" },
	},
	formatters = {
		-- humanfirst one
		hfgofmt = {
			command = "hfgofmt",
		},
	},
	format_on_save = function()
		if not auto_formatting then
			return
		end
		return {
			timeout_ms = 1000,
			lsp_format = "fallback",
		}
	end,
	default_format_opts = {
		-- fallback to lsp
		lsp_format = "fallback",
		async = true,
	},
})

vim.keymap.set({ "n", "v" }, "<leader>lf", function()
	require("conform").format({ async = true })
end, { desc = "Format (conform)" })

vim.keymap.set("n", "<leader>Tf", function()
	auto_formatting = not auto_formatting
	if auto_formatting then
		vim.notify("Automatic formatting enabled", vim.log.levels.INFO)
	else
		vim.notify("Automatic formatting disabled", vim.log.levels.WARN)
	end
end, { desc = "Format: Toggle" })
