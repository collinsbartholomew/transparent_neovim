local M = {}

local servers = {
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
			},
		},
	},
	pyright = {},
	ts_ls = {},
	gopls = {},
	clangd = {},
	rust_analyzer = {},
	jsonls = {},
	yamlls = {},
	bashls = {},
	html = {},
	cssls = {},
}

function M.setup()
	require("mason").setup()

	local tools = {
		"stylua", "black", "prettier", "shfmt", "clang-format",
		"ruff", "shellcheck", "eslint_d", "luacheck", "golangci-lint", "cppcheck",
	}

	require("mason-tool-installer").setup({
		ensure_installed = tools,
		auto_update = false,
		run_on_start = false,
	})

	local capabilities = require("cmp_nvim_lsp").default_capabilities()

	local on_attach = function(client, bufnr)
		local nmap = function(keys, func)
			vim.keymap.set("n", keys, func, { buffer = bufnr })
		end

		nmap("gd", vim.lsp.buf.definition)
		nmap("gr", require("telescope.builtin").lsp_references)
		nmap("K", vim.lsp.buf.hover)
		nmap("<leader>rn", vim.lsp.buf.rename)
		nmap("<leader>ca", vim.lsp.buf.code_action)
	end

	require("mason-lspconfig").setup({
		ensure_installed = vim.tbl_keys(servers),
		handlers = {
			function(server_name)
				if server_name == "rust_analyzer" then return end
				
				require("lspconfig")[server_name].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					settings = servers[server_name].settings or {},
				})
			end,
		},
	})
end

return M