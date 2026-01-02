require("which-key").add({
	{ "<leader>S", group = "Swap" },
})

---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
	ensure_installed = {}, -- change in neovim/default.nix
	sync_install = false,
	auto_install = false,

	highlight = {
		-- `false` will disable the whole extension
		enable = true,

		-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
		-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
		-- the name of the parser)
		-- list of language that will be disabled
		disable = {},

		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},

	-- See https://github.com/nvim-treesitter/nvim-treesitter-textobjects
	textobjects = {
		select = {
			enable = true,

			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,

			keymaps = {
				["ap"] = { query = "@parameter.outer", desc = "Select outer part of a parameter" },
				["ip"] = { query = "@parameter.inner", desc = "Select inner part of a parameter" },
				["af"] = { query = "@function.outer", desc = "Select outer part of a function" },
				["if"] = { query = "@function.inner", desc = "Select inner part of a function" },
				["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
				["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
				["ab"] = { query = "@block.outer", desc = "Select outer part of a block" },
				["ib"] = { query = "@block.inner", desc = "Select inner part of a block" },
			},

			-- You can choose the select mode (default is charwise 'v')
			--
			-- Can also be a function which gets passed a table with the keys
			-- * query_string: eg '@function.inner'
			-- * method: eg 'v' or 'o'
			-- and should return the mode ('v', 'V', or '<c-v>') or a table
			-- mapping query_strings to modes.
			-- v = charwise, V = linewise, <c-v> = blockwise
			selection_modes = {
				["@parameter.outer"] = "v", -- charwise
			},

			-- If you set this to `true` (default is `false`) then any textobject is
			-- extended to include preceding or succeeding whitespace. Succeeding
			-- whitespace has priority in order to act similarly to eg the built-in
			-- `ap`.
			--
			-- Can also be a function which gets passed a table with the keys
			-- * query_string: eg '@function.inner'
			-- * selection_mode: eg 'v'
			-- and should return true of false
			include_surrounding_whitespace = true,
		},

		swap = {
			enable = true,
			swap_next = {
				["<leader>Sp"] = { query = "@parameter.inner", desc = "Swap with next parameter" },
				["<leader>Sf"] = { query = "@function.outer", desc = "Swap with next function" },
			},
			swap_previous = {
				["<leader>SP"] = { query = "@parameter.inner", desc = "Swap with previous parameter" },
				["<leader>SF"] = { query = "@function.outer", desc = "Swap with previous function" },
			},
		},

		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]f"] = { query = "@function.outer", desc = "Next function start" },
				["]c"] = { query = "@class.outer", desc = "Next class start" },
			},
			goto_next_end = {
				["]F"] = { query = "@function.outer", desc = "Next function end" },
				["]C"] = { query = "@class.outer", desc = "Next class end" },
			},
			goto_previous_start = {
				["[f"] = { query = "@function.outer", desc = "Previous function start" },
				["[c"] = { query = "@class.outer", desc = "Previous class start" },
			},
			goto_previous_end = {
				["[F"] = { query = "@function.outer", desc = "Previous function end" },
				["[C"] = { query = "@class.outer", desc = "Previous class end" },
			},

			-- Below will go to either the start or the end, whichever is closer.
			-- Use if you want more granular movements
			-- Make it even more gradual by adding multiple queries and regex.
			goto_next = {
				["]d"] = "@conditional.outer",
			},
			goto_previous = {
				["[d"] = "@conditional.outer",
			},
		},

		lsp_interop = {
			enable = true,
			border = "none",
			floating_preview_opts = {},
			peek_definition_code = {
				["<leader>lif"] = { query = "@function.outer", desc = "LSP: Peek function definition" },
				["<leader>lic"] = { query = "@class.outer", desc = "LSP: Peek class definition" },
			},
		},
	},
})

-- Treesitter folding
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldenable = false
