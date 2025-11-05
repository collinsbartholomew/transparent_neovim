---
-- Assembly tools configuration (formatting, linting)
local M = {}

function M.setup()
    -- Conform.nvim for formatting
    local conform_ok, conform = pcall(require, "conform")
    if conform_ok then
        -- Add assembly formatter
        conform.formatters_by_ft = vim.tbl_extend("force", conform.formatters_by_ft, {
            asm = { "asmfmt" },
            nasm = { "asmfmt" },
            gas = { "asmfmt" },
        })
        
        -- Define asmfmt formatter
        conform.formatters.asmfmt = {
            command = "asmfmt",
            args = { "-" },
            stdin = true,
        }
    end

    -- Linting with nvim-lint
    local lint_ok, lint = pcall(require, "lint")
    if lint_ok then
        -- Add assembly linters
        lint.linters_by_ft = vim.tbl_extend("force", lint.linters_by_ft, {
            asm = { "nasm" },
            nasm = { "nasm" },
            gas = { "gas" },
        })
        
        -- Define NASM linter
        lint.linters.nasm = {
            cmd = "nasm",
            args = { "-X", "gnu", "-f", "elf64", "-o", "/dev/null", "-" },
            stdin = true,
            stream = "stderr",
            parser = function(output, bufnr)
                local diagnostics = {}
                for _, line in ipairs(vim.split(output, "\n")) do
                    local parts = vim.split(line, ":")
                    if #parts >= 3 then
                        local ln = tonumber(parts[2])
                        if ln then
                            table.insert(diagnostics, {
                                bufnr = bufnr,
                                lnum = ln - 1,
                                col = 0,
                                severity = vim.diagnostic.severity.ERROR,
                                message = table.concat({ unpack(parts, 3) }, ":"),
                                source = "nasm",
                            })
                        end
                    end
                end
                return diagnostics
            end,
        }
        
        -- Define GAS linter
        lint.linters.gas = {
            cmd = "as",
            args = { "--fatal-warnings", "-o", "/dev/null", "-" },
            stdin = true,
            stream = "stderr",
            parser = function(output, bufnr)
                local diagnostics = {}
                for _, line in ipairs(vim.split(output, "\n")) do
                    local pattern = "stdin:(%d+):(.*)"
                    local ln, msg = string.match(line, pattern)
                    if ln and msg then
                        table.insert(diagnostics, {
                            bugnr = bufnr,
                            lnum = tonumber(ln) - 1,
                            col = 0,
                            severity = vim.diagnostic.severity.ERROR,
                            message = msg,
                            source = "gas",
                        })
                    end
                end
                return diagnostics
            end,
        }
    end
    
    -- Set up custom formatter as fallback
    vim.api.nvim_create_user_command("AsmFormat", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local formatter = require("profile.languages.asm.formatter")
        local formatted = formatter.format_asm(lines, {})
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
    end, { nargs = 0 })
end

return M