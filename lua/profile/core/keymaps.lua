local M = {}

function M.setup()
	local map = vim.keymap.set

	-- Navigation
	map("n", "<leader>nh", ":nohlsearch<CR>")
	map("n", "<S-h>", "<cmd>bprev<cr>")
	map("n", "<S-l>", "<cmd>bnext<cr>")
	map("n", "<C-h>", "<C-w>h")
	map("n", "<C-j>", "<C-w>j")
	map("n", "<C-k>", "<C-w>k")
	map("n", "<C-l>", "<C-w>l")

	-- Move lines
	map("n", "<A-j>", "<cmd>m .+1<cr>==")
	map("n", "<A-k>", "<cmd>m .-2<cr>==")
	map("v", "<A-j>", ":m '>+1<cr>gv")
	map("v", "<A-k>", ":m '<-2<cr>gv")

	-- Indenting
	map("v", "<", "<gv")
	map("v", ">", ">gv")

	-- Better paste
	map("x", "<leader>p", '"_dP')

	-- Theme toggle (improved)
	map("n", "<leader>tt", function()
		require("profile.ui.theme").toggle_theme()
	end, { desc = "Toggle theme" })

	-- Terminal
	map("n", "<leader>T", function()
		local wins = vim.api.nvim_list_wins()
		for _, win in ipairs(wins) do
			if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
				vim.api.nvim_win_close(win, false)
				return
			end
		end
		vim.cmd("botright 15split | terminal")
		vim.cmd("startinsert")
	end, { desc = "Toggle terminal" })

	-- Windows
	map("n", "<leader>w|", "<cmd>vsplit<cr>", { desc = "Vertical split" })
	map("n", "<leader>w-", "<cmd>split<cr>", { desc = "Horizontal split" })
	map("n", "<leader>wq", "<cmd>close<cr>", { desc = "Close window" })
	map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Close other windows" })

	-- Buffers
	map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
	map("n", "<leader>ba", "<cmd>%bd|e#<cr>", { desc = "Delete all but current" })

	-- LSP
	map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostics" })
	map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
	map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
	map("n", "<leader>lq", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix" })

	-- UI
	map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })
	map("n", "-", "<cmd>Neotree reveal<cr>", { desc = "Reveal in explorer" })
	map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle diagnostics" })

	-- Telescope
	map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
	map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
	map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
	map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
	map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
	map("n", "<leader>fc", "<cmd>Telescope commands<cr>", { desc = "Commands" })
	map("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Keymaps" })

	-- Quick actions
	map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
	map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
	map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Force quit all" })

	-- Better up/down
	map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
	map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

	-- Resize with arrows
	map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
	map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
	map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
	map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
end

return M
