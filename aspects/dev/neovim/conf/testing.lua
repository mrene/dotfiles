require("which-key").add({
	{ "<leader>t", group = "Testing" },
})

-- Neotest
-- https://github.com/nvim-neotest/neotest
local Neotest = require("neotest")
local summary_was_opened = false
Neotest.setup({
	-- log_level = vim.log.levels.DEBUG,

	adapters = {
		require("rustaceanvim.neotest"),

		require("neotest-golang")({
			go_test_args = {
				"-v",
				"-count=1",
				"-timeout=10s",
			},
			warn_test_name_dupes = false,
		}),

		require("neotest-python"),
	},

	output = {
		output_on_run = true,
	},

	quickfix = {
		enabled = false, -- annoying since it opens quickfix at the bottom of the sidebar
		open = false,
	},

	-- Notify on completion
	-- https://github.com/nvim-neotest/neotest/issues/218
	consumers = {
		notify = function(client)
			client.listeners.results = function(_, results, partial)
				-- Partial results can be very frequent
				if partial then
					return
				end

				local fail_count = 0
				local success_count = 0
				for _, result in pairs(results) do
					if result.status == "failed" then
						fail_count = fail_count + 1
					else
						success_count = success_count + 1
					end
				end

				if fail_count > 0 then
					vim.notify(string.format("%d test(s) failed", fail_count), vim.log.levels.ERROR, { title = "Neotest" })
				else
					if not summary_was_opened then
						Neotest.summary.close()
					end
				end
				if success_count > 0 then
					vim.notify(string.format("%d test(s) passed", success_count), vim.log.levels.INFO, { title = "Neotest" })
				end
			end
			return {}
		end,
	},
})

local function is_summary_opened()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype
		if ft == "neotest-summary" then
			return true
		end
	end
	return false
end

local function run_nearest()
	summary_was_opened = is_summary_opened()
	Neotest.summary.open()
	Neotest.run.run()
end

local function debug_nearest()
	Neotest.summary.close() -- it gets in the way
	require("dapui").open()
	Neotest.run.run({ strategy = "dap" })
end

local function run_file()
	summary_was_opened = is_summary_opened()
	Neotest.summary.open()
	Neotest.run.run(vim.fn.expand("%"))
end

local function debug_file()
	Neotest.summary.close() -- it gets in the way
	require("dapui").open()
	Neotest.run.run({ vim.fn.expand("%"), strategy = "dap" })
end

local function run_dir()
	summary_was_opened = is_summary_opened()
	Neotest.summary.open()
	local dir = vim.fn.expand("%:p:h")
	Neotest.run.run(dir)
end

local function debug_dir()
	Neotest.summary.close() -- it gets in the way
	require("dapui").open()
	local dir = vim.fn.expand("%:p:h")
	Neotest.run.run({ dir, strategy = "dap" })
end

local function run_last()
	summary_was_opened = is_summary_opened()
	Neotest.summary.open()
	Neotest.run.run_last()
end

local function debug_last()
	Neotest.summary.close() -- it gets in the way
	require("dapui").open()
	Neotest.run.run_last({ strategy = "dap" })
end

local function open_output()
	Neotest.output.open({ enter = true, last_run = true })
end

local function stop_test()
	Neotest.run.stop()
end

local function toggle_summary()
	Neotest.summary.toggle()
end

local function close()
	Neotest.summary.close()
end

vim.keymap.set("n", "<leader>tc", run_nearest, { desc = "Test: Run nearest / under cursor" })
vim.keymap.set("n", "<leader>tdc", debug_nearest, { desc = "Test: Debug nearest" })
vim.keymap.set("n", "<leader>tf", run_file, { desc = "Test: Run file" })
vim.keymap.set("n", "<leader>tdf", debug_file, { desc = "Test: Debug file" })
vim.keymap.set("n", "<leader>tp", run_dir, { desc = "Test: Run package/dir" })
vim.keymap.set("n", "<leader>tdp", debug_dir, { desc = "Test: Debug package/dir" })
vim.keymap.set("n", "<leader>tl", run_last, { desc = "Test: Run last" })
vim.keymap.set("n", "<leader>tdl", debug_last, { desc = "Test: Debug last" })

vim.keymap.set("n", "<leader>tu", stop_test, { desc = "Test: Stop" })
vim.keymap.set("n", "<leader>ts", toggle_summary, { desc = "Test: Toggle summary / side panel" })

vim.keymap.set("n", "<leader>to", open_output, { desc = "Test: Toggle output" })
vim.keymap.set("n", "<leader>tq", close, { desc = "Test: Close output & side panel" })
