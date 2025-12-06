-- Overseer configuration
-- Task runner and build system integration for Neovim

local M = {}

function M.setup()
	local overseer = require("overseer")

	overseer.setup({
		task_list = {
			direction = "bottom",
			min_height = 15, -- Reduced from 25 for better screen usage
			max_height = 30, -- Reduced from 40 for better screen usage
			default_detail = 1,
			bindings = {
				["?"] = "actions.help",
				["g?"] = "actions.help",
				["<CR>"] = "actions.run_task",
				["<C-e>"] = "actions.edit_task",
				["o"] = "actions.open_task_panel",
				["O"] = "actions.open_hsplit",
				["L"] = "actions.open_vsplit",
				["q"] = "actions.close",
				["p"] = "actions.toggle_preview",
				["<C-l>"] = "actions.cycle_detail",
				["["] = "actions.previous_task",
				["]"] = "actions.next_task",
				["<C-k>"] = "actions.scroll_output_up",
				["<C-j>"] = "actions.scroll_output_down",
			},
		},
		dap = false,
		strategy = {
			"toggleterm",
			use_shell = false,
			direction = "vertical",
			auto_scroll = true,
			quit_on_exit = "success",
			on_new_task = function(task) end,
		},
		templates = { "builtin" }, -- Simplified templates for better performance
		template_timeout = 3000, -- Reduced from 5000 for better responsiveness
		confirm = {
			avail_templates = false,
			notify = true,
		},
		always_show_dap = false,
		preload_history = false, -- Disabled for performance
		actions = {},
	})

	-- Load custom user tasks
	require("overseer.template").register({
		name = "python run",
		builder = function(params)
			return {
				cmd = { "python" },
				args = { vim.fn.expand("%") },
				components = {
					{
						"default",
						timeout = 60, -- Reduced from 120 for better responsiveness
						on_output_parse = vim.schedule_wrap(function(lines, info)
							if info.code == 0 then
								vim.notify("Python script ran successfully", vim.log.levels.INFO)
							end
						end),
					},
				},
			}
		end,
		condition = {
			filetype = { "python" },
		},
	})

	-- Keybindings for Overseer
	local wk_ok, which_key = pcall(require, "which-key")
	if wk_ok then
		which_key.register({
			o = {
				name = "Overseer",
				r = { "<cmd>OverseerRun<cr>", "Run task" },
				t = { "<cmd>OverseerToggle<cr>", "Toggle task panel" },
			},
		}, { prefix = "<leader>" })
	end
end

return M