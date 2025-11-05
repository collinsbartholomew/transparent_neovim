-- Neo-tree setup
local M = {}

function M.setup()
	-- Ensure required dependencies are loaded first
	local status_ok, neo_tree = pcall(require, "neo-tree")
	if not status_ok then
		return
	end

	neo_tree.setup({
		close_if_last_window = false,
		popup_border_style = "rounded",
		enable_git_status = true,
		enable_diagnostics = false,
		window = {
			position = "left",
			width = 30,
			mapping_options = {
				noremap = true,
				nowait = true,
			},
			mappings = {
				["<space>"] = "none",
			},
		},

		filesystem = {
			filtered_items = {
				visible = true, -- Show all files
				hide_dotfiles = false, -- Don't hide dotfiles
				hide_gitignored = false, -- Don't hide gitignored files
				hide_hidden = false, -- Don't hide hidden files
				never_show = {}, -- Don't hide any files
			},
			follow_current_file = true,
			group_empty_dirs = false,
			hijack_netrw_behavior = "disabled",
			use_libuv_file_watcher = true,
		},
		event_handlers = {
			{
				event = "neo_tree_buffer_enter",
				handler = function()
					vim.opt_local.signcolumn = "auto"
				end,
			},
		},
		default_component_configs = {
			container = {
				enable_character_fade = true,
			},
			indent = {
				indent_size = 2,
				padding = 1,
				with_markers = true,
				indent_marker = "│",
				last_indent_marker = "└",
				highlight = "NeoTreeIndentMarker",
			},
			icon = {
				folder_closed = "",
				folder_open = "",
				folder_empty = "~",
				default = "*",
				highlight = "NeoTreeFileIcon",
			},
			modified = {
				symbol = "[+] ",
				highlight = "NeoTreeModified",
			},
			name = {
				trailing_slash = false,
				use_git_status_colors = true,
				highlight = "NeoTreeFileName",
			},
			git_status = {
				symbols = {
					added = "✚",
					deleted = "✖",
					modified = "",
					renamed = "➜",
					untracked = "★",
					ignored = "◌",
					unstaged = "✗",
					staged = "✓",
					conflict = "",
				},
			},
		},
		commands = {
			toggle = function(state)
				state:close()
			end,
		},
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "neo-tree",
		callback = function()
			vim.opt_local.winhighlight = "WinSeparator:NeoTreeWinSeparator"
		end,
	})

	vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { fg = "#888888", bg = "NONE", bold = true })
end

return M
