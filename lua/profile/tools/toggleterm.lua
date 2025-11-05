-- ToggleTerm configuration
-- Manage multiple terminal windows easily

local M = {}

function M.setup()
	local toggleterm = require("toggleterm")

	toggleterm.setup({
		size = function(term)
			if term.direction == "horizontal" then
				return 15
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.4
			end
			return 20
		end,
		open_mapping = [[<C-\>]],
		on_open = function(term)
			vim.cmd("startinsert!")
		end,
		on_close = function(term) end,
		hide_numbers = true,
		shade_filetypes = {},
		shade_terminals = true,
		shading_factor = 2,
		start_in_insert = true,
		insert_mappings = true,
		terminal_mappings = true,
		persist_size = true,
		persist_mode = true,
		direction = "float",
		close_on_exit = true,
		shell = vim.o.shell,
		auto_scroll = true,
		float_opts = {
			border = "curved",
			winblend = 3,
			highlights = {
				border = "Normal",
				background = "Normal",
			},
		},
		winbar = {
			enabled = true,
			name_formatter = function(term)
				return term.name
			end,
		},
	})

	-- Define custom terminal configurations
	local Terminal = require("toggleterm.terminal").Terminal

	-- Main floating terminal
	local float_term = Terminal:new({ cmd = vim.o.shell, hidden = true })

	function _G.toggle_float_term()
		float_term:toggle()
	end

	-- Horizontal split terminal
	local horizontal_term = Terminal:new({ cmd = vim.o.shell, direction = "horizontal", hidden = true })

	function _G.toggle_horizontal_term()
		horizontal_term:toggle()
	end

	-- Vertical split terminal
	local vertical_term = Terminal:new({ cmd = vim.o.shell, direction = "vertical", hidden = true })

	function _G.toggle_vertical_term()
		vertical_term:toggle()
	end

	-- Python REPL
	local python_term = Terminal:new({
		cmd = "python3",
		direction = "float",
		hidden = true,
		on_open = function(term)
			vim.cmd("startinsert!")
		end,
	})

	function _G.toggle_python_term()
		python_term:toggle()
	end

	-- Node REPL
	local node_term = Terminal:new({
		cmd = "node",
		direction = "float",
		hidden = true,
		on_open = function(term)
			vim.cmd("startinsert!")
		end,
	})

	function _G.toggle_node_term()
		node_term:toggle()
	end

	-- Keybindings for ToggleTerm
	local opts = { noremap = true, silent = true }
	vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", vim.tbl_extend("force", opts, { desc = "Toggle terminal" }))
	vim.keymap.set("n", "<leader>tf", "<cmd>lua toggle_float_term()<cr>", vim.tbl_extend("force", opts, { desc = "Toggle float terminal" }))
	vim.keymap.set("n", "<leader>th", "<cmd>lua toggle_horizontal_term()<cr>", vim.tbl_extend("force", opts, { desc = "Toggle horizontal terminal" }))
	vim.keymap.set("n", "<leader>tv", "<cmd>lua toggle_vertical_term()<cr>", vim.tbl_extend("force", opts, { desc = "Toggle vertical terminal" }))

	-- Python and Node REPL keybindings
	vim.keymap.set("n", "<leader>tp", "<cmd>lua toggle_python_term()<cr>", vim.tbl_extend("force", opts, { desc = "Toggle Python REPL" }))
	vim.keymap.set("n", "<leader>tn", "<cmd>lua toggle_node_term()<cr>", vim.tbl_extend("force", opts, { desc = "Toggle Node REPL" }))

	-- Terminal mode keybindings
	vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
	vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
	vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
	vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)

	-- Register with which-key using new API
	local wk_ok, which_key = pcall(require, "which-key")
	if wk_ok then
		which_key.add({
			{ '<leader>t', group = 'Terminal' },
			{ '<leader>tt', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },
			{ '<leader>tf', '<cmd>lua toggle_float_term()<cr>', desc = 'Float terminal' },
			{ '<leader>th', '<cmd>lua toggle_horizontal_term()<cr>', desc = 'Horizontal terminal' },
			{ '<leader>tv', '<cmd>lua toggle_vertical_term()<cr>', desc = 'Vertical terminal' },
			{ '<leader>tp', '<cmd>lua toggle_python_term()<cr>', desc = 'Python REPL' },
			{ '<leader>tn', '<cmd>lua toggle_node_term()<cr>', desc = 'Node REPL' },
		})
	end
end

return M
