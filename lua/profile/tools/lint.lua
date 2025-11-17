-- lua/profile/lint.lua
local M = {}

local function executable(cmd)
    return vim.fn.executable(cmd) == 1
end

function M.setup()
    local ok, lint = pcall(require, "lint")
    if not ok then
        vim.notify("nvim-lint not available", vim.log.levels.WARN)
        return
    end
    lint.linters_by_ft = {
        lua = { "luacheck" },
        python = { "ruff" },
        java = { "checkstyle" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        html = { "htmlhint" },
        css = { "stylelint" },
        scss = { "stylelint" },
        c = { "clangtidy" },
        cpp = { "clangtidy" },
        rust = { "clippy" },
        go = { "golangcilint" },
        php = { "phpstan" },
        motoko = { "moc" },
    }
    -- Custom linter for Motoko using moc - only if moc is available
    if executable("moc") then
        lint.linters.moc = {
            cmd = "moc",
            args = { "--check", "$FILENAME" },
            stdin = false,
            append_fname = true,
            ignore_exitcode = true,
            parser = function(output, bufnr)
                local diagnostics = {}
                for _, line in ipairs(vim.split(output, "\n")) do
                    local file, ln, start_col, end_ln, end_col, err_type, code, msg =
                        line:match("(.*):(%d+).(%d+)-(%d+).(%d+),%s+(.+)%[(.+)%],%s+(.*)")
                    if ln then
                        table.insert(diagnostics, {
                            bufnr = bufnr,
                            lnum = tonumber(ln) - 1,
                            col = tonumber(start_col) - 1,
                            end_lnum = tonumber(end_ln) - 1,
                            end_col = tonumber(end_col) - 1,
                            severity = vim.diagnostic.severity.ERROR,
                            message = err_type .. " [" .. code .. "]: " .. msg,
                            source = "moc",
                        })
                    end
                end
                return diagnostics
            end,
        }
    end
    -- Use built-in parsers for others (assuming nvim-lint has them)
    local group = vim.api.nvim_create_augroup("ProfileNvimLint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        group = group,
        callback = function()
            lint.try_lint()
        end,
    })
end

return M
