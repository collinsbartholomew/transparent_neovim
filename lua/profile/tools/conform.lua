local M = {}

function M.setup()
	local conform = require("conform")

	-- Configure formatters with language-specific indentation settings
	conform.setup({
		formatters_by_ft = {
			-- Scripting & Config
			lua = { "stylua" },
			python = { "black" },
			sh = { "shfmt" },
			bash = { "shfmt" },

			-- Web Development
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			jsx = { "prettier" },
			tsx = { "prettier" },
			html = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			svelte = { "prettier" },
			vue = { "prettier" },

			-- Data & Config
			json = { "prettier" },
			jsonc = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },
			nix = { "nixpkgs-fmt" },
			zig = { "zigfmt" },

			-- Systems Languages
			rust = { "rustfmt" },
			go = { "gofmt" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			java = { "google-java-format" },

			-- Dynamic Languages
			ruby = { "rubocop" },
			php = { "php-cs-fixer" },

			-- Data Languages
			toml = { "taplo" },
			sql = { "sqlfluff" },
			xml = { "prettier" },
		},
		formatters = {
			-- Prettier: Optimized for single-line preference
			prettier = {
				extra_args = function()
					local ft = vim.bo.filetype
					local base_args = {
						"--tab-width",
						"4",
						"--use-tabs",
						"true",
						"--print-width",
						"120",
						"--prose-wrap",
						"never",
						"--single-quote",
						"true",
						"--trailing-comma",
						"es5",
					}
					if vim.tbl_contains({ "html", "xml", "jsx", "tsx" }, ft) then
						return vim.list_extend(base_args, { "--jsx-single-quote", "true" })
					end
					return base_args
				end,
			},
			-- Stylua: Optimized for tabs and single-line
			stylua = {
				extra_args = {
					"--indent-type",
					"Tabs",
					"--line-endings",
					"Unix",
					"--quote-style",
					"AutoPreferDouble",
					"--call-parentheses",
					"None",
				},
			},
			-- Clang-format: Tabs and optimized
			["clang-format"] = {
				extra_args = {
					"-style={ IndentWidth: 4, UseTab: ForIndentation, ColumnLimit: 120, AllowShortFunctionsOnASingleLine: All, AllowShortIfStatementsOnASingleLine: true }",
				},
			},
			-- Shfmt: Tabs for shell
			shfmt = {
				extra_args = { "-i", "0", "-bn", "-ci" },
			},
			-- Black: Optimized line length
			black = {
				extra_args = { "--line-length", "120", "--skip-string-normalization" },
			},
			-- Google Java Format: Optimized
			["google-java-format"] = {
				extra_args = { "--aosp", "--skip-sorting-imports" },
			},
			-- Rubocop: Ruby formatter/linter
			rubocop = {
				extra_args = { "-A", "--format", "quiet" },
			},
			-- PHP-CS-Fixer: Optimized
			["php-cs-fixer"] = {
				extra_args = { "--rules=@PSR12,no_trailing_whitespace,single_line_after_imports" },
			},
			-- SQLFluff: Optimized
			sqlfluff = {
				extra_args = { "--dialect", "ansi", "--exclude-rules", "L016" },
			},
			-- Rustfmt: Optimized
			rustfmt = {
				extra_args = { "--config", "hard_tabs=true,max_width=120" },
			},
			-- Gofmt: Use tabs
			gofmt = {
				extra_args = { "-s" },
			},
		},
		default_format_opts = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
	})

	vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

	-- Setup conform keymaps
	local map = vim.keymap.set
	map("n", "<leader>fm", function()
		conform.format({ async = true, lsp_fallback = true })
	end, { desc = "Format buffer" })

	map("v", "<leader>fm", function()
		conform.format({ async = true, lsp_fallback = true })
	end, { desc = "Format selection" })
end

return M
