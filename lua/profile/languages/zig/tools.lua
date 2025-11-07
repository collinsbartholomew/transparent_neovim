-- added-by-agent: zig-setup 20251020
-- mason: none
-- manual: ensure zig is installed and in PATH

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
    if vim.fn.executable("zig") == 0 then
        vim.notify("Zig not found in PATH. Install from https://ziglang.org/download/", vim.log.levels.WARN)
        return
    end
    
    -- Create user commands for Zig operations
    vim.api.nvim_create_user_command('ZigBuild', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("zig build %s", args) },
            "[Zig Build]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('ZigRun', function(opts)
        local file = vim.fn.expand('%:p')
        if vim.bo.filetype ~= 'zig' then
            vim.notify('Not a Zig file', vim.log.levels.ERROR)
            return
        end
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("zig run %s %s", file, args) },
            "[Zig Run]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('ZigTest', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("zig test %s", args) },
            "[Zig Test]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('ZigFmt', function(opts)
        if vim.bo.filetype ~= 'zig' then
            vim.notify('Not a Zig file', vim.log.levels.ERROR)
            return
        end
        -- Try LSP formatting first
        vim.lsp.buf.format({
            timeout_ms = 2000,
            filter = function(client)
                return client.name == "zls"
            end
        })
    end, {})

    vim.api.nvim_create_user_command('ZigCheck', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("zig check %s", args) },
            "[Zig Check]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('ZigDoc', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("zig build doc %s && xdg-open docs/index.html", args) },
            "[Zig Doc]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('ZigBench', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("zig build bench %s", args) },
            "[Zig Bench]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('ZigCoverage', function()
        run_in_term(
            { "sh", "-c", "zig build test --cover && zig build report-coverage" },
            "[Zig Coverage]"
        )
    end, {})

    vim.api.nvim_create_user_command('ZigSanitize', function(opts)
        local file = vim.fn.expand('%:p')
        if vim.bo.filetype ~= 'zig' then
            vim.notify('Not a Zig file', vim.log.levels.ERROR)
            return
        end
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("zig build-exe -fsanitize=address %s %s && ./$(basename %s .zig)", file, args, file) },
            "[Zig Sanitize]"
        )
    end, { nargs = "*" })

end

return M