local pkms_dir = vim.fn.expand("~/pkms")
local pkms_float_win = nil
local fzf = require("fzf-lua")

require("which-key").add({
	{ "<leader>m", group = "PKMS" },
	{ "<leader>mj", group = "Journal" },
})

local function is_pkms_buffer(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(bufnr)
	return path:find(pkms_dir, 1, true) ~= nil
end

-- Opens PKMS float if not already in PKMS. Optionally waits for LSP.
local function ensure_pkms_context(wait_for_lsp)
	if is_pkms_buffer() then
		return
	end

	if pkms_float_win and vim.api.nvim_win_is_valid(pkms_float_win) then
		vim.api.nvim_set_current_win(pkms_float_win)
	else
		local _, win = FloatingWindow()
		pkms_float_win = win
		vim.cmd("edit " .. pkms_dir .. "/index.md")
	end

	if wait_for_lsp then
		vim.wait(2000, function()
			return #vim.lsp.get_clients({ bufnr = 0, name = "markdown_oxide" }) > 0
		end, 50)
	end
end

-- fzf action that opens file in PKMS float
local function pkms_fzf_open(selected, opts)
	if pkms_float_win and vim.api.nvim_win_is_valid(pkms_float_win) then
		vim.api.nvim_set_current_win(pkms_float_win)
	end
	require("fzf-lua.actions").file_edit(selected, opts)
end

-- Markdown oxide LSP configuration (code lens + :Daily command)
-- https://oxide.md/Setup+Instructions
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("MarkdownOxideConfig", {}),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client or client.name ~= "markdown_oxide" then
			return
		end

		-- Code lens refresh on buffer events
		if client.server_capabilities and client.server_capabilities.codeLensProvider then
			vim.lsp.codelens.refresh({ bufnr = ev.buf })
			vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "CursorHold", "BufEnter" }, {
				buffer = ev.buf,
				callback = function()
					vim.lsp.codelens.refresh({ bufnr = ev.buf })
				end,
			})
		end

		-- :Daily command for jumping to daily notes
		vim.api.nvim_create_user_command("Daily", function(args)
			client:request("workspace/executeCommand", { command = "jump", arguments = { args.args } }, nil, ev.buf)
		end, { desc = "Open daily note", nargs = "*" })
	end,
})

-- Journal keymaps
vim.keymap.set("n", "<leader>mjd", function()
	ensure_pkms_context(true)
	vim.cmd("Daily today")
end, { silent = true, desc = "PKMS: Today's note" })

vim.keymap.set("n", "<leader>mjy", function()
	ensure_pkms_context(true)
	vim.cmd("Daily yesterday")
end, { silent = true, desc = "PKMS: Yesterday's note" })

vim.keymap.set("n", "<leader>mjt", function()
	ensure_pkms_context(true)
	vim.cmd("Daily tomorrow")
end, { silent = true, desc = "PKMS: Tomorrow's note" })

-- Daily note with toggle behavior
vim.keymap.set("n", "<leader>md", function()
	if pkms_float_win and vim.api.nvim_win_is_valid(pkms_float_win) then
		vim.api.nvim_win_close(pkms_float_win, true)
		pkms_float_win = nil
		return
	end

	ensure_pkms_context(true)
	vim.cmd("Daily today")
end, { desc = "PKMS: Toggle daily note" })

-- File search (no LSP needed)
vim.keymap.set("n", "<leader>mf", function()
	ensure_pkms_context(false)
	fzf.files({
		cwd = pkms_dir,
		actions = { ["default"] = pkms_fzf_open },
	})
end, { desc = "PKMS: Find files" })

-- Content search (no LSP needed)
vim.keymap.set("n", "<leader>ms", function()
	ensure_pkms_context(false)
	fzf.live_grep({
		cwd = pkms_dir,
		actions = { ["default"] = pkms_fzf_open },
	})
end, { desc = "PKMS: Search content" })

-- Workspace symbols (needs LSP)
vim.keymap.set("n", "<leader>mS", function()
	ensure_pkms_context(true)
	fzf.lsp_live_workspace_symbols({
		winopts = { title = " PKMS Symbols " },
		actions = { ["default"] = pkms_fzf_open },
	})
end, { desc = "PKMS: Workspace symbols" })
