-- Neotest configuration
-- Testing framework integration
-- Centralized config for all language adapters

local M = {}

local function get_python_executable()
    if vim.g.python_executable and vim.g.python_executable ~= "" then
        return vim.g.python_executable
    end
    local py = vim.fn.exepath("python3")
    if py ~= "" then return py end
    py = vim.fn.exepath("python")
    if py ~= "" then return py end
    return "python"
end

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
		table.insert(adapters, python_adapter({
			dap = { justMyCode = false },
			args = { "-v", "-s" },
			runner = "pytest",
			python = get_python_executable,
		}))
	end

	-- Go adapter
	local go_ok, go_adapter = pcall(require, "neotest-go")
	if go_ok then
		table.insert(adapters, go_adapter({
			dap = { justMyCode = false },
			experimental = {
				test_table = true,
			},
			args = { "-v", "-race", "-count=1", "-timeout=60s" },
			env = {
				GO111MODULE = "on",
				CGO_ENABLED = "1",
			},
			extras = { "-p=1" },
		}))
	end

	-- Java adapter
	local java_ok, java_adapter = pcall(require, "neotest-java")
	if java_ok then
		table.insert(adapters, java_adapter({}))
	end

	-- .NET adapter
	local dotnet_ok, dotnet_adapter = pcall(require, "neotest-dotnet")
	if dotnet_ok then
		table.insert(adapters, dotnet_adapter({ dap = { justMyCode = false } }))
	end

	-- PHP adapter
	local phpunit_ok, phpunit_adapter = pcall(require, "neotest-phpunit")
	if phpunit_ok then
		table.insert(adapters, phpunit_adapter({
			env = {
				PHP_CS_FIXER_IGNORE_ENV = "1"
			},
			phpunit_cmd = function()
				local composer_ok = vim.fn.filereadable("vendor/bin/phpunit") == 1
				if composer_ok then
					return vim.fn.getcwd() .. "/vendor/bin/phpunit"
				end
				return "phpunit"
			end,
		}))
	end

	-- Rust adapter
	local rust_ok, rust_adapter = pcall(require, "neotest-rust")
	if rust_ok then
		table.insert(adapters, rust_adapter({
			dap = { justMyCode = false },
			args = { "--no-capture" },
			frameworks = { "test", "rstest" },
		}))
	end

	-- C++ Catch2 adapter
	local catch2_ok, catch2_adapter = pcall(require, "neotest-catch2")
	if catch2_ok then
		table.insert(adapters, catch2_adapter())
	end

	-- C++ GoogleTest adapter
	local gtest_ok, gtest_adapter = pcall(require, "neotest-gtest")
	if gtest_ok then
		table.insert(adapters, gtest_adapter())
	end

	-- Shell/Bash adapter
	local bash_ok, bash_adapter = pcall(require, "neotest-bats")
	if bash_ok then
		table.insert(adapters, bash_adapter())
	end

	-- Jest adapter
	local jest_ok, jest_adapter = pcall(require, "neotest-jest")
	if jest_ok then
		table.insert(adapters, jest_adapter({
			jest_config_file = "jest.config.js",
			env = { CI = true },
			cwd = function()
				return vim.fn.getcwd()
			end,
		}))
	end

	-- Vitest adapter
	local vitest_ok, vitest_adapter = pcall(require, "neotest-vitest")
	if vitest_ok then
		table.insert(adapters, vitest_adapter())
	end

	neotest.setup({
		adapters = adapters,
		status = { virtual_text = true },
		output = { open_on_run = true },
		quickfix = {
			open = function()
				vim.cmd('Trouble quickfix')
			end,
		},
		consumers = {
			trouble = require("neotest").consumers.trouble,
		},
		diagnostic = {
			enabled = true,
		},
		floating = {
			border = "rounded",
			max_height = 0.6,
			max_width = 0.6,
		},
	})

	local wk_ok, which_key = pcall(require, "which-key")
	if wk_ok then
		which_key.register({
			t = {
				name = "Test",
				-- Basic test execution
				t = { function() neotest.run.run() end, "Run nearest test" },
				f = { function() neotest.run.run(vim.fn.expand("%")) end, "Run current file" },
				p = { function() neotest.run.run(vim.fn.getcwd()) end, "Run project tests" },
				l = { function() neotest.run.run_last() end, "Rerun last test" },
				-- Debug support
				d = { function() neotest.run.run({ strategy = "dap" }) end, "Debug nearest test" },
				D = { function() neotest.run.run({ file = vim.fn.expand("%"), strategy = "dap" }) end, "Debug file tests" },
				-- UI panels and output
				s = { function() neotest.summary.toggle() end, "Toggle summary panel" },
				o = { function() neotest.output_panel.toggle() end, "Toggle output panel" },
				O = { function() neotest.output.open({ enter = true, auto_close = true }) end, "Open test output" },
				-- Advanced features
				x = { function() neotest.run.stop() end, "Stop test run" },
				w = { function() neotest.watch.toggle(vim.fn.expand("%")) end, "Watch file" },
				W = { function() neotest.watch.toggle(vim.fn.getcwd()) end, "Watch all tests" },
				-- Navigation
				j = { function() neotest.jump.next({ status = "failed" }) end, "Jump to next failed" },
				k = { function() neotest.jump.prev({ status = "failed" }) end, "Jump to prev failed" },
			},
		}, { prefix = "<leader>" })
	end
end

return M
