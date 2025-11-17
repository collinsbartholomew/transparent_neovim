-- lua/profile/conform.lua
local M = {}

local function executable(cmd)
    return vim.fn.executable(cmd) == 1
end

local function has_node_module(dirname, module_path)
    local path = vim.fs.find({ "node_modules/" .. module_path }, { path = dirname, upward = true, type = "file" })
    return #path > 0
end

function M.setup()
    local ok, conform = pcall(require, "conform")
    if not ok then
        vim.notify("conform.nvim not available", vim.log.levels.WARN)
        return
    end
    conform.setup({
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "ruff_format" },
            java = { "google-java-format" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            javascriptreact = { "prettier" },
            typescriptreact = { "prettier" },
            go = { "goimports" },
            html = { "prettier" },
            css = { "prettier" },
            scss = { "prettier" },
            less = { "prettier" },
            json = { "prettier" },
            jsonc = { "prettier" },
            markdown = { "prettier" },
            mdx = { "prettier" },
            vue = { "prettier" },
            svelte = { "prettier" },
            astro = { "prettier" },
            xml = { "prettier_xml" },
            xhtml = { "prettier_xml" },
            c = { "clang-format" },
            cpp = { "clang-format" },
            cuda = { "clang-format" },
            rust = { "rustfmt" },
            sh = { "shfmt" },
            bash = { "shfmt" },
            zsh = { "shfmt" },
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
            asm = { "asmfmt" },
            nasm = { "asmfmt" },
            gas = { "asmfmt" },
            php = { "phpcbf" },
            motoko = { "prettier_motoko" },
            ["_"] = { "trim_whitespace", "trim_newlines" },
        },
        format_on_save = {
            timeout_ms = 1500,
            lsp_fallback = true,
        },
        formatters = {
            prettier = {
                prepend_args = { "--print-width", "120", "--prose-wrap", "preserve", "--tab-width", "4" },
            },
            prettier_xml = {
                command = "prettier",
                prepend_args = { "--print-width", "120", "--prose-wrap", "preserve", "--tab-width", "3" },
            },
            prettier_motoko = {
                command = "prettier",
                prepend_args = { "--print-width", "120", "--prose-wrap", "preserve", "--tab-width", "4", "--plugin", "prettier-plugin-motoko" },
            },
            ["clang-format"] = {
                prepend_args = { "--style={IndentWidth: 4, UseTab: ForIndentation}" },
            },
            rustfmt = {},
            shfmt = {
                prepend_args = { "-i", "4" },
            },
            stylua = {},
            ruff_format = {},
            rubocop = {},
            csharpier = {
                command = "csharpier",
                args = { "--write-stdout" },
            },
            sqlfluff = {
                prepend_args = { "--dialect", "ansi" },
            },
            taplo = {},
            fish_indent = {},
            mix_format = {
                command = "mix",
                args = { "format", "-" },
            },
            erlfmt = {},
            fourmolu = {},
            scalafmt = {},
            gofumpt = {},
            goimports = {},
            ["google-java-format"] = {
                args = { "-" },
            },
            asmfmt = {},
            phpcbf = {
                prepend_args = { "--standard=PSR12" },
            },
            eslint_d = {
                args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
                condition = function()
                    return executable("eslint_d")
                end,
            },
        },
    })
    vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
        if conform.format_on_save then
            conform.format_on_save = nil
            vim.notify("Format on save disabled", vim.log.levels.INFO)
        else
            conform.format_on_save = { timeout_ms = 1500, lsp_fallback = true }
            vim.notify("Format on save enabled", vim.log.levels.INFO)
        end
    end, { desc = "Toggle conform.nvim format on save" })
end

return M