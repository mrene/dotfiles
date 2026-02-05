require("which-key").add({
	{ "<leader>p", group = "Project" },
})

local fzf = require("fzf-lua")

local function get_proj_dir()
	local cwd = vim.fn.getcwd()
	local proj_dir = cwd .. "/proj"
	if vim.fn.isdirectory(proj_dir) == 1 then
		return proj_dir
	end
	return nil
end

local function open_project_file()
	local cwd = vim.fn.getcwd()
	local target_file = vim.fn.glob(cwd .. "/proj/00-*.md", false, true)[1]
	if target_file and target_file ~= "" then
		vim.cmd("edit " .. target_file)
	else
		vim.notify("No file matching proj/00-*.md found in project root", vim.log.levels.WARN)
	end
end

local function find_project_files()
	local proj_dir = get_proj_dir()
	if not proj_dir then
		vim.notify("No proj/ directory found in project root", vim.log.levels.WARN)
		return
	end
	fzf.files({ cwd = proj_dir })
end

local function grep_project_files()
	local proj_dir = get_proj_dir()
	if not proj_dir then
		vim.notify("No proj/ directory found in project root", vim.log.levels.WARN)
		return
	end
	fzf.live_grep({ cwd = proj_dir })
end

vim.keymap.set("n", "<Leader>po", open_project_file, { silent = true, desc = "Project: open main doc (00-*.md)" })
vim.keymap.set("n", "<Leader>pf", find_project_files, { silent = true, desc = "Project: find files in proj/" })
vim.keymap.set("n", "<Leader>fp", find_project_files, { silent = true, desc = "Project: find files in proj/" })
vim.keymap.set("n", "<Leader>ps", grep_project_files, { silent = true, desc = "Project: search in proj/" })
