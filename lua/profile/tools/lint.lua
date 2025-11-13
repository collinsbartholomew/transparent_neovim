-- lua/profile/lint.lua
local M = {}

function M.setup()
    local ok, lint = pcall(require, "lint")
    if not ok then
        vim.notify("nvim-lint not available", vim.log.levels.WARN)
        return
    end

    -- filetype -> linters map (keep conservative and useful defaults)
    lint.linters_by_ft = {
        lua = { "luacheck" },
        python = { "ruff" },
        java = { "checkstyle" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        html = { "htmlhint" },
        css = { "stylelint" },
        scss = { "stylelint" },
        asm = { "nasm" },
        nasm = { "nasm" },
        gas = { "gas" },
        cpp = { "clang-tidy", "cppcheck" },
        c = { "clang-tidy", "cppcheck" },
        qml = { "qmllint" },
        rust = { "clippy" },
        go = { "golangci-lint" },
        cs = { "dotnet_build" },
        php = { "phpstan" },
        motoko = { "motoko" },
    }

    -- NASM
    lint.linters.nasm = {
        cmd = "nasm",
        args = { "-X", "gnu", "-f", "elf64", "-o", "/dev/null", "-" },
        stdin = true,
        stream = "stderr",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                local parts = vim.split(line, ":")
                if #parts >= 3 then
                    local ln = tonumber(parts[2])
                    if ln then
                        local msg = table.concat({ unpack(parts, 3, #parts) }, ":")
                        table.insert(diagnostics, {
                            bufnr = bufnr,
                            lnum = ln - 1,
                            col = 0,
                            severity = vim.diagnostic.severity.ERROR,
                            message = msg,
                            source = "nasm",
                        })
                    end
                end
            end
            return diagnostics
        end,
    }

    -- GAS (GNU assembler)
    lint.linters.gas = {
        cmd = "as",
        args = { "--fatal-warnings", "-o", "/dev/null", "-" },
        stdin = true,
        stream = "stderr",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                local ln, msg = string.match(line, "stdin:(%d+):%s*(.*)")
                if ln and msg then
                    table.insert(diagnostics, {
                        bufnr = bufnr,
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

    -- clang-tidy
    lint.linters["clang-tidy"] = {
        cmd = "clang-tidy",
        args = { "--quiet", "-" },
        stdin = true,
        stream = "stderr",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                local ln, col, sev, msg = string.match(line, "stdin:(%d+):(%d+):%s*([^:]+):%s*(.+)")
                if ln and col and sev and msg then
                    local severity_level = vim.diagnostic.severity.WARN
                    local s = sev:lower()
                    if s:match("error") then severity_level = vim.diagnostic.severity.ERROR
                    elseif s:match("note") then severity_level = vim.diagnostic.severity.INFO end

                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = tonumber(ln) - 1,
                        col = tonumber(col) - 1,
                        severity = severity_level,
                        message = msg,
                        source = "clang-tidy",
                    })
                end
            end
            return diagnostics
        end,
    }

    -- cppcheck (XML-ish)
    lint.linters.cppcheck = {
        cmd = "cppcheck",
        args = { "--enable=all", "--inconclusive", "--xml", "--xml-version=2", "--suppress=unmatchedSuppression:*", "-" },
        stdin = true,
        stream = "stderr",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                local ln, severity, msg = string.match(line, 'filename="stdin" line="(%d+)"[^>]* severity="(%a+)"[^>]* msg="([^"]+)"')
                if ln and severity and msg then
                    local severity_level = vim.diagnostic.severity.WARN
                    if severity:lower() == "error" then severity_level = vim.diagnostic.severity.ERROR end

                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = tonumber(ln) - 1,
                        col = 0,
                        severity = severity_level,
                        message = msg,
                        source = "cppcheck",
                    })
                end
            end
            return diagnostics
        end,
    }

    -- qmllint
    lint.linters.qmllint = {
        cmd = "qmllint",
        args = { "-" },
        stdin = true,
        stream = "stderr",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                local ln, col, msg = string.match(line, "stdin:(%d+):(%d+):%s*(.+)")
                if ln and col and msg then
                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = tonumber(ln) - 1,
                        col = tonumber(col) - 1,
                        severity = vim.diagnostic.severity.ERROR,
                        message = msg,
                        source = "qmllint",
                    })
                end
            end
            return diagnostics
        end,
    }

    -- clippy (cargo)
    lint.linters.clippy = {
        cmd = "cargo",
        args = { "clippy", "--message-format=json" },
        stdin = false,
        stream = "stdout",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                if line ~= "" then
                    local ok, parsed = pcall(vim.json.decode, line)
                    if ok and parsed and parsed.reason == "compiler-message" and parsed.message and parsed.message.spans then
                        local msg = parsed.message
                        local span = msg.spans[1]
                        if span then
                            local severity = vim.diagnostic.severity.HINT
                            if msg.level == "warning" then severity = vim.diagnostic.severity.WARN
                            elseif msg.level == "error" or msg.level == "failure-note" then severity = vim.diagnostic.severity.ERROR end

                            table.insert(diagnostics, {
                                bufnr = bufnr,
                                lnum = span.line_start - 1,
                                col = span.column_start - 1,
                                end_lnum = span.line_end - 1,
                                end_col = span.column_end - 1,
                                severity = severity,
                                message = msg.message,
                                source = "clippy",
                            })
                        end
                    end
                end
            end
            return diagnostics
        end,
    }

    -- golangci-lint (checkstyle-like xml)
    lint.linters["golangci-lint"] = {
        cmd = "golangci-lint",
        args = { "run", "--out-format", "checkstyle" },
        stdin = false,
        stream = "stdout",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                local ln, col, severity, msg = string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
                if ln and col and severity and msg then
                    local severity_level = vim.diagnostic.severity.WARN
                    if severity:lower() == "error" then severity_level = vim.diagnostic.severity.ERROR end

                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = tonumber(ln) - 1,
                        col = tonumber(col) - 1,
                        severity = severity_level,
                        message = msg,
                        source = "golangci-lint",
                    })
                end
            end
            return diagnostics
        end,
    }

    -- dotnet build
    lint.linters.dotnet_build = {
        cmd = "dotnet",
        args = { "build", "--no-restore", "--no-dependencies" },
        stdin = false,
        stream = "stderr",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                -- pattern: path(line,column): severity CODE: message [project]
                local file, severity, code, msg = string.match(line, "([^:]+):%((%d+),(%d+)%)%s*:%s*(%a+)%s*%s*([^:]+):%s*(.+)%s+%[.+%]")
                if file and severity and code and msg then
                    -- fallback parse: if previous pattern fails, try simpler match
                    local ln, col = string.match(line, "%((%d+),(%d+)%)")
                    if ln and col then
                        local severity_level = vim.diagnostic.severity.WARN
                        if severity:lower() == "error" then severity_level = vim.diagnostic.severity.ERROR end
                        table.insert(diagnostics, {
                            bufnr = bufnr,
                            lnum = tonumber(ln) - 1,
                            col = tonumber(col) - 1,
                            severity = severity_level,
                            message = "[" .. (code or "") .. "] " .. (msg or line),
                            source = "dotnet-build",
                        })
                    end
                end
            end
            return diagnostics
        end,
    }

    -- checkstyle (Java - checkstyle XML)
    lint.linters.checkstyle = {
        cmd = "checkstyle",
        args = { "-f", "checkstyle", "-" },
        stdin = true,
        stream = "stdout",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                local ln, col, severity, msg = string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
                if ln and col and severity and msg then
                    local severity_level = vim.diagnostic.severity.WARN
                    if severity:lower() == "error" then severity_level = vim.diagnostic.severity.ERROR end

                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = tonumber(ln) - 1,
                        col = tonumber(col) - 1,
                        severity = severity_level,
                        message = msg,
                        source = "checkstyle",
                    })
                end
            end
            return diagnostics
        end,
    }

    -- ruff (python) - using checkstyle output
    lint.linters.ruff = {
        cmd = "ruff",
        args = { "check", "--format", "checkstyle", "-" },
        stdin = true,
        stream = "stdout",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                local ln, col, severity, msg = string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
                if ln and col and severity and msg then
                    local severity_level = vim.diagnostic.severity.WARN
                    if severity:lower() == "error" then severity_level = vim.diagnostic.severity.ERROR end

                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = tonumber(ln) - 1,
                        col = tonumber(col) - 1,
                        severity = severity_level,
                        message = msg,
                        source = "ruff",
                    })
                end
            end
            return diagnostics
        end,
    }

    -- luacheck
    lint.linters.luacheck = {
        cmd = "luacheck",
        args = function()
            return { "--formatter", "checkstyle", "--codes", "--ranges", "--filename", vim.api.nvim_buf_get_name(0), "-" }
        end,
        stdin = true,
        stream = "stdout",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                local ln, col, severity, msg = string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
                if ln and col and severity and msg then
                    local severity_level = vim.diagnostic.severity.WARN
                    if severity:lower() == "error" then severity_level = vim.diagnostic.severity.ERROR end

                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = tonumber(ln) - 1,
                        col = tonumber(col) - 1,
                        severity = severity_level,
                        message = msg,
                        source = "luacheck",
                    })
                end
            end
            return diagnostics
        end,
    }

    -- eslint_d
    lint.linters.eslint_d = {
        cmd = "eslint_d",
        args = function()
            return { "--format", "checkstyle", "--stdin", "--stdin-filename", vim.api.nvim_buf_get_name(0) }
        end,
        stdin = true,
        stream = "stdout",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                local ln, col, severity, msg = string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
                if ln and col and severity and msg then
                    local severity_level = vim.diagnostic.severity.WARN
                    if severity:lower() == "error" then severity_level = vim.diagnostic.severity.ERROR end

                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = tonumber(ln) - 1,
                        col = tonumber(col) - 1,
                        severity = severity_level,
                        message = msg,
                        source = "eslint_d",
                    })
                end
            end
            return diagnostics
        end,
    }

    -- phpstan
    lint.linters.phpstan = {
        cmd = "phpstan",
        args = { "analyze", "--error-format=checkstyle", "--no-progress", "-" },
        stdin = true,
        stream = "stdout",
        parser = function(output, bufnr)
            local diagnostics = {}
            for _, line in ipairs(vim.split(output or "", "\n")) do
                local ln, col, severity, msg = string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
                if ln and col and severity and msg then
                    local severity_level = vim.diagnostic.severity.WARN
                    if severity:lower() == "error" then severity_level = vim.diagnostic.severity.ERROR end

                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = tonumber(ln) - 1,
                        col = tonumber(col) - 1,
                        severity = severity_level,
                        message = msg,
                        source = "phpstan",
                    })
                end
            end
            return diagnostics
        end,
    }

    -- motoko (placeholder)
    lint.linters.motoko = {
        cmd = "mo-ide",
        args = {},
        stdin = false,
        stream = "stdout",
        parser = function()
            return {} -- placeholder until a stable output format is known
        end,
    }

    -- Create an autocmd group to avoid duplicate autocmds
    local group = vim.api.nvim_create_augroup("ProfileNvimLint", { clear = true })

    -- Lint on save only (less noisy and common practice)
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = group,
        callback = function()
            pcall(lint.try_lint)
        end,
    })
end

return M
