local api = vim.api
local profile_augroup = api.nvim_create_augroup("ProfileAutocommands", { clear = true })

-- Filetype registration
vim.filetype.add({
	extension = {
		mo = "motoko",
		mojo = "mojo",
		asm = "asm",
		s = "asm",
		S = "asm",
	},
	filename = {
		["*.blade.php"] = "blade",
	},
	pattern = {
		[".*%.🔥"] = "mojo",
	},
})

-- FileType-specific indentation settings (consolidated)
local indent_settings = {
	-- Tabs (no expansion)
	{ pattern = { "asm", "go" },                                                                                                                                                      tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = false },
	-- 4 spaces
	{ pattern = { "mojo", "python", "lua", "javascript", "typescript", "ruby", "rust", "c", "cpp", "java", "cs", "zig", "sh", "bash", "zsh", "vim", "php", "blade", "json", "toml" }, tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },
	-- 3 spaces
	{ pattern = { "html", "xml", "xhtml", "svg", "css", "scss", "jsx", "tsx" },                                                                                                       tabstop = 3, shiftwidth = 3, softtabstop = 3, expandtab = true },
	-- 2 spaces
	{ pattern = { "yaml", "yml" },                                                                                                                                                    tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
}

for _, config in ipairs(indent_settings) do
	api.nvim_create_autocmd("FileType", {
		group = profile_augroup,
		pattern = config.pattern,
		callback = function()
			vim.opt_local.tabstop = config.tabstop
			vim.opt_local.shiftwidth = config.shiftwidth
			vim.opt_local.softtabstop = config.softtabstop
			vim.opt_local.expandtab = config.expandtab
		end,
	})
end

api.nvim_create_autocmd("VimResized", {
	group = profile_augroup,
	callback = function()
		pcall(vim.cmd, "wincmd=")
	end,
})

api.nvim_create_autocmd("TextYankPost", {
	group = profile_augroup,
	callback = function()
		vim.hl.on_yank({ timeout = 200 })
	end,
})

api.nvim_create_autocmd("BufWritePre", {
	group = profile_augroup,
	command = [[%s/\s\+$//e]],
})

api.nvim_create_autocmd("BufWritePre", {
	group = profile_augroup,
	callback = function()
		if not vim.fn.expand("%:p"):match("term://") then
			vim.fn.mkdir(vim.fn.expand("%:p:h"), "p")
		end
	end,
})

api.nvim_create_autocmd("FileType", {
	group = profile_augroup,
	pattern = {
		"help", "startuptime", "qf", "lspinfo", "man", "spectre_panel",
		"dbui", "neotest-summary", "neotest-output", "neotest-output-panel",
		"aerial-nav", "grug-far",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

api.nvim_create_autocmd("FileType", {
	group = profile_augroup,
	pattern = "dap-float",
	callback = function(event)
		vim.keymap.set("n", "<ESC>", "<cmd>close!<cr>", { buffer = event.buf, silent = true })
	end,
})

api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, {
	group = profile_augroup,
	callback = function()
		if vim.opt.number:get() then
			vim.opt.relativenumber = true
		end
	end,
})

-- Diagnostic configuration
vim.o.signcolumn = "yes"
vim.diagnostic.config({
	virtual_text = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

local function set_diagnostic_colors()
	vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#F7768E", bg = "NONE" })
	vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#E0AF68", bg = "NONE" })
	vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#7AA2F7", bg = "NONE" })
	vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#0DB9D7", bg = "NONE" })
end

set_diagnostic_colors()
api.nvim_create_autocmd("ColorScheme", {
	group = profile_augroup,
	callback = set_diagnostic_colors,
})
