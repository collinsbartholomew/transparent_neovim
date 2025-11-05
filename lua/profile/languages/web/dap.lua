-- added-by-agent: web-setup 20251020-173000
-- mason: js-debug-adapter
-- manual: node.js installation required

local M = {}

function M.setup()
	local dap_status, dap = pcall(require, "dap")
	if not dap_status then
		vim.notify("nvim-dap not available for web debug setup", vim.log.levels.WARN)
		return
	end

	local dapui_status, dapui = pcall(require, "dapui")
	if dapui_status then
		-- DAP UI setup is handled in main dap setup
	end

	-- Setup enhanced JavaScript/TypeScript debug configurations
	dap.configurations.javascript = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch Node.js",
			program = "${workspaceFolder}/index.js",
			cwd = "${workspaceFolder}",
		},
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
		},
		{
			type = "pwa-chrome",
			request = "launch",
			name = "Launch Chrome",
			url = "http://localhost:3000",
			webRoot = "${workspaceFolder}",
		},
	}

	dap.configurations.typescript = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch Node.js",
			program = "${workspaceFolder}/index.ts",
			cwd = "${workspaceFolder}",
			runtimeArgs = { "--loader", "ts-node/esm" },
			skipFiles = { "<node_internals>/**", "node_modules/**" },
		},
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
		},
		{
			type = "pwa-chrome",
			request = "launch",
			name = "Launch Chrome against localhost",
			url = "http://localhost:3000",
			webRoot = "${workspaceFolder}",
		},
	}

	dap.configurations.javascriptreact = {
		{
			type = "pwa-chrome",
			request = "launch",
			name = "Launch Chrome against localhost",
			url = "http://localhost:3000",
			webRoot = "${workspaceFolder}",
		},
		{
			type = "pwa-node",
			request = "launch",
			name = "Debug React App",
			program = "${workspaceFolder}/node_modules/react-scripts/scripts/start.js",
			cwd = "${workspaceFolder}",
		},
	}

	dap.configurations.typescriptreact = {
		{
			type = "pwa-chrome",
			request = "launch",
			name = "Launch Chrome against localhost",
			url = "http://localhost:3000",
			webRoot = "${workspaceFolder}",
		},
		{
			type = "pwa-node",
			request = "launch",
			name = "Debug React App",
			program = "${workspaceFolder}/node_modules/react-scripts/scripts/start.js",
			cwd = "${workspaceFolder}",
		},
	}

	-- Keymaps
	vim.keymap.set("n", "<F5>", ":DapContinue<CR>", { silent = true })
	vim.keymap.set("n", "<F10>", ":DapStepOver<CR>", { silent = true })
	vim.keymap.set("n", "<F11>", ":DapStepInto<CR>", { silent = true })
	vim.keymap.set("n", "<F12>", ":DapStepOut<CR>", { silent = true })
	vim.keymap.set("n", "<leader>db", ":DapToggleBreakpoint<CR>", { silent = true })
	vim.keymap.set("n", "<leader>dB", ":DapSetBreakpoint<CR>", { silent = true })
	vim.keymap.set("n", "<leader>dc", ":DapContinue<CR>", { silent = true })
	vim.keymap.set("n", "<leader>di", ":DapStepInto<CR>", { silent = true })
	vim.keymap.set("n", "<leader>do", ":DapStepOver<CR>", { silent = true })
	vim.keymap.set("n", "<leader>dO", ":DapStepOut<CR>", { silent = true })
	vim.keymap.set("n", "<leader>dr", ":DapToggleRepl<CR>", { silent = true })
	vim.keymap.set("n", "<leader>dl", ":DapShowLog<CR>", { silent = true })

	if dapui_status then
		vim.keymap.set("n", "<leader>du", ":DapUiToggle<CR>", { silent = true })
	end
end

return M