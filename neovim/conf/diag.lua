require("which-key").add({
	{ "<leader>x", group = "Diagnostics" },
})

-- Per-project diagnostic exclusions
local function is_file_excluded(filepath)
	local default_exclusions = {
		"/node_modules/",
		"/vendor/",
		"/.git/",
		"/target/",
		"/build/",
	}
	for _, pattern in ipairs(default_exclusions) do
		if filepath:match(pattern) then
			return true
		end
	end

	-- Check project-specific exclusions from vim.g.diagnostic_excluded_dirs
	-- Set via `vim.g.diagnostic_excluded_dirs = { ... }` in `.nvim.lua`
	if vim.g.diagnostic_excluded_dirs then
		for _, pattern in ipairs(vim.g.diagnostic_excluded_dirs) do
			if filepath:match(pattern) then
				return true
			end
		end
	end

	return false
end

-- Trouble (diagnostics)
-- https://github.com/folke/trouble.nvim
local Trouble = require("trouble")
Trouble.setup({
	modes = {
		cwd_diagnostics = {
			mode = "diagnostics",
			filter = {
				function(item)
					-- Only show diagnostics in the current working directory
					local cwd = vim.fn.getcwd()
					if item.filename:sub(1, #cwd) ~= cwd then
						return false
					end

					-- If file is excluded, only show if it's the currently active buffer
					if is_file_excluded(item.filename) then
						local current_file = vim.api.nvim_buf_get_name(0)
						return item.filename == current_file
					end

					return true
				end,
			},
		},
	},
})

local diag_mode = "cwd_diagnostics"

local function trouble_diag_open()
	Trouble.open(diag_mode)
end

local function trouble_diag_focus()
	if Trouble.is_open(diag_mode) then
		Trouble.focus()
	else
		Trouble.open(diag_mode)
	end
end

local function trouble_diag_close()
	Trouble.close(diag_mode)
end

local function trouble_diag_toggle()
	Trouble.toggle(diag_mode)
end

local function trouble_diag_next()
	if not Trouble.is_open(diag_mode) then
		Trouble.open(diag_mode)
	end

	Trouble.focus()
	Trouble.next()
end

local function trouble_diag_prev()
	if not Trouble.is_open(diag_mode) then
		Trouble.open(diag_mode)
	end

	Trouble.focus()
	Trouble.prev()
end

local function diag_next_infile()
	vim.diagnostic.jump({ count = 1 })
end

local function diag_prev_infile()
	vim.diagnostic.jump({ count = -1 })
end

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<leader>xs", vim.diagnostic.open_float, { desc = "Diag: Open diagnostic float" })
vim.keymap.set("n", "<leader>xf", vim.diagnostic.open_float, { desc = "Diag: Open diagnostic float" })
vim.keymap.set("n", "<leader>xr", trouble_diag_close, { desc = "Diag: Reset diagnostics" })
vim.keymap.set("n", "]x", diag_next_infile, { desc = "Diag: Go to next diagnostic (in file)" })
vim.keymap.set("n", "[x", diag_prev_infile, { desc = "Diag: Go to previous diagnostic (in file)" })
vim.keymap.set("n", "]X", trouble_diag_next, { desc = "Diag: Go to next diagnostic (global)" })
vim.keymap.set("n", "[X", trouble_diag_prev, { desc = "Diag: Go to previous diagnostic (global)" })
vim.keymap.set("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diag: Set location list" })
vim.keymap.set("n", "<leader>xo", trouble_diag_open, { desc = "Diag: Open trouble" })
vim.keymap.set("n", "<leader>xf", trouble_diag_focus, { desc = "Diag: Focus trouble" })
vim.keymap.set("n", "<leader>xx", trouble_diag_toggle, { desc = "Diag: Toggle trouble" })
vim.keymap.set("n", "<leader>xq", trouble_diag_close, { desc = "Diag: Close trouble" })
