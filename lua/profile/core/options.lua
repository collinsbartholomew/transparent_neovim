local opt = vim.opt

opt.mouse = ""
opt.fillchars = { eob = " " }
opt.number = true
opt.relativenumber = true
opt.clipboard = "unnamedplus"
opt.guicursor = "a:block"

-- Indentation settings
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = false
opt.smartindent = true
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
-- UI settings
opt.cmdheight = 0
opt.updatetime = 300
opt.timeoutlen = 300
opt.showtabline = 0 -- Hide tabline/top bar
opt.pumheight = 10
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.shortmess:append("c")

-- Additional fillchars settings to ensure no ~ characters
opt.fillchars:append({
    vert = "│",
    horiz = "─",
    horizup = "┴",
    horizdown = "┬",
    vertleft = "┤",
    vertright = "├",
    verthoriz = "┼",
})
