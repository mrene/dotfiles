-- fzf-lua
-- From https://github.com/jkearse3/dotfiles/blob/e3e53bb0c11daeb33dc5b44609ff46da9dd05b1c/nvim/lua/lazy_plugins/search.lua#L2
local fzf = require("fzf-lua")
local actions = require("fzf-lua.actions")
fzf.setup({
	winopts = {
		preview = {
			default = "bat", -- faster than builtin that triggers LSPs
			layout = "vertical",
			vertical = "down:60%",
		},
	},
	keymap = {
		fzf = {
			["ctrl-k"] = "select-all+accept",
			["ctrl-d"] = "half-page-down",
			["ctrl-u"] = "half-page-up",
		},
	},
	oldfiles = {
		cwd_only = true,
		include_current_session = true,
	},

	actions = {
		buffers = {
			-- Force delete buffer
			["ctrl-d"] = {
				fn = function(selected, opts)
					local bufnr = tonumber(selected[1]:match("%[(%d+)%]"))
					if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
						vim.api.nvim_buf_delete(bufnr, { force = true })
					end
					return true
				end,
				desc = "Force delete buffer",
				reload = true,
			},

			-- Have to add them since they get otherwise
			["default"] = actions.buf_edit,
			["ctrl-x"] = { fn = actions.buf_del, reload = true },
		},
	},
})

require("which-key").add({
	{ "<leader>f", group = "FZF Search" },
})

local function lsp_document_symbols()
	fzf.lsp_document_symbols({
		-- Hide filepath and line:col, show symbol fields (last 2 tab-delimited fields)
		fzf_opts = { ["--delimiter"] = "\\t", ["--with-nth"] = "-2.." },
	})
end

-- Quick keybindings
vim.keymap.set("n", "<C-p>", fzf.files, { desc = "FZF: Files" })
vim.keymap.set("n", "<C-l>", fzf.lgrep_curbuf, { desc = "FZF: Live grep file" })
vim.keymap.set("n", "<C-g>", fzf.live_grep, { desc = "FZF: Live grep workspace" })
vim.keymap.set("n", "<C-b>", fzf.buffers, { desc = "FZF: Buffers" })
vim.keymap.set("n", "<C-s>", lsp_document_symbols, { desc = "FZF: LSP document symbols" })
vim.keymap.set("n", "<C-n>", fzf.tabs, { desc = "FZF: Tabs" })
vim.keymap.set("n", "<C-h>", fzf.oldfiles, { desc = "FZF: Old files" })

-- Long form keybindings
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "FZF: Files" }) -- Can be used on nvim-tree folder node (see tree.lua)
vim.keymap.set("n", "<leader>fo", fzf.oldfiles, { desc = "FZF: Old files" })
vim.keymap.set("n", "<leader>fs", fzf.lgrep_curbuf, { desc = "FZF: Live grep file" })
vim.keymap.set("n", "<leader>fS", fzf.live_grep, { desc = "FZF: Live grep workspace" }) -- Can be used on nvim-tree folder node (see tree.lua)
vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "FZF: Grep word" })
vim.keymap.set("n", "<leader>fW", fzf.grep_cWORD, { desc = "FZF: Grep WORD" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "FZF: Buffers" })
vim.keymap.set("n", "<leader>fn", fzf.tabs, { desc = "FZF: Tabs" })
vim.keymap.set("n", "<leader>fm", fzf.marks, { desc = "FZF: Marks" })
vim.keymap.set("n", "<leader>fR", fzf.registers, { desc = "FZF: Registers" })
vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "FZF: Resume last search" })
vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "FZF: Help tags" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "FZF: Keymaps" })
vim.keymap.set("n", "<leader>fc", fzf.commands, { desc = "FZF: Commands" })

vim.keymap.set("n", "<leader>fx", fzf.quickfix, { desc = "FZF: Quickfix list" })
vim.keymap.set("n", "<leader>fxl", fzf.quickfix, { desc = "FZF: Quickfix list" })
vim.keymap.set("n", "<leader>fxs", fzf.quickfix_stack, { desc = "FZF: Quickfix stack" })

vim.keymap.set("n", "<leader>fls", lsp_document_symbols, { desc = "FZF: LSP document symbols" })
vim.keymap.set("n", "<leader>flS", fzf.lsp_live_workspace_symbols, { desc = "FZF: LSP workspace symbols" })
vim.keymap.set("n", "<leader>flr", fzf.lsp_references, { desc = "FZF: LSP references" })
vim.keymap.set("n", "<leader>flc", fzf.lsp_incoming_calls, { desc = "FZF: LSP incoming calls" })
vim.keymap.set("n", "<leader>flC", fzf.lsp_outgoing_calls, { desc = "FZF: LSP outgoing calls" })
vim.keymap.set("n", "<leader>fld", fzf.lsp_definitions, { desc = "FZF: LSP definitions" })
vim.keymap.set("n", "<leader>flD", fzf.lsp_declarations, { desc = "FZF: LSP declarations" })
vim.keymap.set("n", "<leader>flt", fzf.lsp_typedefs, { desc = "FZF: LSP type definitions" })
vim.keymap.set("n", "<leader>fli", fzf.lsp_implementations, { desc = "FZF: LSP type implementations" })
vim.keymap.set("n", "<leader>flm", fzf.lsp_document_diagnostics, { desc = "FZF: LSP document diagnostics" })
vim.keymap.set("n", "<leader>flM", fzf.lsp_workspace_diagnostics, { desc = "FZF: LSP workspace diagnostics" })

vim.keymap.set("n", "<leader>fdb", fzf.dap_breakpoints, { desc = "FZF: DAP breakpoints" })

vim.keymap.set({ "n", "v", "i" }, "<C-x><C-f>", function()
	require("fzf-lua").complete_path()
end, { silent = true, desc = "FZF: Fuzzy complete path" })

-- Git related
-- local function files_from_trunk()
-- 	local fzf_lua = require("fzf-lua")
-- 	fzf_lua.fzf_exec("jj diff -r 'trunk()..@' --name-only", {
-- 		prompt = "Branch files> ",
-- 		actions = require("fzf-lua.actions").filjj diff --summary -r 'trunk()..@'e_edit,
-- 		previewer = "builtin",
-- 	})
-- end
vim.keymap.set("n", "<leader>fgs", fzf.git_status, { desc = "FZF: Git status" })
vim.keymap.set("n", "<leader>fgS", fzf.git_stash, { desc = "FZF: Git stash" })
vim.keymap.set("n", "<leader>fgf", fzf.git_files, { desc = "FZF: Git files" })
vim.keymap.set("n", "<leader>fgb", fzf.git_branches, { desc = "FZF: Git branches" })
vim.keymap.set("n", "<leader>fgB", fzf.git_blame, { desc = "FZF: Git blame" })
vim.keymap.set("n", "<leader>fgt", fzf.git_tags, { desc = "FZF: Git tags" })
