-- Trouble configuration
-- Better diagnostics viewer and problem list

local M = {}

function M.setup()
	local trouble = require("trouble")

	trouble.setup({
		fold_open = "󰝤",
		fold_closed = "󰝥",
		indent_lines = true,
		severity = nil,
		groupby = "category",
		action_keys = {
			close = "q",
			cancel = "<esc>",
			refresh = "r",
			jump = { "<cr>", "<tab>", "<2-LeftMouse>" },
			open_split = { "<c-x>" },
			open_vsplit = { "<c-v>" },
			open_tab = { "<c-t>" },
			previous = "K",
			next = "J",
			help = "?",
		},
		multiline = false,
		restore = true,
		follow = true,
		cyclical = true,
		indent_guides = true,
		signs = {
			error = "󰅙",
			warning = "󰀪",
			hint = "󰌶",
			information = "󰋼",
			other = "󰠠",
		},
		use_diagnostic_signs = true,
	})

	local wk_ok, which_key = pcall(require, "which-key")
	if wk_ok then
		which_key.register({
			x = {
				name = "Trouble",
				x = { "<cmd>Trouble toggle<cr>", "Toggle Trouble" },
				w = { "<cmd>Trouble toggle mode=workspace_diagnostics<cr>", "Workspace Diagnostics" },
				d = { "<cmd>Trouble toggle mode=document_diagnostics<cr>", "Document Diagnostics" },
				q = { "<cmd>Trouble toggle mode=quickfix<cr>", "Quickfix" },
				l = { "<cmd>Trouble toggle mode=loclist<cr>", "Location List" },
			},
		}, { prefix = "<leader>" })
	end
end

return M
