require("which-key").add({
	{ "<leader>g", group = "Git" },
})

-- Diffview
-- https://github.com/sindrets/diffview.nvim
-- `--imply-local` means it will use the local version of the file on the right side
require("diffview").setup({})

vim.g.main_branch_override = ""
local function git_main_branch()
	if vim.g.main_branch_override ~= "" then
		return vim.g.main_branch_override
	end
	return vim.fn.system("jj-main-branch")
end
vim.api.nvim_command("command! -nargs=1 SetMainBranch let g:main_branch_override = <args>")

local function git_prev_branch()
	-- Returns the previous branch in the PR branch
	-- Could be the main branch if the PR is on top of main
	return vim.fn.system("jj-prev-branch")
end

local function open_diffview_main()
	vim.api.nvim_command("DiffviewClose")
	local main_branch = git_main_branch()
	vim.api.nvim_command("DiffviewOpen " .. main_branch .. "... --imply-local")
	vim.notify("Diffing against " .. main_branch)
end

local function open_diffview_prev()
	vim.api.nvim_command("DiffviewClose")
	local prev_branch = git_prev_branch()
	vim.api.nvim_command("DiffviewOpen " .. prev_branch .. " --imply-local")
	vim.notify("Diffing against " .. prev_branch)
end

local function open_diffview_rev()
	local rev = vim.fn.input("Git rev/commit: ")
	if rev == "" then
		vim.notify("No git rev/commit entered")
		return
	end

	vim.api.nvim_command("DiffviewClose")
	vim.api.nvim_command("DiffviewOpen " .. rev .. " --imply-local")
end

local function open_diffview_working()
	vim.api.nvim_command("DiffviewClose")
	vim.api.nvim_command("DiffviewOpen")
end

local function open_diffview_file_history()
	vim.api.nvim_command("DiffviewClose")
	vim.api.nvim_command("DiffviewFileHistory %")
end

require("which-key").add({
	{ "<leader>gd", group = "Diff view" },
})
vim.keymap.set("n", "<Leader>gdw", open_diffview_working, { desc = "Git: open diff view against working set" })
vim.keymap.set("n", "<Leader>gdm", open_diffview_main, { desc = "Git: open diff view against main branch" })
vim.keymap.set("n", "<Leader>gdp", open_diffview_prev, { desc = "Git: open diff view against previous branch" })
vim.keymap.set("n", "<Leader>gdf", open_diffview_file_history, { desc = "Git: open file history" })
vim.keymap.set("n", "<Leader>gdc", open_diffview_rev, { desc = "Git: open diff view against given rev/commit" })
vim.keymap.set("n", "<Leader>gdq", ":DiffviewClose<CR>", { silent = true, desc = "Git: close diff view" })

-- Git signs
-- https://github.com/lewis6991/gitsigns.nvim
local gitsigns = require("gitsigns")
require("gitsigns").setup({
	current_line_blame = true, -- show blame info on current line as virtual text
	on_attach = function(bufnr)
		local buf_name = vim.api.nvim_buf_get_name(bufnr)
		if buf_name:match("^diffview://") then
			return false
		end

		return true
	end,
})
require("which-key").add({
	{ "<leader>gg", group = "Gutter signs" },
})
vim.keymap.set({ "n", "v" }, "<Leader>gu", ":Gitsigns reset_hunk<CR>", { silent = true, desc = "Git: revert hunk" })
vim.keymap.set({ "n", "v" }, "<Leader>ga", ":Gitsigns stage_hunk<CR>", { silent = true, desc = "Git: stage hunk" })
vim.keymap.set("n", "]g", ":Gitsigns nav_hunk next<CR>", { silent = true, desc = "Git: next hunk" })
vim.keymap.set("n", "[g", ":Gitsigns nav_hunk prev<CR>", { silent = true, desc = "Git: previous hunk" })
vim.keymap.set("n", "<Leader>gb", ":Gitsigns blame<CR>", { silent = true, desc = "Git: blame pane" })
vim.keymap.set("n", "<Leader>gdb", function()
	gitsigns.diffthis(nil, { vertical = true })
end, { silent = true, desc = "Git: open buffer diff" })

local function switch_gutter_base_main()
	local main_branch = git_main_branch()
	vim.api.nvim_command("Gitsigns change_base " .. main_branch .. " true")
	vim.notify("Switching git gutter against " .. main_branch)
end
local function switch_gutter_base_prev()
	local prev_branch = git_prev_branch()
	vim.api.nvim_command("Gitsigns change_base " .. prev_branch .. " true")
	vim.notify("Switching git gutter against " .. prev_branch)
end
local function switch_gutter_base_default()
	vim.api.nvim_command("Gitsigns reset_base true")
	vim.notify("Switching git gutter to default")
end

vim.keymap.set("n", "<Leader>ggm", switch_gutter_base_main, { silent = true, desc = "Git: switch gutter base gainst main branch" })
vim.keymap.set("n", "<Leader>ggp", switch_gutter_base_prev, { silent = true, desc = "Git: switch gutter base against previous branch" })
vim.keymap.set("n", "<Leader>ggw", switch_gutter_base_default, { silent = true, desc = "Git: switch gutter base to working set" })

-- Octo.nvim
-- https://github.com/pwntester/octo.nvim
require("octo").setup({
	use_local_fs = true, -- Use local filesystem for right side, allowing LSP to work and stop error'ing
	picker = "fzf-lua",
})
require("which-key").add({
	{ "<leader>gp", group = "PR review" },
})
vim.keymap.set("n", "<Leader>gpl", ":Octo pr list<CR>", { silent = true, desc = "Git: PR list" })
vim.keymap.set("n", "<Leader>gpo", ":Octo review open<CR>", { silent = true, desc = "Git: PR review open" })
vim.keymap.set("n", "<Leader>gpq", ":Octo review close<CR>", { silent = true, desc = "Git: PR review close" })
vim.keymap.set("n", "<Leader>gpc", ":Octo review comments<CR>", { silent = true, desc = "Git: PR review comments" })
vim.keymap.set("n", "<Leader>gps", ":Octo review submit<CR>", { silent = true, desc = "Git: PR review submit" })

-- Gitlinker
-- Generates shareable links
-- https://github.com/ruifm/gitlinker.nvim
require("gitlinker").setup({
	mappings = "<leader>gy",
})

-- General keymap
vim.keymap.set("n", "<Leader>gs", ":Git<CR>", { silent = true, desc = "Git: status" })

local function git_main_branch_ask()
	local branch = vim.fn.input("Main branch: ")
	if branch ~= "" then
		vim.g.main_branch_override = branch
		vim.notify("Main branch set to " .. branch)
	else
		vim.g.main_branch_override = ""
		vim.notify("Defaulting to default main branch")
	end

	switch_gutter_base_main()
end
vim.keymap.set("n", "<Leader>gm", git_main_branch_ask, { silent = true, desc = "Git: change main branch" })
