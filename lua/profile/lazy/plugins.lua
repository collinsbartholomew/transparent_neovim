-- stylua: ignore start
-- lazy.nvim plugin specs (reviewed & adjusted lazy/event settings)
-- 1) Keep core runtime plugins and themes loaded eagerly (lazy = false) so statusline, icons,
--    LSP, mason, and notifications are available early.
-- 2) Keep command/event-based lazy loading for plugins that are expensive and can load on demand.
-- 3) Wrap a few plugin configs with pcall in their config functions where appropriate to avoid
--    a single failing config from breaking the rest of the setup.

return {
	-- === Core & Performance ===
	{
		"folke/lazy.nvim",
		lazy = false,
		opts = {
			ui = {
				border = "single",
			},
		},
	},

	-- === Themes & Icons (Load early for UI) ===
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("profile.ui.theme").setup()
		end,
	},
	{ "rose-pine/neovim",            name = "rose-pine", lazy = true },
	{ "EdenEast/nightfox.nvim",      lazy = true },
	{ "olimorris/onedarkpro.nvim",   lazy = false, priority = 1000 },
	{ "nvim-tree/nvim-web-devicons", lazy = false, priority = 1000, config = false },
	{
		"echasnovski/mini.icons",
		lazy = false,
		priority = 1000,
		config = function()
			require("mini.icons").setup()
		end,
	},

	-- === UI & Navigation ===
	{
		"folke/which-key.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("profile.ui.whichkey").setup()
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		lazy = false,
		priority = 1000,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("profile.ui.statusline").setup()
		end,
	},

	{
		"rcarriga/nvim-notify",
		lazy = false,
		priority = 1000,
		config = function()
			require("profile.ui.notifications").setup()
		end,
	},

	{
		"stevearc/dressing.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("dressing").setup()
			require("profile.ui.popups").setup()
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		lazy = false,
		priority = 900,
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("profile.ui.telescope").setup()
		end,
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		lazy = false,
		priority = 900,
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
		lazy = false,
		priority = 900,
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

	-- Mason & LSP: defer until first buffer
	{
		"williamboman/mason.nvim",
		event = { "BufReadPre", "BufNewFile" },
		priority = 500,
		config = false,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		priority = 499,
		dependencies = { "williamboman/mason.nvim" },
		config = false,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = { "BufReadPre", "BufNewFile" },
		priority = 498,
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		config = false,
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		priority = 400,
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"folke/neodev.nvim",
			"b0o/schemastore.nvim",
			"simrat39/rust-tools.nvim",
			"mfussenegger/nvim-jdtls",
			"p00f/clangd_extensions.nvim",
			{
				"jose-elias-alvarez/typescript.nvim",
				config = function()
					pcall(function()
						require("avante_lib").load()
						require("avante").setup({ provider = "claude", auto_suggestions_provider = "claude" })
					end)
				end,
			},
		},
		config = function()
			pcall(function() require("neodev").setup({}) end)
			require("profile.lsp.init").setup()
		end,
	},

	{ "folke/neodev.nvim",     ft = "lua",     lazy = true },

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

	-- Debugging ===
	{
		"mfussenegger/nvim-dap",
		cmd = { "DapContinue", "DapToggleBreakpoint", "DapStepOver", "DapStepInto", "DapStepOut", "DapRepl" },
		config = function()
			require("profile.dap").setup()
		end,
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
		config = false,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		lazy = true,
		dependencies = { "mfussenegger/nvim-dap" },
	},

	-- === Git ===
	{ "tpope/vim-fugitive",    cmd = "Git" },
	{ "kdheepak/lazygit.nvim", cmd = "LazyGit" },
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" }, -- Changed from VeryLazy to buffer events
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
				watch_gitdir = {
					interval = 2000,
					follow_files = true,
				},
				sign_priority = 6,
				update_debounce = 200, -- Increased debounce time
				status_formatter = nil,
				max_file_length = 40000,
				preview_config = {
					border = "rounded",
					style = "minimal",
					relative = "cursor",
				},
				word_diff = false,
				trouble = false,
			})
		end,
	},

	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
	},

	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
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
		event = { "BufReadPost", "BufNewFile" }, -- Changed from VeryLazy to buffer events
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
		config = function()
			require("profile.editing.comment").setup()
		end,
	},

	{
		"HiPhish/rainbow-delimiters.nvim",
		event = { "BufReadPost", "BufNewFile" }, -- Changed from VeryLazy to buffer events
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("profile.editing.rainbow").setup()
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("profile.ui.indent").setup()
		end,
	},

	{
		"echasnovski/mini.nvim",
		event = { "BufReadPost", "BufNewFile" },
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
		event = "LspAttach",
		config = function()
			require("illuminate").configure({
				delay = 500, -- Increased delay to reduce CPU usage
				large_file_cutoff = 2000,
				large_file_overrides = {
					providers = { "lsp" },
				},
				min_count_to_highlight = 2,
				filetypes_denylist = {
					"dirvish", "fugitive", "alpha", "NvimTree",
					"lazy", "neo-tree", "mason", "notify",
					"toggleterm", "TelescopePrompt",
				},
				modes_allowlist = { "n" },
			})
		end,
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
				trim_scope = "outer",
				throttle = true,
				patterns = {
					default = {
						"class", "function", "method", "for",
						"while", "if", "switch", "case",
					},
				},
			})
		end,
	},

	{ "stevearc/aerial.nvim", 
		cmd = "AerialToggle",
		lazy = false,
		config = function()
			require("profile.ui.aerial").setup()
		end,
	},
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
	{ "folke/flash.nvim",            
	lazy = false, 
	config = true,
},

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
		event = "VeryLazy",
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
		"folke/noice.nvim",
		lazy = false,
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		config = function()
			pcall(function() require("profile.ui.noice").setup() end)
		end,
	},

	{
		"brenoprata10/nvim-highlight-colors",
		lazy = false,
		config = function()
			require("nvim-highlight-colors").setup({
				render = "virtual",
				virtual_symbol = "██",
				virtual_symbol_prefix = "",
				virtual_symbol_suffix = "",
				virtual_symbol_position = "inline",
				enable_tailwind = false,
				hilight = false,
				virtual_only = true,
			})
		end,
	},

	{
		"uga-rosa/ccc.nvim",
		cmd = "CccPick",
		keys = { { "<leader>cp", "<cmd>CccPick<cr>", desc = "Pick color" } },
		config = function()
			require("ccc").setup({ highlighter = { auto_enable = false } })
		end,
	},

	-- === Sessions & Startup ===
	{ "folke/persistence.nvim",      cmd = "PersistenceLoad" },
	{
		"goolord/alpha-nvim",
		lazy = false,
		priority = 1000,
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
		ft = { "rust" },
		lazy = true,
	},
	{ "rust-lang/rust.vim",                ft = "rust", lazy = true },
	{
		"saecki/crates.nvim",
		ft = { "rust", "toml" },
		lazy = true,
	},
	-- Go
	{
		"ray-x/go.nvim",
		ft = "go",
		lazy = true,
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
				-- standard plugin option is `events`
				events = { "BufLeave", "FocusLost", "InsertLeave", "TextChanged" },
				write_all_buffers = false,
				debounce_delay = 2000,
				condition = function(buf)
					local fn = vim.fn

					-- Don't save for certain filetypes
					local ignore_ft = {
						"TelescopePrompt",
						"neo-tree",
						"dashboard",
						"alpha",
						"lazy",
						"mason",
						"lspinfo",
						"notify",
						"toggleterm",
						"help",
					}

					local ft = fn.getbufvar(buf, "&filetype")
					-- if filetype is in ignore list -> don't auto save
					for _, v in ipairs(ignore_ft) do
						if v == ft then
							return false
						end
					end

					-- Don't save if buffer isn't modifiable
					if not fn.getbufvar(buf, "&modifiable") then
						return false
					end

					-- Don't save if file size > 1MB (guard against unsaved/empty names)
					local name = fn.expand("%:p")
					if name ~= "" then
						local size = fn.getfsize(name)
						if size > 1024 * 1024 then
							return false
						end
					end

					return true
				end,
			})
		end,
	},

	-- === Surround ===
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
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
-- stylua: ignore end