local opt = vim.opt
-- Core settings
opt.mouse = "a"          -- Enable mouse in all modes
opt.clipboard = "unnamedplus"  -- Use system clipboard
vim.cmd([[runtime! plugin/matchparen.vim]])
-- UI Improvements
opt.fillchars = {
    eob = " ",        -- Hide ~ at end of buffer
    vert = "│",       -- Vertical split character
    horiz = "─",      -- Horizontal split character
    horizup = "┴",    -- Split corner characters
    horizdown = "┬",
    vertleft = "┤",
    vertright = "├",
    verthoriz = "┼",
}
-- Line numbers
opt.number = true
opt.relativenumber = true
-- Indentation settings
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Set up filetype-specific indentation
-- File type specific indentation is handled in autocmds.lua

-- Modern autocommands for better UX
vim.api.nvim_create_augroup('modern_features', { clear = true })

-- Smart wrap settings
vim.api.nvim_create_autocmd('FileType', {
    group = 'modern_features',
    pattern = { 'markdown', 'txt', 'tex', 'gitcommit' },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.breakindent = true
        vim.opt_local.breakindentopt = 'shift:2'
        vim.opt_local.showbreak = '↪ '
    end,
})
-- Search settings
opt.hlsearch = false     -- Don't highlight search results
opt.incsearch = true     -- Show search matches as you type
-- Appearance settings
opt.termguicolors = true -- Enable 24-bit RGB color in the terminal

opt.wrap = false         -- Don't wrap lines
-- Folding settings
opt.foldlevel = 99
opt.foldlevelstart = 99
-- Backspace behavior
opt.backspace = "indent,eol,start" -- Allow backspacing over indent, end of line, and start of insert
-- Window splitting behavior
opt.splitright = true
opt.splitbelow = true
-- File handling settings
opt.swapfile = false -- Don't create swap files
opt.backup = false   -- Don't create backup files
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.undofile = true

-- Additional search settings
opt.ignorecase = true
opt.smartcase = true
-- UI and performance settings
-- `cmdheight=0` is supported only on newer Neovim; guard to avoid startup errors
opt.cmdheight = 0
opt.updatetime = 250       -- Faster completion
opt.timeoutlen = 300       -- Time to wait for mapped sequence
opt.redrawtime = 1500      -- Time for syntax highlighting
opt.ttimeoutlen = 10       -- Time for key code sequences
opt.showtabline = 0        -- Hide tabline/top bar
opt.pumheight = 10         -- Maximum number of items in popup menu
opt.scrolloff = 8          -- Lines of context
opt.sidescrolloff = 8      -- Columns of context
opt.shortmess:append({ W = true, I = true, c = true })  -- Reduce messages

