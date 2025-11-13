-- stylua: ignore start
-- lazy.nvim plugin specs (reviewed & adjusted lazy/event settings)
-- 1) Keep core runtime plugins and themes loaded eagerly (lazy = false) so statusline, icons,
--    LSP, mason, treesitter, and notifications are available early.
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
			"folke/neodev.nvim",
		},
		config = function()
			-- Setup Neodev for better Lua devicings (Neovim config)
			require("neodev").setup({})
		end,
	},

	{ "folke/neodev.nvim",     ft = "lua",     lazy = true, config = true },

	-- === AI & Coding Assistance ===
	{
		"yetone/avante.nvim",
		cmd = { "AvanteAsk", "AvanteChat", "AvanteToggle" },
		build = "make",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			-- avante default libraries then provider config
			pcall(function()
				require("avante_lib").load()
				require("avante").setup({ provider = "claude", auto_suggestions_provider = "claude" })
			end)
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
				watch_gitdir = {
					interval = 2000,  -- Reduce update frequency
					follow_files = true,
				},
				sign_priority = 6,
				update_debounce = 200,  -- Debounce sign updates
				status_formatter = nil,  -- Disable status formatter for better performance
				max_file_length = 40000,  -- Don't process files larger than 40k lines
				preview_config = {
					border = "rounded",
					style = "minimal",
					relative = "cursor",
				},
				word_diff = false,  -- Disable word diff for better performance
				trouble = false,    -- Disable trouble integration if not needed
				-- yadm configuration removed as it's not a valid gitsigns option
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
				delay = 200,
				large_file_cutoff = 1000,  -- Don't illuminate files with more than 1000 lines
				large_file_overrides = {
					providers = { "lsp" },  -- Only use LSP for large files
				},
				min_count_to_highlight = 2,  -- Only highlight if word appears at least twice
				filetypes_denylist = {
					"dirvish",
					"fugitive",
					"alpha",
					"NvimTree",
					"lazy",
					"neo-tree",
					"mason",
					"notify",
					"toggleterm",
					"TelescopePrompt",
				},
				modes_allowlist = { "n" },  -- Only illuminate in normal mode
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
				trim_scope = "outer",  -- Reduce context noise
				throttle = true,       -- Enable throttling for better performance
				patterns = {           -- Specify patterns for better context
					default = {
						"class",
						"function",
						"method",
						"for",
						"while",
						"if",
						"switch",
						"case",
					},
				},
			})
			
			-- Set highlight groups in a protected call
			pcall(function()
				vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "NONE" })
				vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#555555", bg = "NONE" })
				vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = "#444444", bg = "NONE" })
			end)
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
		ft = { "rust" },
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
-- stylua: ignore end
