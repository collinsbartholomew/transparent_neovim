-- added-by-agent: csharp-setup 20251020-153000
-- mason: none
-- manual: dotnet-sdk installation required

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
    -- Setup user commands
    vim.api.nvim_create_user_command('DotnetBuild', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("dotnet build %s", args) },
            "[Dotnet Build]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('DotnetTest', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("dotnet test %s", args) },
            "[Dotnet Test]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('DotnetRun', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("dotnet run %s", args) },
            "[Dotnet Run]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('DotnetFormat', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("dotnet format %s", args) },
            "[Dotnet Format]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('DotnetWatch', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("dotnet watch %s", args) },
            "[Dotnet Watch]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('DotnetPublish', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("dotnet publish %s", args) },
            "[Dotnet Publish]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('DotnetClean', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("dotnet clean %s", args) },
            "[Dotnet Clean]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('DotnetRestore', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("dotnet restore %s", args) },
            "[Dotnet Restore]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('DotnetAddPackage', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("dotnet add package %s", args) },
            "[Dotnet Add Package]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('DotnetRemovePackage', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("dotnet remove package %s", args) },
            "[Dotnet Remove Package]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('DotnetListPackages', function()
        run_in_term(
            { "sh", "-c", "dotnet list package" },
            "[Dotnet List Packages]"
        )
    end, {})

    vim.api.nvim_create_user_command('DotnetOutdated', function()
        run_in_term(
            { "sh", "-c", "dotnet list package --outdated" },
            "[Dotnet Outdated Packages]"
        )
    end, {})

    vim.api.nvim_create_user_command('DotnetVulnerabilities', function()
        run_in_term(
            { "sh", "-c", "dotnet list package --vulnerable" },
            "[Dotnet Vulnerable Packages]"
        )
    end, {})

    vim.api.nvim_create_user_command('DotnetTrace', function()
        run_in_term(
            { "sh", "-c", "dotnet trace collect --providers Microsoft-DotNETCore-SampleProfiler" },
            "[Dotnet Trace]"
        )
    end, {})

    vim.api.nvim_create_user_command('DotnetCounters', function()
        run_in_term(
            { "sh", "-c", "dotnet counters monitor --process-id $(pgrep dotnet)" },
            "[Dotnet Counters]"
        )
    end, {})

    vim.api.nvim_create_user_command('OmniReload', function()
        vim.cmd('LspRestart omnisharp')
    end, {})

    -- Setup neotest-dotnet if available
    local neotest_status_ok, neotest = pcall(require, "neotest")
    if neotest_status_ok then
        neotest.setup({
            adapters = {
                require("neotest-dotnet")({
                    dap = { justMyCode = false },
                }),
            },
        })
    end

    -- Setup conform.nvim integration if available
    local conform_ok, conform = pcall(require, "conform")
    if conform_ok then
        -- We don't add to formatters_by_ft here because we want to keep it optional
        -- User can add this to their conform setup:
        -- formatters_by_ft = {
        --   cs = { "dotnet_format" },
        -- }
    end
end

return M