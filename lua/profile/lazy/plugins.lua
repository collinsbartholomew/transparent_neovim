-- stylua: ignore start
-- lazy.nvim plugin specs (reviewed & adjusted lazy/event settings)
-- I inspected the original table and made conservative changes:
-- 1) Keep core runtime plugins and themes loaded eagerly (lazy = false) so statusline, icons,
--    LSP, mason, treesitter, and notifications are available early.
-- 2) Keep command/event-based lazy loading for plugins that are expensive and can load on demand.
-- 3) Wrap a few plugin configs with pcall in their config functions where appropriate to avoid
--    a single failing config from breaking the rest of the setup.

return {
	-- === Core & Performance ===
	{
		"folke/lazy.nvim",
		version = "*",
		lazy = false,
		opts = {
			ui = {
				border = "single",
			},
		},
	},

	-- === UI & Navigation ===
	{
		"folke/which-key.nvim",
		lazy = false,
		priority = 100,
	},

	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("profile.ui.telescope").setup()
		end,
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("profile.ui.neotree").setup()
		end,
	},

	{
		"ThePrimeagen/harpoon",
		cmd = "Harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = true,
	},

	-- === Completion & LSP ===
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp",         lazy = true },
			{ "hrsh7th/cmp-buffer",           lazy = true },
			{ "hrsh7th/cmp-path",             lazy = true },
			{ "hrsh7th/cmp-cmdline",          lazy = true },
			{ "saadparwaiz1/cmp_luasnip",     lazy = true },
			{ "L3MON4D3/LuaSnip",             lazy = true },
			{ "rafamadriz/friendly-snippets", lazy = true },
		},
		config = function()
			require("profile.completion.cmp").setup()
		end,
	},

	-- Mason & LSP: keep eager because other plugins expect them during startup
	{
		"williamboman/mason.nvim",
		lazy = false,
		priority = 500,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		priority = 499,
		dependencies = { "williamboman/mason.nvim" },
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = false,
		priority = 498,
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
	},

	{
		"neovim/nvim-lspconfig",
		lazy = false,
		priority = 400,
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
	},

	{ "folke/neodev.nvim",     ft = "lua",     lazy = true, config = true },

	-- Breadcrumbs (disabled to remove topbar)
	-- {
	-- 	"utilyre/barbecue.nvim",
	-- 	event = { "BufReadPost", "BufNewFile" },
	-- 	dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
	-- 	config = function()
	-- 		require("barbecue").setup({ theme = "auto", show_dirname = false, show_modified = true })
	-- 	end,
	-- },

	-- === AI & Coding Assistance ===
	{
		"yetone/avante.nvim",
		cmd = { "AvanteAsk", "AvanteChat", "AvanteToggle" },
		version = false,
		build = "make",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("avante_lib").load() -- Load default libraries
			require("avante").setup({ provider = "claude", auto_suggestions_provider = "claude" })
		end,
	},

	{
		"olimorris/codecompanion.nvim",
		cmd = "CodeCompanion",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = true,
	},

	-- === Code Actions UI ===
	{
		"aznhe21/actions-preview.nvim",
		event = "LspAttach",
		config = function()
			require("actions-preview").setup({
				telescope = vim.tbl_extend("force",
					require("telescope.themes").get_dropdown(), {})
			})
		end,
	},

	-- === Debugging ===
	{
		"mfussenegger/nvim-dap",
		lazy = true,
	},

	{
		"rcarriga/nvim-dap-ui",
		cmd = { "DapUiToggle", "DapContinue" },
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = true,
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		lazy = true,
		dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		lazy = true,
		dependencies = { "mfussenegger/nvim-dap" },
		config = true,
	},

	-- === Git ===
	{ "tpope/vim-fugitive",    cmd = "Git" },
	{ "kdheepak/lazygit.nvim", cmd = "LazyGit" },
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				current_line_blame = false,
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end
					map("n", "]h", gs.next_hunk, { desc = "Next hunk" })
					map("n", "[h", gs.prev_hunk, { desc = "Prev hunk" })
					map("n", "<leader>ghs", gs.stage_hunk, { desc = "Stage hunk" })
					map("n", "<leader>ghr", gs.reset_hunk, { desc = "Reset hunk" })
					map("n", "<leader>ghp", gs.preview_hunk, { desc = "Preview hunk" })
					map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
					map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "Toggle blame" })
				end,
			})
		end,
	},

	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		config = true,
	},

	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = true,
	},

	-- === Editing Enhancements ===
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("profile.editing.autopairs").setup()
		end,
	},

	{
		"windwp/nvim-ts-autotag",
		ft = { "html", "javascript", "typescript", "jsx", "tsx", "vue", "svelte", "astro", "xml", "php", "blade" },
		config = function()
			require("profile.editing.autotag").setup()
		end,
	},

	{
		"numToStr/Comment.nvim",
		event = "BufReadPost",
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
		config = function()
			require("profile.editing.comment").setup()
		end,
	},

	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "BufReadPost",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("profile.editing.rainbow").setup()
		end,
	},

	{
		"echasnovski/mini.nvim",
		version = false,
		event = "BufReadPost",
		config = function()
			require("mini.indentscope").setup({ symbol = "│", options = { try_as_border = true } })
		end,
	},

	-- === Code Intelligence ===
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		priority = 300,
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			require("profile.treesitter").setup()
		end,
	},
	{
		"RRethy/vim-illuminate",
		event = "BufReadPost",
		config = function()
			require("illuminate").configure({
				on_highlight = function()
					vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
				end
			})
		end
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesitter-context").setup({
				enable = true,
				max_lines = 3,
				min_window_height = 20,
				mode = "topline",
				separator = "─",
			})
			vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#555555", bg = "NONE" })
			vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = "#444444", bg = "NONE" })
		end,
	},

	{ "stevearc/aerial.nvim", cmd = "AerialToggle", config = true },
	{ "SmiteshP/nvim-navic",  event = "LspAttach" },
	{
		"SmiteshP/nvim-navbuddy",
		dependencies = { "MunifTanjim/nui.nvim", "SmiteshP/nvim-navic" },
		event = "LspAttach",
		config = true,
	},
	{
		"ThePrimeagen/refactoring.nvim",
		event = "BufReadPost",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		config = true,
	},
	{ "folke/flash.nvim",            event = "VeryLazy", config = true },

	-- === Documentation & Markdown ===
	{
		"toppair/peek.nvim",
		cmd = { "PeekOpen", "PeekClose" },
		build = "deno task --quiet build:esbuild",
		ft = { "markdown", "markdown.pandoc", "rmd" },
		config = function()
			require("peek").setup()
		end,
	},

	-- === Formatting & Linting ===
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		config = function()
			require("profile.tools.conform").setup()
		end,
	},

	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("profile.tools.lint").setup()
		end,
	},

	-- === Tasks & Terminal ===
	{
		"stevearc/overseer.nvim",
		cmd = { "OverseerRun", "OverseerToggle" },
		config = function()
			require("profile.tools.overseer").setup()
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "TermExec" },
		config = function()
			require("profile.tools.toggleterm").setup()
		end,
	},

	-- === UI & Status ===
	{
		"rcarriga/nvim-notify",
		lazy = false,
		priority = 900,
		config = function()
			require("profile.ui.notifications").setup()
		end,
	},

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		config = function()
			require("profile.ui.noice").setup()
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		lazy = false,
		priority = 200,
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	{
		"stevearc/dressing.nvim",
		lazy = false,
		priority = 150,
		config = true,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		main = "ibl",
		config = function()
			require("profile.ui.indent").setup()
		end,
	},

	{
		"brenoprata10/nvim-highlight-colors",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			-- 1. Setup the plugin with desired options (virtual rendering)
			require("nvim-highlight-colors").setup({
				render = "background",
				virtual_symbol = "██",
				virtual_symbol_prefix = "",
				virtual_symbol_suffix = "",
				virtual_symbol_position = "inline",
			})
		end,
	},

	{
		"uga-rosa/ccc.nvim",
		keys = { { "<leader>cp", "<cmd>CccPick<cr>", desc = "Pick color" } },
		config = function()
			require("ccc").setup({ highlighter = { auto_enable = false } })
		end,
	},

	-- === Themes & Icons ===
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
	},

	{ "rose-pine/neovim",            name = "rose-pine", lazy = true },
	{ "EdenEast/nightfox.nvim",      lazy = true },
	{ "olimorris/onedarkpro.nvim",   lazy = true },
	{ "nvim-tree/nvim-web-devicons", lazy = false },
	{
		"echasnovski/mini.icons",
		version = false,
		event = "BufReadPost",
		config = function()
			require("mini.icons").setup()
		end,
	},

	-- === Sessions & Startup ===
	{ "folke/persistence.nvim",      cmd = "PersistenceLoad", config = true },
	{
		"goolord/alpha-nvim",
		lazy = false,
		priority = 999,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("profile.ui.enhancements").setup()
		end,
	},

	-- === Search & Replace ===
	{
		"nvim-pack/nvim-spectre",
		cmd = "Spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("profile.tools.spectre").setup()
		end,
	},

	-- === Testing ===
	{
		"nvim-neotest/neotest",
		cmd = { "Neotest" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-python",
			"nvim-neotest/neotest-go",
			"Issafalcon/neotest-dotnet",
			"rcasia/neotest-java",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			require("profile.tools.neotest").setup()
		end,
	},

	-- === Language-Specific ===
	--C/C++
	{ "p00f/clangd_extensions.nvim", ft = "c,cpp",            lazy = true },
	-- Rust
	{
		"mrcjkb/rustaceanvim",
		version = "^4",
		ft = { "rust" },
		dependencies = { "nvim-lua/plenary.nvim", "williamboman/mason.nvim" },
	},
	{ "rust-lang/rust.vim",                ft = "rust", lazy = true },
	{
		"saecki/crates.nvim",
		ft = { "rust", "toml" },
		config = true,
	},
	-- Go
	{
		"ray-x/go.nvim",
		ft = "go",
		config = function() require("go").setup({ lsp_cfg = true }) end,
	},
	{ "leoluz/nvim-dap-go",                ft = "go",   lazy = true },
	-- Zig
	{ "ziglang/zig.vim",                   ft = "zig",  lazy = true },
	-- C#
	{ "Hoffs/omnisharp-extended-lsp.nvim", ft = "cs",   lazy = true },
	-- Flutter/Dart
	{
		"akinsho/flutter-tools.nvim",
		ft = { "dart" },
		dependencies = { "nvim-lua/plenary.nvim", "stevearc/conform.nvim" },
		config = true,
	},
	-- Java
	{ "mfussenegger/nvim-jdtls", ft = "java", lazy = true },
	-- PHP & Laravel
	{
		"phpactor/phpactor",
		ft = "php",
		build = "composer install --ignore-platform-req=ext-iconv",
	},
	{ "ray-x/guihua.lua",        ft = "php",  lazy = true },
	{
		"adalessa/laravel.nvim",
		ft = { "php", "blade" },
		dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap", "rcarriga/nvim-notify" },
		config = true,
	},
	{ "jwalton512/vim-blade", ft = "blade", lazy = true },
	-- Mojo
	{ "czheo/mojo.vim",       ft = "mojo",  lazy = true },
	-- Database
	{
		"kristijanhusak/vim-dadbod-ui",
		cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
		dependencies = { "kristijanhusak/vim-dadbod" },
		config = function()
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_show_database_icon = 1
		end,
	},

	-- === Troubleshooting & Diagnostics ===
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		config = function()
			require("profile.tools.trouble").setup()
		end,
	},

	-- === Auto-save ===
	{
		"okuuva/auto-save.nvim",
		event = { "InsertLeave", "TextChanged" },
		config = function()
			require("auto-save").setup({
				enabled = true,
				trigger_events = { immediate_save = { "BufLeave", "FocusLost" }, defer_save = { "InsertLeave" } },
				condition = function(buf)
					local fn = vim.fn
					local utils = require("auto-save.utils.data")
					if fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
						return true
					end
					return false
				end,
				debounce_delay = 1000,
			})
		end,
	},

	-- === Surround ===
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = true,
	},

	-- === Undo Tree ===
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		config = function()
			require("profile.tools.undotree").setup()
		end,
	},
}
