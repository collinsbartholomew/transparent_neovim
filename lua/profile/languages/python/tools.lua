---
-- Python tools integration: formatting, linting, test runner
-- Formatters: black, ruff, isort (Mason/pipx)
-- Linters: ruff (Mason/pipx)
-- Test runner: neotest-python
local M = {}

-- Helper function to run commands in aterminal buffer
local function run_in_term(cmd, title)
    vim.cmd("botright new")
    local buf = vim.api.nvim_get_current_buf()
    local chan = vim.api.nvim_open_term(buf, {})
    vim.api.nvim_buf_set_name(buf, title)
    vim.fn.jobstart(cmd, {
on_stdout = function(_, data)
            data = table.concat(data, "\n")
            vim.api.nvim_chan_send(chan, data)
        end,
        on_stderr = function(_, data)
            data = table.concat(data, "\n")
            vim.api.nvim_chan_send(chan, data)
        end,
       stdout_buffered = true,
        stderr_buffered = true,
    })
end

function M.setup()
    -- Conform.nvim for formatting
    local conform_ok, conform = pcall(require, "conform")
    if conform_ok then
        -- Using centralized conform.lua configuration
    end

    -- Setup linting for Python
    local lint_ok, lint = pcall(require, "lint")
    if lint_ok then
        lint.linters_by_ft.python = { "ruff" }
    end

    -- Neotest-python for test running
    local neotest_ok, neotest = pcall(require, "neotest")
    local neotest_python_ok = pcall(require, "neotest-python")

    if neotest_ok and neotest_python_ok then
        neotest.setup({
            adapters = {
                require("neotest-python")({
                    dap = { justMyCode =false },
                    args = { "-v", "-s" },
                    runner = "pytest",
                    python = function()
                        local venv_path = os.getenv("VIRTUAL_ENV")
                        if venv_path then
                            return venv_path .. "/bin/python"
                        else
                            return "python"
                        end
                   end,
                }),
            },
        })
    end

    -- Create user commands for Python operations
    vim.api.nvim_create_user_command("PythonRun", function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("python %s", args)},
            "[Python Run]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("PythonTest", function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("python -m pytest %s", args) },
"[Python Test]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("PythonCoverage", function()
        run_in_term(
            { "sh", "-c", "coverage run -m pytest && coverage report && coverage html" },
            "[Python Coverage]"
        )
    end, {})

    vim.api.nvim_create_user_command("PythonFormat", function()
        run_in_term(
            { "sh", "-c", "black ." },
            "[Python Format]"
        )
    end, {})

    vim.api.nvim_create_user_command("PythonLint", function()
        run_in_term(
{ "sh", "-c", "ruff check ." },
            "[Python Lint]"
        )
    end, {})

    vim.api.nvim_create_user_command("PythonSecurity", function()
        run_in_term(
            { "sh", "-c", "bandit -r ." },
            "[Python Security]"
        )
    end, {})

    vim.api.nvim_create_user_command("PythonMemory", function()
        local file = vim.fn.expand("%:p")
        run_in_term(
            { "sh", "-c", string.format("python -m memory_profiler %s", file) },
            "[Python Memory]"
        )
    end, {})

    vim.api.nvim_create_user_command("PythonProfile", function()
        local file = vim.fn.expand("%:p")
        run_in_term(
            { "sh", "-c", string.format("python -m cProfile -o profile.out %s && snakeviz profile.out", file) },
            "[Python Profile]"
        )
    end, {})

    vim.api.nvim_create_user_command("PythonVenv", function()
        run_in_term(
            { "sh", "-c", "python -m venv .venv && source .venv/bin/activate && pip install --upgrade pip" },
            "[Python Virtual Environment]"
        )
    end, {})

    vim.api.nvim_create_user_command("PythonRequirements", function()
        run_in_term(
            { "sh", "-c", "pip freeze > requirements.txt" },
            "[Python Requirements]"
        )
    end, {})

   vim.api.nvim_create_user_command("PythonInstall", function()
        run_in_term(
            { "sh", "-c", "pip install -r requirements.txt" },
            "[Python Install]"
        )
    end, {})

    -- Add new command for pip-audit
    vim.api.nvim_create_user_command("PythonAudit", function()
        run_in_term(
            { "sh", "-c", "pip-audit requirements.txt" },
            "[Python Audit]"
        )
    end, {})

    -- Add new command for dependencyvisualization
    vim.api.nvim_create_user_command("PythonDeps", function()
        run_in_term(
            { "sh", "-c", "pipdeptree > dependencies.txt && echo 'Dependencies saved to dependencies.txt'" },
            "[Python Dependencies]"
        )
    end, {})
end

return M