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
        [".*%.mojo$"] = "mojo",
    },
})


api.nvim_create_autocmd("TextYankPost", {
	group = profile_augroup,
	callback = function()
		vim.hl.on_yank({ timeout = 200 })
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

-- Load keymaps after which-key is available
local function load_keymaps()
    local ok, keymaps = pcall(require, "profile.core.keymaps")
    if ok and keymaps and keymaps.setup then
        keymaps.setup()
    else
        -- Try again in 100ms if failed
        vim.defer_fn(load_keymaps, 100)
    end
end

-- Trigger keymap loading
api.nvim_create_autocmd("User", {
    group = profile_augroup,
    pattern = "VeryLazy",
    callback = load_keymaps,
})

-- Fallback: try to load keymaps after 500ms if VeryLazy event hasn't fired
vim.defer_fn(load_keymaps, 500)

-- Ensure signcolumn is always visible (diagnostics configured in profile.core.diagnostics)
vim.opt.signcolumn = "yes"