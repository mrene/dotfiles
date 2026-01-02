require("which-key").add({
	{ "<leader>a", group = "Agentic" },
})

-- codecompanion
-- https://codecompanion.olimorris.dev/getting-started.html
require("codecompanion").setup({
	strategies = {
		chat = {
			adapter = "copilot",
			model = "gpt-5",
			tools = {
				["mcp"] = {
					callback = require("mcphub.extensions.codecompanion"),
					description = "Call tools and resources from the MCP Servers",
					opts = {
						requires_approval = true,
					},
				},
			},
		},
		inline = {
			adapter = "copilot",
			model = "gpt-4.1",
		},
	},
})
vim.keymap.set(
	"v",
	"gs",
	":'<,'>CodeCompanion Fix any spelling or unclear text in this selected text. Try to keep the original meaning and intent of the text.<CR>",
	{ silent = true, desc = "CodeCompanion: Fix spelling & unclear text" }
)
vim.keymap.set(
	"v",
	"gC",
	":'<,'>CodeCompanion Add documentation to the selected text if it's missing. If it's a whole function, add proper function documentation. If it already exist, improve it. If it's code, add inline comments explaining it. If there are existing documentation, just improve it if needed. @insert_edit_into_file #buffer<CR>",
	{ silent = true, desc = "CodeCompanion: Comment code" }
)
vim.keymap.set({ "n", "v" }, "<leader>aa", ":'<,'>CodeCompanionActions<CR>", { silent = true, desc = "CodeCompanion: Actions" })
vim.keymap.set("v", "<leader>ae", function()
	vim.ui.input({ prompt = "Describe what needs to be done:" }, function(input)
		if input and input ~= "" then
			local system_prompt = "Use @insert_edit_into_file and #buffer for tool use."
			local input_escaped = vim.fn.escape(input, '"')
			local cmd = string.format(":'<,'>CodeCompanion %s %s<CR>", input_escaped, system_prompt)
			vim.cmd(cmd)
		end
	end)
end, { silent = true, desc = "CodeCompanion: Inline edit with prompt" })

-- MCPHub
require("mcphub").setup({})
vim.keymap.set("n", "<Leader>au", ":<CR>:MCPHub<CR>", { silent = true, desc = "Open MCPHub" })

-- ClaudeCode.nvim
-- https://github.com/coder/claudecode.nvim
require("claudecode").setup({})

require("which-key").add({
	{ "<leader>c", group = "Claude" },
})

vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
vim.keymap.set("n", "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
vim.keymap.set("n", "<leader>cr", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
vim.keymap.set("n", "<leader>cC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
vim.keymap.set("n", "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
vim.keymap.set("v", "<leader>cs", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
vim.keymap.set("n", "<leader>cs", "<cmd>ClaudeCodeTreeAdd<cr>", { desc = "Add file" }) -- , ft = { "NvimTree", "neo-tree", "oil" }
vim.keymap.set("n", "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
vim.keymap.set("n", "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })
