local M = {}

function M.setup()
	local group = vim.api.nvim_create_augroup("ProfileAutocmds", { clear = true })

	-- Highlight on yank
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = group,
		callback = function() vim.hl.on_yank({ timeout = 150 }) end,
	})

	-- Close with q
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = { "help", "lspinfo", "man", "qf", "trouble", "telescope" },
		callback = function(event)
			vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf })
		end,
	})

	-- Language-specific indentation
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = { "html", "css", "javascript", "typescript", "json", "yaml", "lua" },
		callback = function()
			vim.opt_local.tabstop = 2
			vim.opt_local.shiftwidth = 2
			vim.opt_local.expandtab = true
		end,
	})

	-- Python specific
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "python",
		callback = function()
			vim.opt_local.tabstop = 4
			vim.opt_local.shiftwidth = 4
			vim.opt_local.expandtab = true
		end,
	})

	-- Go specific
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "go",
		callback = function()
			vim.opt_local.tabstop = 4
			vim.opt_local.shiftwidth = 4
			vim.opt_local.expandtab = false
		end,
	})

	-- Auto-create directories
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		callback = function(event)
			local file = vim.uv.fs_realpath(event.match) or event.match
			vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
		end,
	})

	-- Restore cursor position
	vim.api.nvim_create_autocmd("BufReadPost", {
		group = group,
		callback = function()
			local mark = vim.api.nvim_buf_get_mark(0, '"')
			local lcount = vim.api.nvim_buf_line_count(0)
			if mark[1] > 0 and mark[1] <= lcount then
				pcall(vim.api.nvim_win_set_cursor, 0, mark)
			end
		end,
	})

	-- Check if file changed outside of vim
	vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
		group = group,
		command = "checktime",
	})

	-- Resize splits when window is resized
	vim.api.nvim_create_autocmd("VimResized", {
		group = group,
		command = "tabdo wincmd =",
	})

	-- Disable diagnostics in node_modules
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		group = group,
		pattern = "*/node_modules/*",
		callback = function()
			vim.diagnostic.disable(0)
		end,
	})

	-- Enable spell checking for certain file types
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = { "gitcommit", "markdown", "text" },
		callback = function()
			vim.opt_local.spell = true
			vim.opt_local.spelllang = "en_us"
		end,
	})

	-- Better blank line indentation
	vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
		group = group,
		callback = function()
			-- Force redraw to show indentation guides on blank lines
			vim.cmd("redraw")
		end,
	})

	-- Maintain transparency after colorscheme changes
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			require("profile.ui.theme").apply_transparency()
		end,
	})

	-- Terminal settings
	vim.api.nvim_create_autocmd("TermOpen", {
		group = group,
		callback = function()
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
			vim.opt_local.signcolumn = "no"
			vim.cmd("startinsert")
		end,
	})
end

return M