local M = {}

function M.setup()
    local conform_status, conform = pcall(require, "conform")
    if not conform_status then
        vim.notify("Conform.nvim not available", vim.log.levels.WARN)
        return
    end

    conform.setup({
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "ruff_format" },
            java = { "google-java-format" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            go = { "goimports", "gofumpt" },
            html = { "prettier" },
            jsx = { "prettier" },
            tsx = { "prettier" },
            xml = { "prettier" },
            xhtml = { "prettier" },
            css = { "prettier" },
            scss = { "prettier" },
            sass = { "prettier" },
            less = { "prettier" },
            json = { "prettier" },
            markdown = { "prettier" },
            handlebars = { "prettier" },
            hbs = { "prettier" },
            php = { "phpcbf" },
            vue = { "prettier" },
            svelte = { "prettier" },
            astro = { "prettier" },
            mdx = { "prettier" },
            c = { "clang-format" },
            cpp = { "clang-format" },
            rust = { "rustfmt" },
            sh = { "shfmt" },
            bash = { "shfmt" },
            ruby = { "rubocop" },
            dart = { "dart_format" },
            zig = { "zigfmt" },
            csharp = { "csharpier" },
            sql = { "sqlfluff" },
            graphql = { "prettier" },
            yaml = { "prettier" },
            toml = { "taplo" },
            fish = { "fish_indent" },
            elixir = { "mix_format" },
            erlang = { "erlfmt" },
            haskell = { "fourmolu" },
            scala = { "scalafmt" },
        },
        format_on_save = function(bufnr)
            if vim.g.disable_conform_format then
                return
            end
            return {
                timeout_ms = 2000,
                lsp_fallback = true,
            }
        end,
        formatters = {
            injected = {
                options = {
                    ignore_errors = true,
                },
            },
            prettier = {
                condition = function(_, ctx)
                    local found = false
                    if ctx and ctx.dirname then
                        found = vim.fs.find({ "package.json" }, { path = ctx.dirname, upward = true })[1]
                    end
                    return found or vim.fn.executable("prettier") == 1
                end,
                prepend_args = { "--config", vim.fn.expand("~/.config/nvim/.prettierrc.json") },
            },
            ["clang-format"] = {
                prepend_args = { "--config", vim.fn.expand("~/.config/nvim/.clang-format") },
            },
            rustfmt = {
                prepend_args = { "--config-path", vim.fn.expand("~/.config/nvim/rustfmt.toml") },
            },
            shfmt = {
                prepend_args = { "-i", "4" },
            },
            stylua = {
                prepend_args = { "--config-path", vim.fn.expand("~/.config/nvim/stylua.toml") },
            },
            black = {
                prepend_args = { "--config", vim.fn.expand("~/.config/nvim/pyproject.toml") },
            },
            rubocop = {
                prepend_args = { "-c", vim.fn.expand("~/.config/nvim/.rubocop.yml") },
            },

            csharpier = {
                command = "dotnet",
                args = { "csharpier", "--config", vim.fn.expand("~/.config/nvim/.csharpierrc"), "-" },
                condition = function()
                    return vim.fn.executable("dotnet") == 1
                end,
            },
            sqlfluff = {
                command = "sqlfluff",
                args = { "format", "--config", vim.fn.expand("~/.config/nvim/.sqlfluff"), "-" },
                condition = function()
                    return vim.fn.executable("sqlfluff") == 1
                end,
            },

            taplo = {
                command = "taplo",
                args = { "format", "--config", vim.fn.expand("~/.config/nvim/.taplo.toml"), "-" },
            },
            fish_indent = {
                command = "fish_indent",
                args = { "-" },
            },
            mix_format = {
                command = "mix",
                args = { "format", "-" },
            },
            erlfmt = {
                command = "erlfmt",
                args = { "--config-file", vim.fn.expand("~/.config/nvim/.erlfmt"), "-" },
            },
            fourmolu = {
                command = "fourmolu",
                args = { "--config-file", vim.fn.expand("~/.config/nvim/fourmolu.yaml"), "-" },
            },
            scalafmt = {
                command = "scalafmt",
                args = { "--config-str", "{indentSize=4, style=defaultWithAlign}", "--stdin" },
            },

            gofumpt = {
                command = "gofumpt",
            },
            goimports = {
                command = "goimports",
                args = { "-" },
            },
            ["google-java-format"] = {
                command = "google-java-format",
                args = { "-" },
            },
            ruff_format = {
                command = "ruff",
                args = { "format", "--config", vim.fn.expand("~/.config/nvim/pyproject.toml"), "-" },
            },
            eslint_d = {
                command = "eslint_d",
                args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
                condition = function(_, ctx)
                    local found = vim.fn.executable("eslint_d") == 1
                    if not found then
                        return false
                    end
                    vim.fn.system("eslint_d start")
                    return true
                end,
                timeout_ms = 10000,
            },
            phpcbf = {
                command = "phpcbf",
                args = { "--standard=PSR12", "-" },
            },
        },
    })

    vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
        vim.g.disable_conform_format = not vim.g.disable_conform_format
        local status = vim.g.disable_conform_format and "disabled" or "enabled"
        vim.notify("Format on save " .. status, vim.log.levels.INFO)
    end, {})
end

return M
