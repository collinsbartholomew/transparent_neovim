---
-- Go tools integration: formatting, linting, test runner
-- Formatters: gofumpt, goimports (Mason)
-- Linters: staticcheck, golangci-lint (Mason/manual)
-- Test runner: neotest-go
local M = {}

-- Helper function to run commands in a terminal buffer
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
    -- Using centralized conform.lua configuration
    
    -- Neotest-go for test running
    local neotest_status_ok, neotest = pcall(require, "neotest")
    if neotest_status_ok then
        neotest.setup({
            adapters = {
                require("neotest-go")({
                    dap = { justMyCode = false },
                    experimental = {
                        test_table = true,
                    },
                    args = { "-v", "-race", "-count=1", "-timeout=60s" },
                }),
            },
        })
    end

    -- Create user commands for Go operations
    vim.api.nvim_create_user_command("GoBuild", function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("go build %s", args) },
            "[Go Build]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("GoRun", function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("go run . %s", args) },
            "[Go Run]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("GoTest", function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("go test ./... %s", args) },
            "[Go Test]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("GoBench", function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("go test -bench=. %s", args) },
            "[Go Bench]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("GoCoverage", function()
        run_in_term(
            { "sh", "-c", "go test -coverprofile=coverage.out && go tool cover -html=coverage.out" },
            "[Go Coverage]"
        )
    end, {})

    vim.api.nvim_create_user_command("GoVet", function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("go vet %s", args) },
            "[Go Vet]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("GoModTidy", function()
        run_in_term(
            { "sh", "-c", "go mod tidy" },
            "[Go Mod Tidy]"
        )
    end, {})

    vim.api.nvim_create_user_command("GoGenerate", function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("go generate %s", args) },
            "[Go Generate]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("GoLint", function()
        run_in_term(
            { "sh", "-c", "golangci-lint run" },
            "[Go Lint]"
        )
    end, {})

    vim.api.nvim_create_user_command("GoDoc", function()
        local word = vim.fn.expand("<cword>")
        run_in_term(
            { "sh", "-c", string.format("go doc %s", word) },
            "[Go Doc]"
        )
    end, {})

    vim.api.nvim_create_user_command("GoPprof", function()
        run_in_term(
            { "sh", "-c", "go tool pprof http://localhost:6060/debug/pprof/profile" },
            "[Go Pprof]"
        )
    end, {})

    vim.api.nvim_create_user_command("GoSec", function()
        run_in_term(
            { "sh", "-c", "gosec ./..." },
            "[Go Security Scan]"
        )
    end, {})

    vim.api.nvim_create_user_command("GoRace", function()
        run_in_term(
            { "sh", "-c", "go run -race ." },
            "[Go Race Detector]"
        )
    end, {})

    -- Auto-run go mod tidy on save if go.mod exists
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "go.mod",
        callback = function()
            vim.fn.jobstart({"go", "mod", "tidy"}, {
                on_exit = function(_, code)
                    if code == 0 then
                        vim.notify("go mod tidy completed successfully", vim.log.levels.INFO)
                    else
                        vim.notify("go mod tidy failed", vim.log.levels.WARN)
                    end
                end
            })
        end,
    })
end

return M