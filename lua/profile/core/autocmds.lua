local api = vim.api
local profile_augroup = api.nvim_create_augroup("ProfileAutocommands", { clear = true })

-- Filetype registration
local ft = vim.filetype.add
ft({
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
	{ pattern = { "html", "xml", "xhtml", "svg", "css", "scss", "jsx", "tsx", "vue", "svelte", "astro" },                                                                                                       tabstop = 3, shiftwidth = 3, softtabstop = 3, expandtab = true },
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

-- Smart wrap settings for specific filetypes
api.nvim_create_autocmd('FileType', {
	group = profile_augroup,
	pattern = { 'markdown', 'txt', 'tex', 'gitcommit' },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.breakindent = true
		vim.opt_local.breakindentopt = 'shift:2'
		vim.opt_local.showbreak = '↪ '
	end,
})

api.nvim_create_autocmd("TextYankPost", {
	group = profile_augroup,
	callback = function()
		vim.hl.on_yank({ timeout = 200 })
	end,
})

-- BufWritePre handlers for auto-mkdir and trailing whitespace removal
api.nvim_create_autocmd("BufWritePre", {
    group = profile_augroup,
    callback = function(ev)
        -- Remove trailing whitespace only for specific filetypes
        local ft = vim.bo[ev.buf].filetype
        local skip_trailing = {
            markdown = true,
            text = true,
            [""] = true,
        }
        
        if not skip_trailing[ft] and not vim.bo[ev.buf].binary then
            local save_cursor = vim.fn.getpos('.')
            pcall(vim.cmd, [[%s/\s\+$//e]])
            vim.fn.setpos('.', save_cursor)
        end
        
        -- Create directory if it doesn't exist, skip for special buffers
        local path = vim.fn.expand("%:p")
        if path:match("^%w+://") or path:match("^term://") then
            return
        end
        local dir = vim.fn.fnamemodify(path, ":h")
        if dir ~= "" and not vim.loop.fs_stat(dir) then
            vim.fn.mkdir(dir, "p")
        end
    end,
})

api.nvim_create_autocmd("FileType", {
	group = profile_augroup,
	pattern = {
		"help", "startuptime", "qf", "lspinfo", "man", "spectre_panel",
		"dbui", "neotest-summary", "neotest-output", "neotest-output-panel",
		"aerial-nav", "Trouble", "tsplayground", "notify",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.bo[event.buf].bufhidden = "wipe"
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, desc = "Close window" })
	end,
})

api.nvim_create_autocmd("FileType", {
	group = profile_augroup,
	pattern = "dap-float",
	callback = function(event)
		vim.keymap.set("n", "<ESC>", "<cmd>close!<cr>", { buffer = event.buf, silent = true })
	end,
})

-- Smart number handling
api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
    group = profile_augroup,
    callback = function()
        if vim.wo.number and vim.api.nvim_get_mode().mode ~= 'i' then
            vim.wo.relativenumber = true
        end
    end,
})

api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
    group = profile_augroup,
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = false
        end
    end,
})
-- Ensure signcolumn is always visible (diagnostics configured in profile.core.diagnostics)
vim.opt.signcolumn = "yes"
