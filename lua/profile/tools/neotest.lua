-- Neotest configuration
-- Testing framework integration

local M = {}

function M.setup()
	local neotest_ok, neotest = pcall(require, "neotest")
	if not neotest_ok then
		vim.notify("neotest not available", vim.log.levels.WARN)
		return
	end

	local adapters = {}

	-- Python adapter
	local python_ok, python_adapter = pcall(require, "neotest-python")
	if python_ok then
		table.insert(adapters, python_adapter)
	end

	-- Go adapter
	local go_ok, go_adapter = pcall(require, "neotest-go")
	if go_ok then
		table.insert(adapters, go_adapter)
	end

	-- Java adapter
	local java_ok, java_adapter = pcall(require, "neotest-java")
	if java_ok then
		table.insert(adapters, java_adapter)
	end

	-- .NET adapter
	local dotnet_ok, dotnet_adapter = pcall(require, "neotest-dotnet")
	if dotnet_ok then
		table.insert(adapters, dotnet_adapter)
	end

	neotest.setup({
		adapters = adapters,
		status = { virtual_text = true },
		output = { open_on_run = true },
	})

	local wk_ok, which_key = pcall(require, "which-key")
	if wk_ok then
		which_key.register({
			t = {
				name = "Test",
				t = { "<cmd>Neotest run<cr>", "Run test" },
				s = { "<cmd>Neotest summary<cr>", "Test summary" },
				o = { "<cmd>Neotest output<cr>", "Test output" },
				n = { "<cmd>Neotest run nearest<cr>", "Run nearest test" },
				f = { "<cmd>Neotest run file<cr>", "Run file tests" },
				l = { "<cmd>Neotest run last<cr>", "Run last test" },
				d = { "<cmd>Neotest debug<cr>", "Debug test" },
			},
		}, { prefix = "<leader>" })
	end
end

return M
