local M = {}

function M.setup()
	local status_ok, noice = pcall(require, "noice")
	if not status_ok then
		return
	end

	noice.setup({
		lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
			hover = {
				enabled = true,
				silent = false,
			},
			signature = {
				enabled = true,
				auto_open = {
					enabled = false,
					trigger = false,
				},
			},
			progress = {
				enabled = true,
			},
		},
		presets = {
			bottom_search = false,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = false,
			lsp_doc_border = true,
		},
		views = {
			notify = {
				merge = true,
				replace = true,
			},
			hover = {
				border = {
					style = "rounded",
				},
				size = {
					max_width = 50,
					max_height = 10,
				},
				win_options = {
					wrap = true,
					winblend = 0,
				},
				zindex = 1000,
			},
			signature = {
				border = {
					style = "rounded",
				},
				size = {
					max_width = 50,
					max_height = 8,
				},
				win_options = {
					wrap = true,
					winblend = 0,
				},
				zindex = 1000,
			},
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					any = {
						{ find = "%d+L, %d+B" },
						{ find = "; after #%d+" },
						{ find = "; before #%d+" },
						{ find = "%d fewer lines" },
						{ find = "%d more lines" },
						{ find = "migrations" },
					},
				},
				view = "mini",
			},
			{
				filter = {
					event = "msg_showmode",
				},
				view = "mini",
			},
			{
				filter = {
					event = "notify",
					find = "migrations",
				},
				view = "mini",
			},
		},
		messages = {
			enabled = true,
			view_error = "notify",
			view_warn = "notify",
			view_history = "messages",
			view_search = false,
		},
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
			format = {
				cmdline = { pattern = "^:", icon = ":" },
				search_down = { kind = "search", pattern = "^/", icon = "/" },
				search_up = { kind = "search", pattern = "^%?", icon = "?" },
			},
		},
		popupmenu = {
			enabled = true,
			backend = "nui",
		},
		notify = {
			enabled = true,
			render = "notify",
		},
		throttle = 1000 / 30,
	})
end

return M
