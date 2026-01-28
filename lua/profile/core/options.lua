local opt = vim.opt
local M = {}

function M.setup()
	-- Core
	opt.mouse = "" -- Disabled as requested
	opt.clipboard = "unnamedplus"
	opt.updatetime = 200
	opt.timeoutlen = 300
	opt.undofile = true
	opt.swapfile = false
	opt.backup = false

	-- Cursor (block in all modes as requested)
	opt.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:block"

	-- Display
	opt.number = true
	opt.relativenumber = true
	opt.signcolumn = "yes"
	opt.cursorline = true
	opt.termguicolors = true
	opt.scrolloff = 8
	opt.sidescrolloff = 8
	opt.wrap = false
	opt.linebreak = true
	opt.showmode = false
	opt.conceallevel = 0

	-- Search
	opt.ignorecase = true
	opt.smartcase = true
	opt.hlsearch = true
	opt.incsearch = true

	-- Indentation (optimized built-in features)
	opt.tabstop = 4
	opt.shiftwidth = 4
	opt.expandtab = false
	opt.smartindent = true
	opt.autoindent = true
	opt.breakindent = true
	opt.shiftround = true
	opt.smarttab = true

	-- Built-in blank line indentation (replaces indent-blankline plugin)
	opt.list = true
	opt.listchars = {
		tab = "│ ",
		trail = "·",
		nbsp = "␣",
		leadmultispace = "│   ",
		multispace = "│   ",
		lead = "│",
		precedes = "‹",
		extends = "›",
	}

	-- Folding (built-in treesitter folding)
	opt.foldmethod = "expr"
	opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	opt.foldlevel = 99
	opt.foldlevelstart = 99
	opt.foldenable = true

	-- Completion
	opt.completeopt = { "menu", "menuone", "noselect" }
	opt.pumheight = 10
	opt.pumblend = 10
	opt.winblend = 10

	-- Visual improvements
	opt.fillchars = {
		fold = " ",
		foldsep = " ",
		diff = "╱",
		eob = " ",
		vert = "│",
		horiz = "─",
		horizup = "┴",
		horizdown = "┬",
		vertleft = "┤",
		vertright = "├",
		verthoriz = "┼",
	}

	-- Performance optimizations
	opt.lazyredraw = false
	opt.synmaxcol = 240
	opt.redrawtime = 10000

	-- Split behavior
	opt.splitbelow = true
	opt.splitright = true
	opt.splitkeep = "screen"

	-- Command line
	opt.cmdheight = 1
	opt.showcmd = false
	opt.ruler = false

	-- Diff improvements
	opt.diffopt:append("linematch:60")

	-- Built-in spell checking
	opt.spelllang = "en_us"
	opt.spelloptions = "camel"
end

return M
