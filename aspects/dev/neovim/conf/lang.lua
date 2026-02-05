require("which-key").add({
	{ "<leader>l", group = "LSP" },
})

-- TypeScript
vim.lsp.config["ts_ls"] = {
	cmd = { "typescript-language-server", "--stdio" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
}

-- Markdown
vim.lsp.config["markdown_oxide"] = {
	cmd = { "markdown-oxide" },
	root_markers = { ".moxide.toml", ".obsidian", ".git" },
	filetypes = { "markdown", "markdown.mdx" },
	capabilities = {
		workspace = {
			didChangeWatchedFiles = {
				dynamicRegistration = true,
			},
		},
	},
}

-- Nix
vim.lsp.config["nixd"] = {
	cmd = { "nixd" },
	root_markers = { "flake.nix", "flake.lock", ".git" },
	filetypes = { "nix" },
}

-- Protobuf
vim.lsp.config["buf_ls"] = {
	cmd = { "buf", "lsp", "serve" },
	root_markers = { "buf.work.yaml", "buf.yaml", ".git" },
	filetypes = { "proto" },
}

-- Bash
vim.lsp.config["bashls"] = {
	cmd = { "bash-language-server", "start" },
	root_markers = { ".git" },
	filetypes = { "sh", "bash" },
}

-- Jsonnet
vim.lsp.config["jsonnet_ls"] = {
	cmd = { "jsonnet-language-server" },
	root_markers = { "jsonnetfile.json", ".git" },
	filetypes = { "jsonnet", "libsonnet" },
}

-- Python
vim.lsp.config["pyright"] = {
	cmd = { "pyright-langserver", "--stdio" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
	filetypes = { "python" },
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
			},
		},
	},
}

-- Python linting/formatting
if vim.fn.executable("ruff") == 1 then -- Only load if ruff is available
	vim.lsp.config["ruff"] = {
		cmd = { "ruff", "server", "--preview" },
		root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
		filetypes = { "python" },
		init_options = {
			settings = {
				logLevel = "debug",
			},
		},
	}
end

-- Native LSP config for lua_ls
vim.lsp.config["lua_ls"] = {
	cmd = { "lua-language-server" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
	filetypes = { "lua" },
	-- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if path ~= vim.fn.stdpath("config") and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc")) then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using
				-- (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					-- Depending on the usage, you might want to add additional paths here.
					-- "${3rd}/luv/library"
					-- "${3rd}/busted/library",
				},
				-- or pull in all of 'runtimepath'.
				-- NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189 )
				--library = vim.api.nvim_get_runtime_file("", true),
			},
		})
	end,
	settings = {
		Lua = {},
	},
}

-- Enable all LSP servers
vim.lsp.enable("ts_ls")
vim.lsp.enable("markdown_oxide")
vim.lsp.enable("nixd")
vim.lsp.enable("buf_ls")
vim.lsp.enable("bashls")
vim.lsp.enable("jsonnet_ls")
vim.lsp.enable("pyright")
if vim.fn.executable("ruff") == 1 then
	vim.lsp.enable("ruff")
end
vim.lsp.enable("lua_ls")

-- Bind keymap on LSP attach to buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local fzf = require("fzf-lua")

		local function kopts(buffer, desc)
			return { buffer = buffer, desc = desc }
		end

		local function goto_definition_float()
			AwaitBufferChange(function()
				vim.lsp.buf.definition()
			end)
			PopBufferToFloat()
		end

		local function goto_type_definition_float()
			AwaitBufferChange(function()
				vim.lsp.buf.type_definition()
			end)
			PopBufferToFloat()
		end

		local function goto_definition_right()
			AwaitBufferChange(function()
				vim.lsp.buf.definition()
			end)
			PopBufferToRight()
		end

		local function goto_type_definition_right()
			AwaitBufferChange(function()
				vim.lsp.buf.type_definition()
			end)
			PopBufferToRight()
		end

		require("which-key").add({
			{ "<leader>li", group = "LSP: Info..." },
			{ "<leader>ll", group = "LSP: List..." },
			{ "<leader>lg", group = "LSP: Goto..." },
			{ "<leader>lw", group = "LSP: Workspace..." },
			{ "<leader>lc", group = "LSP: Actions..." },
		})

		-- Go to
		vim.keymap.set("n", "<leader>lgd", vim.lsp.buf.definition, kopts(ev.buf, "LSP: Go to definition"))
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, kopts(ev.buf, "LSP: Go to definition"))
		vim.keymap.set("n", "gfd", goto_definition_float, kopts(ev.buf, "LSP: Go to definition (in floating window)"))
		vim.keymap.set("n", "gld", goto_definition_right, kopts(ev.buf, "LSP: Go to definition (in right split)"))

		vim.keymap.set("n", "<leader>lgt", vim.lsp.buf.type_definition, kopts(ev.buf, "LSP: Go to type definition"))
		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, kopts(ev.buf, "LSP: Go to type definition"))
		vim.keymap.set("n", "gft", goto_type_definition_float, kopts(ev.buf, "LSP: Go to type definition (in floating window)"))
		vim.keymap.set("n", "glt", goto_type_definition_right, kopts(ev.buf, "LSP: Go to type definition (in right split)"))

		-- vim.keymap.set("n", "gr", fzf.lsp_references, kopts(ev.buf, "LSP: Go to references"))

		-- Info (more in treesitter.lua)
		vim.keymap.set("n", "<leader>lii", vim.lsp.buf.hover, kopts(ev.buf, "LSP: Displays hover information about a symbol"))
		vim.keymap.set("n", "<leader>lis", vim.lsp.buf.signature_help, kopts(ev.buf, "LSP: Show signature help"))

		-- List
		vim.keymap.set("n", "<leader>lli", fzf.lsp_implementations, kopts(ev.buf, "LSP: List all implementations"))
		vim.keymap.set("n", "<leader>llr", fzf.lsp_references, kopts(ev.buf, "LSP: List references"))

		-- Workspace
		vim.keymap.set("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, kopts(ev.buf, "LSP: Add workspace folder"))
		vim.keymap.set("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, kopts(ev.buf, "LSP: Remove workspace folder"))
		vim.keymap.set("n", "<leader>lwl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, kopts(ev.buf, "LSP: List workspace folders"))

		-- Actions
		vim.keymap.set({ "n", "v" }, "<leader>lca", vim.lsp.buf.code_action, kopts(ev.buf, "LSP: Code action"))
		vim.keymap.set({ "i", "v" }, "<C-l>ca", vim.lsp.buf.code_action, kopts(ev.buf, "LSP: Code action"))
		vim.keymap.set({ "n", "v" }, "<leader>lr", vim.lsp.buf.rename, kopts(ev.buf, "LSP: Rename"))
		vim.keymap.set({ "i", "v" }, "<C-l>r", vim.lsp.buf.rename, kopts(ev.buf, "LSP: Rename"))
		vim.keymap.set("n", "<leader>lR", ":LspRestart<CR>", kopts(ev.buf, "LSP: Restart"))
	end,
})

-- Enable inlays
vim.lsp.inlay_hint.enable(true)
vim.keymap.set("n", "<Leader>Ti", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "LSP: Toggle inlay hints" })

-- Autocomplete
-- nvim-cmp
-- https://github.com/hrsh7th/nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
	-- luasnip
	-- https://github.com/L3MON4D3/LuaSnip
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	preselect = cmp.PreselectMode.None, -- Don't preselect items

	mapping = cmp.mapping.preset.insert({
		-- Accept selected
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert,
			select = false, -- don't select unless selected
		}),
		["<S-CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = false, -- don't select unless selected
		}),

		-- Documentation pane navigation
		["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
		["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
	}),

	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},

	sources = {
		{ name = "nvim_lsp" },
		{ name = "nvim_lsp_signature_help" },
		{ name = "luasnip" },
		{ name = "buffer" },
	},
})

-- Load default snippets
-- Can be called again to load more from specific paths (see doc or HF backend repo)
require("luasnip.loaders.from_vscode").lazy_load({})

-- Golang
-- https://github.com/ray-x/go.nvim
if vim.fn.executable("go") == 1 then -- Only load the plugin if `go` is available since it fails otherwise
	require("go").setup({
		lsp_keymaps = false, -- conflicts with our remaps
		lsp_cfg = {
			settings = {
				gopls = {
					-- via golangci-lint instead
					staticcheck = false,
					analyses = {
						deprecated = false,
					},

					-- Prevent diags from disappearing when typing
					-- See https://github.com/ray-x/go.nvim/issues/515
					diagnosticsDelay = "1s",
					diagnosticsTrigger = "Edit",
				},
			},
		},
	})
	vim.keymap.set({ "n", "v" }, "<leader>lci", ":GoImports<CR>", { silent = true, desc = "LSP: Fix imports" })
end

-- Rust
-- https://github.com/mrcjkb/rustaceanvim#gear-advanced-configuration
-- https://github.com/mrcjkb/rustaceanvim/blob/master/lua/rustaceanvim/config/internal.lua
-- See :h rustaceanvim
vim.g.rustaceanvim = {
	tools = {},
	server = {
		default_settings = {
			["rust-analyzer"] = {},
		},
	},
	dap = {},
}

-- highlight todo, fixme, etc
require("todo-comments").setup({
	keywords = {
		NOTE = {
			alt = { "REVIEW" },
		},
	},
})

-- markdown rendering
require("render-markdown").setup({
	file_types = { "markdown" },
})
