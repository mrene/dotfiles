-- nvim-tree
-- https://github.com/nvim-tree/nvim-tree.lua
local function on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- Fuzzy find files in tree ('/')
	-- Adapted from https://github.com/gennaro-tedesco/dotfiles/blob/master/nvim/lua/plugins/nvim_tree.lua
	vim.keymap.set("n", "/", function()
		local fzf = require("fzf-lua")
		fzf.fzf_exec("fd -H -t f -E '.git/'", {
			prompt = ":",
			actions = {
				["default"] = {
					fn = function(selected)
						if selected[1]:find("^%.") ~= nil then
							api.tree.toggle_hidden_filter()
						end

						api.tree.find_file(selected[1])
					end,
					desc = "fuzzy find files in tree",
				},
			},
		})
	end, opts("fuzzy find files in tree"))

	-- fzf-lua overrides for running on folder nodes
	local function in_directory(fn)
		local node = api.tree.get_node_under_cursor()
		if node and node.type == "directory" then
			fn(node.absolute_path)
		elseif node and node.type == "file" then
			fn(vim.fn.fnamemodify(node.absolute_path, ":h"))
		else
			vim.notify("Couldn't determine path", vim.log.levels.WARN)
		end
	end
	vim.keymap.set("n", "<leader>fS", function()
		in_directory(function(path)
			require("fzf-lua").live_grep({ cwd = path })
		end)
	end, opts("FZF: Live grep in folder"))
	vim.keymap.set("n", "<leader>ff", function()
		in_directory(function(path)
			require("fzf-lua").files({ cwd = path })
		end)
	end, opts("FZF: Files in folder"))

	-- file / dir history
	vim.keymap.set("n", "<leader>gdf", function()
		in_directory(function(path)
			vim.cmd("DiffviewFileHistory " .. path)
		end)
	end, opts("Git: open file/dir history"))
end

require("nvim-tree").setup({
	actions = {
		open_file = {
			resize_window = false, -- Prevent resizing tree on opening file
			quit_on_open = true, -- Close tree when opening a file
		},
	},
	update_focused_file = {
		enable = true,
	},
	diagnostics = {
		enable = true,
		show_on_dirs = true,
	},
	view = {
		width = 50,
		float = {
			enable = true,
			open_win_config = {
				width = 50,
				height = 60,
			},
		},
	},
	on_attach = on_attach,
})
vim.keymap.set("n", "<Leader>e", ":NvimTreeToggle<CR>zz", { desc = "Tree: Toggle", silent = true })
