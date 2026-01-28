return {
	-- Themes
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
		config = function()
			require("profile.ui.theme").setup()
		end,
	},
	{
		"olimorris/onedarkpro.nvim",
		lazy = true,
		priority = 1000,
	},

	-- UI
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("profile.ui.statusline").setup()
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			require("profile.ui.telescope").setup()
		end,
	},

	-- File Explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},
			window = {
				mappings = {
					["<space>"] = "none",
				},
			},
		},
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("profile.lsp.init").setup()
		end,
	},

	-- Completion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
		},
		config = function()
			require("profile.completion.init").setup()
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua", "vim", "vimdoc", "python", "javascript", "typescript", "html", "css",
					"json", "yaml", "markdown", "bash", "c", "cpp", "rust", "go",
				},
				highlight = { 
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = "<C-s>",
						node_decremental = "<M-space>",
					},
				},
			})
		end,
	},

	-- Tools
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		config = function()
			require("profile.tools.conform").setup()
		end,
	},

	{
		"mfussenegger/nvim-lint",
		event = "BufWritePost",
		config = function()
			require("profile.tools.lint").setup()
		end,
	},

	-- Git
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "│" },
			},
			current_line_blame = false,
			attach_to_untracked = true,
		},
	},

	-- Diagnostics
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {
			use_diagnostic_signs = true,
		},
	},

	-- Essential mini plugins
	{ "echasnovski/mini.ai", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.pairs", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.surround", event = "VeryLazy", opts = {} },

	-- Language specific
	{ "mrcjkb/rustaceanvim", ft = "rust" },
}