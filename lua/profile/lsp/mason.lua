local M = {}

function M.setup()
	local mason_ok, mason = pcall(require, "mason")
	if not mason_ok then
		vim.notify("Mason not available", vim.log.levels.ERROR)
		return
	end

	mason.setup({
		ui = {
			border = "single",
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	})

	local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
	if mason_lspconfig_ok then
		mason_lspconfig.setup({
			automatic_installation = true,
		})
	else
		vim.notify("mason-lspconfig not available", vim.log.levels.WARN)
	end

	local mason_tool_ok, mason_tool = pcall(require, "mason-tool-installer")
	if mason_tool_ok then
		mason_tool.setup({
			ensure_installed = {
				"stylua",
				"prettier",
				"black",
				"clang-format",
				"rustfmt",
				"shfmt",
				"google-java-format",
				"phpcbf",
				"asmfmt",
				"luacheck",
				"eslint_d",
				"ruff",
				"phpstan",
			},
			auto_update = true,
			run_on_start = true,
		})
	else
		vim.notify("mason-tool-installer not available", vim.log.levels.WARN)
	end

	local mason_dap_ok, mason_dap = pcall(require, "mason-nvim-dap")
	if mason_dap_ok then
		mason_dap.setup({
			ensure_installed = {
				"codelldb",
				"netcoredbg",
				"dart-debug",
				"js-debug-adapter",
				"debugpy",
				"php-debug",
			},
			automatic_installation = true,
			handlers = {
				function(config)
					require("mason-nvim-dap").default_setup(config)
				end,
			},
		})
	else
		vim.notify("mason-nvim-dap not available", vim.log.levels.WARN)
	end
end

return M
