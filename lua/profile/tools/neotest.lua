-- lua/profile/neotest.lua
-- Testing framework integration
-- Centralized config for all language adapters
local M = {}

local function get_python_executable()
    if vim.g.python_executable and vim.g.python_executable ~= "" then
        return vim.g.python_executable
    end
    local py = vim.fn.exepath("python3")
    if py ~= "" then
        return py
    end
    py = vim.fn.exepath("python")
    if py ~= "" then
        return py
    end
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
        table.insert(
            adapters,
            python_adapter({
                dap = { justMyCode = false },
                args = { "-v", "-s" },
                runner = "pytest",
                python = get_python_executable,
            })
        )
    end
    -- Go adapter
    local go_ok, go_adapter = pcall(require, "neotest-go")
    if go_ok then
        table.insert(
            adapters,
            go_adapter({
                dap = { justMyCode = false },
                args = { "-v", "-race", "-count=1", "-timeout=60s" },
            })
        )
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
        table.insert(
            adapters,
            phpunit_adapter({
                phpunit_cmd = function()
                    if vim.fn.filereadable("vendor/bin/phpunit") == 1 then
                        return vim.fn.getcwd() .. "/vendor/bin/phpunit"
                    end
                    return "phpunit"
                end,
            })
        )
    end
    -- Rust adapter
    local rust_ok, rust_adapter = pcall(require, "neotest-rust")
    if rust_ok then
        table.insert(
            adapters,
            rust_adapter({
                args = { "--no-capture" },
            })
        )
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
        table.insert(
            adapters,
            jest_adapter({
                jestConfigFile = "jest.config.js",
                cwd = function()
                    return vim.fn.getcwd()
                end,
            })
        )
    end
    -- Vitest adapter
    local vitest_ok, vitest_adapter = pcall(require, "neotest-vitest")
    if vitest_ok then
        table.insert(adapters, vitest_adapter())
    end
    neotest.setup({
        adapters = adapters,
        status = { virtual_text = true, signs = true },
        output = { open_on_run = true },
        quickfix = {
            enabled = true,
            open = function()
                vim.cmd("Trouble qflist")
            end,
        },
        diagnostic = {
            enabled = true,
        },
        floating = {
            border = "rounded",
            max_height = 0.6,
            max_width = 0.6,
        },
        summary = {
            enabled = true,
            expand_errors = true,
            follow = true,
            animated = true,
        },
    })
    local wk_ok, which_key = pcall(require, "which-key")
    if wk_ok then
        which_key.add({
            { "<leader>t", group = "Test" },
            {
                "<leader>tt",
                function()
                    neotest.run.run()
                end,
                desc = "Run nearest test",
            },
            {
                "<leader>tf",
                function()
                    neotest.run.run(vim.fn.expand("%"))
                end,
                desc = "Run current file",
            },
            {
                "<leader>tp",
                function()
                    neotest.run.run(vim.loop.cwd())
                end,
                desc = "Run project tests",
            },
            {
                "<leader>tl",
                function()
                    neotest.run.run_last()
                end,
                desc = "Rerun last test",
            },
            {
                "<leader>td",
                function()
                    neotest.run.run({ strategy = "dap" })
                end,
                desc = "Debug nearest test",
            },
            {
                "<leader>tD",
                function()
                    neotest.run.run({ vim.fn.expand("%"), strategy = "dap" })
                end,
                desc = "Debug file tests",
            },
            {
                "<leader>ts",
                function()
                    neotest.summary.toggle()
                end,
                desc = "Toggle summary panel",
            },
            {
                "<leader>to",
                function()
                    neotest.output_panel.toggle()
                end,
                desc = "Toggle output panel",
            },
            {
                "<leader>tO",
                function()
                    neotest.output.open({ enter = true, short = false })
                end,
                desc = "Open test output",
            },
            {
                "<leader>tx",
                function()
                    neotest.run.stop()
                end,
                desc = "Stop test run",
            },
            {
                "<leader>tw",
                function()
                    neotest.watch.toggle(vim.fn.expand("%"))
                end,
                desc = "Watch file",
            },
            {
                "<leader>tW",
                function()
                    neotest.watch.toggle(vim.loop.cwd())
                end,
                desc = "Watch all tests",
            },
            {
                "<leader>tj",
                function()
                    neotest.jump.next({ status = "failed" })
                end,
                desc = "Jump to next failed",
            },
            {
                "<leader>tk",
                function()
                    neotest.jump.prev({ status = "failed" })
                end,
                desc = "Jump to prev failed",
            },
        })
    end
end

return M
