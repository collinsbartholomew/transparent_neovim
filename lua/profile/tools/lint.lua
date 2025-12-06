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
    -- Build linters_by_ft defensively: prefer linters supported by nvim-lint and verify required executables
    local available_linters = lint.linters or {}

    -- Candidate linters per filetype (ordered by preference)
    local desired = {
        lua = { "luacheck" },
        python = { "ruff", "pylint", "flake8" },
        java = { "checkstyle" },
        javascript = { "eslint_d", "eslint" },
        typescript = { "eslint_d", "eslint" },
        html = { "htmlhint" },
        css = { "stylelint" },
        scss = { "stylelint" },
        c = { "clangtidy", "cppcheck" },
        cpp = { "clangtidy", "cppcheck" },
        rust = { "clippy" },
        go = { "golangci-lint", "golangcilint" },
        php = { "phpstan", "phpcs" },
        motoko = { "moc" },
        json = { "jq" },
        yaml = { "yamllint" },
        toml = { "taplo" },
        markdown = { "markdownlint", "mdl" },
        sh = { "shellcheck" },
        zsh = { "shellcheck" },
    }

    -- Map linter name -> required executable(s) to verify availability
    local exec_map = {
        luacheck = { "luacheck" },
        ruff = { "ruff" },
        pylint = { "pylint" },
        checkstyle = { "checkstyle" },
        eslint_d = { "eslint_d" },
        eslint = { "eslint" },
        htmlhint = { "htmlhint" },
        stylelint = { "stylelint" },
        clangtidy = { "clang-tidy", "clang-tidy-14" },
        cppcheck = { "cppcheck" },
        clippy = { "cargo" },
        ["golangci-lint"] = { "golangci-lint" },
        golangcilint = { "golangci-lint" },
        phpstan = { "phpstan" },
        phpcs = { "phpcs" },
        moc = { "moc" },
        jq = { "jq" },
        yamllint = { "yamllint" },
        taplo = { "taplo" },
        markdownlint = { "markdownlint" },
        mdl = { "mdl" },
        shellcheck = { "shellcheck" },
    }

    local filtered = {}
    local report = { enabled = {}, skipped = {} }

    for ft, candidates in pairs(desired) do
        for _, name in ipairs(candidates) do
            -- linter must be defined by nvim-lint
            if available_linters[name] then
                -- if we know required executables, verify at least one exists
                local reqs = exec_map[name]
                local ok_exec = true
                if reqs then
                    ok_exec = false
                    for _, cmd in ipairs(reqs) do
                        if executable(cmd) then
                            ok_exec = true
                            break
                        end
                    end
                end
                if ok_exec then
                    filtered[ft] = filtered[ft] or {}
                    table.insert(filtered[ft], name)
                    report.enabled[name] = report.enabled[name] or {}
                    table.insert(report.enabled[name], ft)
                    break
                else
                    report.skipped[name] = report.skipped[name] or {}
                    table.insert(report.skipped[name], { ft = ft, reason = "executable missing" })
                end
            else
                report.skipped[name] = report.skipped[name] or {}
                table.insert(report.skipped[name], { ft = ft, reason = "nvim-lint provider missing" })
            end
        end
    end

    lint.linters_by_ft = filtered

    -- Create a user command to show lint availability report
    vim.api.nvim_create_user_command("LintStatus", function()
        local lines = { "Lint tools status:" }
        table.insert(lines, "Enabled linters:")
        for name, fts in pairs(report.enabled) do
            table.insert(lines, string.format("  %s -> %s", name, table.concat(fts, ", ")))
        end
        table.insert(lines, "Skipped linters:")
        for name, entries in pairs(report.skipped) do
            for _, e in ipairs(entries) do
                table.insert(lines, string.format("  %s (for %s): %s", name, e.ft, e.reason))
            end
        end
        vim.api.nvim_echo({ { table.concat(lines, "\n"), "None" } }, false, {})
    end, { desc = "Show nvim-lint enabled/skipped linters" })
    
    -- Only lint on save to avoid aggressive linting on every file read
    local group = vim.api.nvim_create_augroup("ProfileNvimLint", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        callback = function()
            lint.try_lint()
        end,
    })
end

return M
