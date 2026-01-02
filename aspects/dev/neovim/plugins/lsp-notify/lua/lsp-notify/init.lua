--- Forked from https://github.com/mrded/nvim-lsp-notify
--- Modified to add debouncing

--- Options for the plugin.
---@class LspNotifyConfig
local options = {
	--- Function to be used for notifies.
	--- Best works if `vim.notify` is already overwritten by `require('notify').
	--- If no, you can manually pass `= require('notify')` here.
	notify = vim.notify,

	--- Exclude by client name.
	excludes = {},

	--- Icons.
	--- Can be set to `= false` to disable.
	---@type {spinner: string[] | false, done: string | false} | false
	icons = {
		--- Spinner animation frames.
		--- Can be set to `= false` to disable only spinner.
		spinner = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
		--- Icon to show when done.
		--- Can be set to `= false` to disable only spinner.
		done = "✓",
	},

	--- Debounce settings
	debounce = {
		--- Enable debouncing of updates
		enabled = true,
		--- Debounce time in milliseconds
		timeout = 100,
	},
}

--- Whether current notification system supports replacing notifications.
--- Will be `true` if `nvim-notify` handles notifications, `false` if `cmdline`.
local supports_replace = false

--- Check if current notification system supports replacing notifications.
---@return boolean suppors
local function check_supports_replace()
	local n = options.notify("lsp notify: test replace support", vim.log.levels.DEBUG, {
		hide_from_history = true,
		on_open = function(window)
			-- If window is hidden, `nvim-notify` prints errors
			-- This shrinks notifications and puts it in a corner where it will not be seen
			vim.api.nvim_win_set_buf(window, vim.api.nvim_create_buf(false, true))
			vim.api.nvim_win_set_config(window, {
				width = 1,
				height = 1,
				border = "none",
				relative = "editor",
				row = 0,
				col = 0,
			})
		end,
		timeout = 1,
		animate = false,
	})
	local supports = pcall(options.notify, "lsp notify: test replace support", vim.log.levels.DEBUG, { replace = n })
	return supports
end

--#region Task

---@class BaseLspTask
local BaseLspTask = {
	---@type string?
	title = "",
	---@type string?
	message = "",
	---@type number?
	percentage = nil,
}

---@param title string
---@param message string
---@return BaseLspTask
function BaseLspTask.new(title, message)
	local self = vim.deepcopy(BaseLspTask)
	self.title = title
	self.message = message
	return self
end

function BaseLspTask:format()
	return (
		"  "
		.. (string.format("%-8s", self.percentage and self.percentage .. "%" or ""))
		.. (self.title or "")
		.. (self.title and self.message and " - " or "")
		.. (self.message or "")
	)
end

--#endregion

--#region Client

---@class BaseLspClient
local BaseLspClient = {
	name = "",
	---@type {any: BaseLspTask}
	tasks = {},
}

---@param name string
---@return BaseLspClient
function BaseLspClient.new(name)
	local self = vim.deepcopy(BaseLspClient)
	self.name = name
	return self
end

function BaseLspClient:count_tasks()
	local count = 0
	for _ in pairs(self.tasks) do
		count = count + 1
	end
	return count
end

function BaseLspClient:kill_task(task_id)
	self.tasks[task_id] = nil
end

function BaseLspClient:format()
	local tasks = ""
	for _, t in pairs(self.tasks) do
		tasks = tasks .. t:format() .. "\n"
	end

	return (self.name .. "\n" .. (tasks ~= "" and tasks:sub(1, -2) or "  Complete"))
end

--#endregion

--#region Notification

---@class BaseLspNotification
local BaseLspNotification = {
	spinner = 1,
	---@type {integer: BaseLspClient}
	clients = {},
	notification = nil,
	window = nil,

	-- Flag to indicate pending updates
	pending_update = false,
}

---@return BaseLspNotification
function BaseLspNotification:new()
	return vim.deepcopy(BaseLspNotification)
end

function BaseLspNotification:count_clients()
	local count = 0
	for _ in pairs(self.clients) do
		count = count + 1
	end
	return count
end

function BaseLspNotification:notification_start()
	self.notification = options.notify("", vim.log.levels.INFO, {
		title = self:format_title(),
		icon = (options.icons and options.icons.spinner and options.icons.spinner[1]) or nil,
		timeout = false,
		hide_from_history = false,
		on_open = function(window)
			self.window = window
		end,
	})
	if not supports_replace then
		-- `options.notify` will not assign `self.notification` if can't be replaced,
		-- so do it manually here
		self.notification = true
	end
end

function BaseLspNotification:notification_progress()
	local message = self:format()
	local message_lines = select(2, message:gsub("\n", "\n"))

	if supports_replace then
		-- Can reuse same notification
		self.notification = options.notify(message, vim.log.levels.INFO, {
			replace = self.notification,
			hide_from_history = false,
		})
		if self.window then
			-- Update height because `nvim-notify` notifications don't do it automatically
			-- Can cover other notifications
			vim.api.nvim_win_set_height(self.window, 3 + message_lines)
		end
	else
		-- Can't reuse same notification
		-- Print it line-by-line to not trigger "Press ENTER or type command to continue"
		for line in message:gmatch("[^\r\n]+") do
			options.notify(line, vim.log.levels.INFO)
		end
	end
end

function BaseLspNotification:notification_end()
	-- First clear the spinner to stop the animation loop
	self.spinner = nil

	options.notify(self:format(), vim.log.levels.INFO, {
		replace = self.notification,
		icon = options.icons and options.icons.done or nil,
		timeout = 1000,
	})
	if self.window then
		-- Set the height back to the smallest notification size
		vim.api.nvim_win_set_height(self.window, 3)
	end

	-- Clean up and reset
	self.notification = nil

	self.window = nil
end

function BaseLspNotification:update()
	-- If debouncing is disabled, update immediately
	if not options.debounce.enabled then
		self:_do_update()
		return
	end

	-- Mark that we have a pending update
	self.pending_update = true

	-- Use a static variable to track if a timer is already scheduled
	if BaseLspNotification._update_timer_active then
		return
	end

	-- Create a new timer
	BaseLspNotification._update_timer_active = true
	vim.defer_fn(function()
		-- Only update if there are pending updates
		if self.pending_update then
			self:_do_update()
			self.pending_update = false
		end
		BaseLspNotification._update_timer_active = false
	end, options.debounce.timeout)
end

-- The actual update function
function BaseLspNotification:_do_update()
	if not self.notification then
		-- Only start a notification if we have clients
		if self:count_clients() > 0 then
			self:notification_start()
			self.spinner = 1
			self:spinner_start()
		end
	elseif self:count_clients() > 0 then
		self:notification_progress()
	elseif self:count_clients() == 0 then
		self:notification_end()
	end
end

function BaseLspNotification:schedule_kill_task(client_id, task_id)
	-- Wait a bit before hiding the task to show that it's complete
	vim.defer_fn(function()
		local client = self.clients[client_id]
		if not client then
			return
		end

		client:kill_task(task_id)
		-- Force an immediate update for task completion
		self.pending_update = true
		BaseLspNotification._update_timer_active = false
		self:_do_update()

		if client:count_tasks() == 0 then
			-- Wait a bit before hiding the client to show that its' tasks are complete
			vim.defer_fn(function()
				if not client or client:count_tasks() == 0 then
					-- Make sure we don't hide a client notification if a task appeared in down time
					self.clients[client_id] = nil

					-- Check if this was the last client
					if self:count_clients() == 0 and self.notification then
						-- Force an immediate update for client completion
						self.pending_update = true
						BaseLspNotification._update_timer_active = false
						self:_do_update()
					end
				end
			end, 2000)
		end
	end, 1000)
end

function BaseLspNotification:format_title()
	return "LSP"
end

function BaseLspNotification:format()
	local clients = ""
	for _, c in pairs(self.clients) do
		clients = clients .. c:format() .. "\n"
	end

	return clients ~= "" and clients:sub(1, -2) or "Complete"
end

function BaseLspNotification:spinner_start()
	-- Stop spinner if notification or spinner was cleared
	if not self.notification or not self.spinner then
		return
	end

	if options.icons and options.icons.spinner then
		self.spinner = (self.spinner % #options.icons.spinner) + 1

		if supports_replace then
			-- Don't spam spinner updates if notification can't be replaced
			self.notification = options.notify(nil, nil, {
				hide_from_history = true,
				icon = options.icons.spinner[self.spinner],
				replace = self.notification,
			})
		end

		-- Trigger new spinner frame
		vim.defer_fn(function()
			self:spinner_start()
		end, options.debounce.enabled and math.max(100, options.debounce.timeout) or 100)
	end
end

--#endregion

---#region Handlers

local function has_value(tab, val)
	for _, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

local notification = BaseLspNotification:new()

local function handle_progress(_, result, context)
	local value = result.value

	local client_id = context.client_id
	local client_name = vim.lsp.get_client_by_id(client_id).name

	if has_value(options.excludes, client_name) then
		return
	end

	-- Get client info from notification or generate it
	notification.clients[client_id] = notification.clients[client_id] or BaseLspClient.new(client_name)
	local client = notification.clients[client_id]

	local task_id = result.token
	-- Get task info from notification or generate it
	client.tasks[task_id] = client.tasks[task_id] or BaseLspTask.new(value.title, value.message)
	local task = client.tasks[task_id]

	if value.kind == "report" then
		-- Task update
		task.message = value.message
		task.percentage = value.percentage
	elseif value.kind == "end" then
		-- Task end
		task.message = value.message or "Complete"
		notification:schedule_kill_task(client_id, task_id)
	end

	-- Redraw notification
	notification:update()
end

local function handle_message(err, method, params, client_id)
	-- Table from LSP severity to VIM severity.
	local severity = {
		vim.log.levels.ERROR,
		vim.log.levels.WARN,
		vim.log.levels.INFO,
		vim.log.levels.INFO, -- Map both `hint` and `info` to `info`
	}
	options.notify(method.message, severity[params.type], { title = "LSP" })
end

--#endregion

--#region Setup

local function init()
	if vim.lsp.handlers["$/progress"] then
		-- There was already a handler, execute it too
		local old = vim.lsp.handlers["$/progress"]
		vim.lsp.handlers["$/progress"] = function(...)
			old(...)
			handle_progress(...)
		end
	else
		vim.lsp.handlers["$/progress"] = handle_progress
	end

	if vim.lsp.handlers["window/showMessage"] then
		-- There was already a handler, execute it too
		local old = vim.lsp.handlers["window/showMessage"]
		vim.lsp.handlers["window/showMessage"] = function(...)
			old(...)
			handle_message(...)
		end
	else
		vim.lsp.handlers["window/showMessage"] = handle_message
	end
end

return {
	---@param opts LspNotifyConfig? Configuration.
	setup = function(opts)
		options = vim.tbl_deep_extend("force", options, opts or {})
		supports_replace = check_supports_replace()

		init()
	end,
}

--#endregion
