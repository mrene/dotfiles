-- navic symbol breadcrumbs
-- https://github.com/SmiteshP/nvim-navic
local navic = require("nvim-navic")
navic.setup({
	lsp = {
		auto_attach = true,
		-- preference = { "ts_ls", "nil_ls", "jsonnet_ls", "bufls", "marksman", "jsonls", "clangd", "gopls", "rust_analyzer", "pyright", "copilot" },
	},
})
local function navic_get_location()
	if navic.is_available() == true then
		return navic.get_location()
	end

	return ""
end

-- lualine
-- https://github.com/nvim-lualine/lualine.nvim
require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = { "NvimTree", "trouble", "DiffviewFiles" },
			winbar = { "NvimTree", "trouble", "DiffviewFiles" },
		},
		ignore_focus = {},
		always_divide_middle = true,
		always_divide_tabline = true,
		globalstatus = false,
		refresh = {
			statusline = 100,
			tabline = 100,
			winbar = 100,
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = {
			{
				"filename",
				path = 1, -- Show relative path
			},
			{
				navic_get_location,
				cond = navic.is_available,
			},
		},
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = {
			"location",
			{
				"lsp_status",
				-- icon = "", -- f013
				-- symbols = {
				-- 	-- Standard unicode symbols to cycle through for LSP progress:
				-- 	spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
				-- 	-- Standard unicode symbol for when LSP is done:
				-- 	done = "✓",
				-- 	-- Delimiter inserted between LSP names:
				-- 	separator = " ",
				-- },
				-- -- List of LSP names to ignore (e.g., `null-ls`):
				ignore_lsp = { "copilot" },
			},
		},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {
			{
				"filename",
				path = 1, -- Show relative path
			},
		},
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
})
