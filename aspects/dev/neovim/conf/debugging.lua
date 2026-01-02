require("which-key").add({
	{ "<leader>d", group = "Debugging" },
})

-- nvim-dap
-- https://github.com/mfussenegger/nvim-dap
--
-- To setup, just create a `.vscode/launch.json` file in your project (making sure it's valid JSON
-- without trailing commas)
local dap = require("dap")
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP: Start/Continue" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP: Step over" })
vim.keymap.set("n", "<leader>dI", dap.step_into, { desc = "DAP: Step into" })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "DAP: Step out" })
vim.keymap.set("n", "<leader>dj", dap.down, { desc = "DAP: Down" })
vim.keymap.set("n", "<leader>dk", dap.up, { desc = "DAP: Up" })
vim.keymap.set("n", "<leader>dp", dap.pause, { desc = "DAP: Pause" })
vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate" })
vim.keymap.set("n", "<leader>dr", dap.restart, { desc = "DAP: Restart" })
vim.keymap.set("n", "<leader>de", dap.repl.toggle, { desc = "DAP: Toggle repl" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP: Run last" })
vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "DAP: Run to cursor" })

-- Breakpoint sign
vim.fn.sign_define("DapBreakpoint", { text = "⭕️", texthl = "", linehl = "", numhl = "" })

-- nvim-dap-ui
-- https://github.com/rcarriga/nvim-dap-ui
local dapui = require("dapui")
dapui.setup({
	layouts = {
		{
			position = "bottom",
			size = 15,
			elements = {
				{ id = "repl", size = 0.3 },
				{ id = "console", size = 0.3 },
				{ id = "scopes", size = 0.3 },
			},
		},
		{
			position = "right",
			size = 50,
			elements = {
				{ id = "stacks", size = 0.6 },
				{ id = "watches", size = 0.2 },
				{ id = "breakpoints", size = 0.2 },
			},
		},
	},
	expand_lines = false,
})

local function quit_dap()
	dap.terminate()
	dapui.close()
end

vim.keymap.set("n", "<leader>du", dapui.open, { desc = "DAP: Open DAP UI" })
vim.keymap.set("n", "<leader>dq", quit_dap, { desc = "DAP: Terminate & Quit DAP UI" })

dap.listeners.before.initialized.dapui_config = function()
	dapui.open()
end
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
-- dap.listeners.before.event_terminated.dapui_config = function()
-- 	dapui.close()
-- end
-- dap.listeners.before.event_exited.dapui_config = function()
-- 	dapui.close()
-- end

-- Go
-- https://github.com/leoluz/nvim-dap-go
require("dap-go").setup()

-- Python
-- https://github.com/mfussenegger/nvim-dap-python
-- Add this to the .nvim.lua (get into a poetry shell, then which python)
-- Make sure to install `debugpy` (add as a dev dependency in pyproject.toml)
-- require("dap-python").setup('/home/appaquet/.cache/pypoetry/virtualenvs/exotwo-qXN8T3xg-py3.11/bin/python')
