-- Clangd Extensions configuration
-- Enhanced functionality for clangd language server

local M = {}

function M.setup()
	local clangd_extensions = require("clangd_extensions")

	clangd_extensions.setup({
		ast = {
			role_icons = {
				type = "",
				declaration = "",
				expression = "",
				specifier = "",
				statement = "",
				["template argument"] = "",
			},
			kind_icons = {
				Compound = "",
				Recovery = "",
				TranslationUnit = "",
				PackExpansion = "",
				TemplateTypeParm = "",
				TemplateTemplateParm = "",
				TemplateParamObject = "",
			},
			highlights = {
				detail = "Comment",
			},
		},
		memory_usage = {
			border = "rounded",
		},
		symbol_info = {
			border = "rounded",
		},
		diagnostics_cycle_next = "<M-]>",
		diagnostics_cycle_prev = "<M-[>",
		header_extension_split = "/h",
		modular_config = true,
		project_config = {
			lsp = {
				path_offset = 1,
				background_index = true,
				clang_tidy = {
					enabled = true,
				},
			},
		},
	})

	-- Keybindings for Clangd Extensions
	local wk_ok, which_key = pcall(require, "which-key")
	if wk_ok then
		which_key.register({
			c = {
				name = "Clangd",
				e = { "<cmd>ClangdSwitchSourceHeader<cr>", "Switch header/source" },
				a = { "<cmd>ClangdAST<cr>", "Show AST" },
				h = { "<cmd>ClangdTypeHierarchy<cr>", "Show type hierarchy" },
				m = { "<cmd>ClangdMemoryUsage<cr>", "Memory usage" },
				s = { "<cmd>ClangdSymbolInfo<cr>", "Symbol info" },
			},
		}, { prefix = "<leader>" })
	end

	-- Additional keybindings
	local opts = { noremap = true, silent = true }
	vim.keymap.set("n", "<leader>cc", "<cmd>ClangdSwitchSourceHeader<cr>", vim.tbl_extend("force", opts, { desc = "Switch header/source" }))
	vim.keymap.set("n", "<leader>ca", "<cmd>ClangdAST<cr>", vim.tbl_extend("force", opts, { desc = "Show AST" }))
end

return M
