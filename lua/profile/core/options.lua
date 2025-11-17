local opt = vim.opt
-- Core settings
opt.mouse = "a"          -- Enable mouse in all modes
opt.clipboard = "unnamedplus"  -- Use system clipboard

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

-- Search settings
opt.hlsearch = false     -- Don't highlight search results
opt.incsearch = true     -- Show search matches as you type
-- Appearance settings
opt.termguicolors = true -- Enable 24-bit RGB color in the terminal
opt.wrap = false         -- Don't wrap lines

-- Folding settings (using ufo for advanced folding)
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "0"  -- Don't show fold column by default

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
opt.signcolumn = "yes"     -- Always show sign column