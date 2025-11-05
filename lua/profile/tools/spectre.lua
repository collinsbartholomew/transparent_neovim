-- Spectre configuration
-- Search and replace panel with preview capabilities

local M = {}

function M.setup()
	local spectre = require("spectre")

	spectre.setup({
		color_devicons = true,
		highlight = {
			ui = "String",
			search = "DiffChange",
			replace = "DiffDelete",
		},
		mapping = {
			["toggle_line"] = {
				map = "dd",
				cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
				desc = "toggle current item",
			},
			["enter_file"] = {
				map = "<cr>",
				cmd = "<cmd>lua require('spectre.actions').enter_file()<CR>",
				desc = "open current item",
			},
			["send_to_qf"] = {
				map = "<leader>sqf",
				cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
				desc = "send all items to quickfix",
			},
			["replace_cmd"] = {
				map = "<leader>sc",
				cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
				desc = "input replace vim command",
			},
			["show_option_menu"] = {
				map = "<leader>so",
				cmd = "<cmd>lua require('spectre').show_options()<CR>",
				desc = "show options",
			},
			["run_current_replace"] = {
				map = "<leader>srl",
				cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
				desc = "replace current line",
			},
			["run_replace"] = {
				map = "<leader>sra",
				cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
				desc = "replace all",
			},
			["change_view_mode"] = {
				map = "<leader>sv",
				cmd = "<cmd>lua require('spectre').change_view()<CR>",
				desc = "results view mode",
			},
			["toggle_live_update"] = {
				map = "<leader>su",
				cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
				desc = "update on every text change",
			},
			["toggle_ignore_case"] = {
				map = "<leader>si",
				cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
				desc = "toggle ignore case",
			},
			["toggle_ignore_hidden"] = {
				map = "<leader>sh",
				cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
				desc = "toggle search hidden files",
			},
			["resume_last_search"] = {
				map = "<leader>sr",
				cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
				desc = "resume last search before close",
			},
			["history_open"] = {
				map = "<leader>s<leader>",
				cmd = "<cmd>lua require('spectre').open_file_search({select_word=false})<CR>",
				desc = "open search history",
			},
		},
		find_engine = {
			rg = {
				cmd = "rg",
				args = {
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
				},
				options = {
					["ignore-case"] = {
						value = "--ignore-case",
						icon = "[I]",
						desc = "ignore case",
					},
					["hidden"] = {
						value = "--hidden",
						desc = "hidden file",
					},
				},
			},
		},
		replace_engine = {
			sed = {
				cmd = "sed",
				args = nil,
				options = {
					["ignore-case"] = {
						value = "-i",
						icon = "[I]",
						desc = "ignore case",
					},
				},
			},
		},
		default = {
			find = {
				cmd = "rg",
				options = { "ignore-case" },
			},
			replace = {
				cmd = "sed",
			},
		},
		replace_vim_cmd = "cdo",
		is_open_target_win = true,
		is_insert_mode = false,
	})

	-- Keybindings for Spectre
	local wk_ok, which_key = pcall(require, "which-key")
	if wk_ok then
		which_key.register({
			s = {
				name = "Spectre",
				p = { "<cmd>lua require('spectre').open()<cr>", "Open Spectre" },
				w = { "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", "Search current word" },
				f = { "<cmd>lua require('spectre').open_file_search({select_word=false})<cr>", "Search on current file" },
			},
		}, { prefix = "<leader>" })
	end
end

return M
