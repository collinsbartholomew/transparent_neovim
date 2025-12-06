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
    -- Build formatters_by_ft defensively so missing tools/plugins don't cause runtime failures
    local function has(cmd) return vim.fn.executable(cmd) == 1 end
    local fb = {
        lua = { "stylua" },
        python = { "ruff_format" },
        java = { "google-java-format" },
        javascript = has("prettier") and { "prettier" } or nil,
        typescript = has("prettier") and { "prettier" } or nil,
        javascriptreact = has("prettier") and { "prettier" } or nil,
        typescriptreact = has("prettier") and { "prettier" } or nil,
        go = { "goimports" },
        html = has("prettier") and { "prettier" } or nil,
        css = has("prettier") and { "prettier" } or nil,
        scss = has("prettier") and { "prettier" } or nil,
        less = has("prettier") and { "prettier" } or nil,
        json = has("prettier") and { "prettier" } or nil,
        jsonc = has("prettier") and { "prettier" } or nil,
        markdown = has("prettier") and { "prettier" } or nil,
        mdx = has("prettier") and { "prettier" } or nil,
        vue = has("prettier") and { "prettier" } or nil,
        svelte = has("prettier") and { "prettier" } or nil,
        astro = has("prettier") and { "prettier" } or nil,
        xml = has("prettier") and { "prettier_xml" } or nil,
        xhtml = has("prettier") and { "prettier_xml" } or nil,
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
        graphql = has("prettier") and { "prettier" } or nil,
        yaml = has("prettier") and { "prettier" } or nil,
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
        motoko = (has("prettier") and { "prettier_motoko" }) or nil,
        ["_"] = { "trim_whitespace", "trim_newlines" },
    }

    -- Remove nil entries
    for k, v in pairs(fb) do if v == nil then fb[k] = nil end end

    conform.setup({
        formatters_by_ft = fb,
        format_on_save = {
            timeout_ms = 1000, -- Reduced from 1500 for better responsiveness
            lsp_fallback = true,
        },
        formatters = {
            prettier = {
                condition = function() return has("prettier") end,
                prepend_args = { "--print-width", "120", "--prose-wrap", "preserve", "--tab-width", "3" },
            },
            prettier_xml = {
                condition = function() return has("prettier") end,
                command = "prettier",
                prepend_args = { "--print-width", "120", "--prose-wrap", "preserve", "--tab-width", "3" },
            },
            prettier_motoko = {
                condition = function() return has("prettier") end,
                command = "prettier",
                prepend_args = { "--print-width", "120", "--prose-wrap", "preserve", "--tab-width", "3", "--plugin", "prettier-plugin-motoko" },
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
            conform.format_on_save = { timeout_ms = 1000, lsp_fallback = true } -- Reduced timeout
            vim.notify("Format on save enabled", vim.log.levels.INFO)
        end
    end, { desc = "Toggle conform.nvim format on save" })
end

return M