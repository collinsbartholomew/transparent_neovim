---
-- Mojo tools integration: formatting, linting, test runner
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
    local conform_ok, conform = pcall(require, "conform")
    if conform_ok then
        -- Using centralized conform.lua configuration
    end

    -- Setup linting for Mojo
    local lint_ok, lint = pcall(require, "lint")
    if lint_ok then
        lint.linters_by_ft.mojo = { "mojo_check" }
    end

    -- Define mojo check linter
    lint.linters.mojo_check = {
        cmd = "mojo",
        args = { "check", "-" },
        stdin = true,
        stream = "stderr",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output, "\n")) do
                -- Pattern for mojo check errors
                local pattern = "stdin:(%d+):(%d+): (.+)"
                local ln, col, msg = string.match(line, pattern)
                if ln and col and msg then
                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = tonumber(ln) - 1,
                        col = tonumber(col) - 1,
                        severity = vim.diagnostic.severity.ERROR,
                        message = msg,
                        source = "mojo-check",
                    })
                end
            end
            return diagnostics
        end,
    }

    -- Create user commands for Mojo operations
    vim.api.nvim_create_user_command("MojoRun", function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("mojo %s", args) },
            "[Mojo Run]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("MojoBuild", function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("mojo build %s", args) },
            "[Mojo Build]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("MojoTest", function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("mojo test %s", args) },
            "[Mojo Test]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("MojoFormat", function()
        run_in_term(
            { "sh", "-c", "mojo format ." },
            "[Mojo Format]"
        )
    end, {})

    vim.api.nvim_create_user_command("MojoCheck", function()
        run_in_term(
            { "sh", "-c", "mojo check ." },
            "[Mojo Check]"
        )
    end, {})

    vim.api.nvim_create_user_command("MojoBench", function()
        run_in_term(
            { "sh", "-c", "mojo bench ." },
            "[Mojo Bench]"
        )
    end, {})

    vim.api.nvim_create_user_command("MojoDoc", function()
        run_in_term(
            { "sh", "-c", "mojo doc ." },
            "[Mojo Doc]"
        )
    end, {})

    vim.api.nvim_create_user_command("MojoPackage", function()
        run_in_term(
            { "sh", "-c", "mojo package ." },
            "[Mojo Package]"
        )
    end, {})

    vim.api.nvim_create_user_command("MojoMemory", function()
        local file = vim.fn.expand("%:p")
        run_in_term(
            { "sh", "-c", string.format("valgrind --tool=memcheck --leak-check=full %s", file) },
            "[Mojo Memory Check]"
        )
    end, {})

    vim.api.nvim_create_user_command("MojoSecurity", function()
        local file = vim.fn.expand("%:p")
        run_in_term(
            { "sh", "-c", string.format("checksec --file=%s", file) },
            "[Mojo Security Check]"
        )
    end, {})
end

return M