-- lua/profile/lsp/mason.lua
-- Mason integration with validated package names
local M = {}

-- Canonical mason package names (validated against mason registry)
-- Use `mason.nvim` package names, NOT lspconfig server names
local ENSURE_INSTALLED_LSPS = {
    "ts_ls",
    "eslint",
    "html",
    "cssls",
    "emmet_ls",
    "tailwindcss",
    "svelte",
    "astro",
    "angularls",
    "prismals",
    "graphql",
    "stylelint_lsp",
    "clangd",
    "cmake",
    "rust_analyzer",
    "zls",
    "pyright",
    "ruff",
    "lua_ls",
    "gopls",
    "jdtls",
    "omnisharp",
    "intelephense",
    "bashls",
    "yamlls",
    "jsonls",
    "taplo",
    "lemminx",
    "docker_compose_language_service",
    "helm_ls",
    "marksman",
    "ltex",
    "motoko_lsp", -- Added Motoko LSP
    "qmlls", -- Qt/QML LSP
}

-- DAP adapters (keep minimal)
local DAP_ADAPTERS = {
    "codelldb",
    "debugpy",
    "js-debug-adapter",
    "delve",
}

function M.setup()
    local mason_ok, mason = pcall(require, "mason")
    if not mason_ok then
        vim.notify("mason.nvim not available", vim.log.levels.WARN)
        return
    end

    mason.setup({
        ui = {
            border = "rounded",
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗",
            },
        },
        max_concurrent_installers = 4,
    })

    local mlsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not mlsp_ok or not mason_lspconfig then
        vim.notify("mason-lspconfig not available", vim.log.levels.WARN)
        return
    end

    -- Use validated mason package names directly
    mason_lspconfig.setup({
        ensure_installed = ENSURE_INSTALLED_LSPS,
        automatic_installation = false,
    })

    local dap_ok, mason_dap = pcall(require, "mason-nvim-dap")
    if dap_ok and mason_dap then
        mason_dap.setup({
            ensure_installed = DAP_ADAPTERS,
            automatic_installation = false,
        })
    end
end

return M