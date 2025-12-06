-- lua/profile/mason.lua
-- Simplified mason integration: ensure common LSPs and DAP adapters are installed using canonical names.
local M = {}

-- Flattened list of canonical LSP server names (no duplicates, no legacy aliases)
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

-- Useful development/debug tools (kept conservative)
local DAP_ADAPTERS = {
    "codelldb",
    "debugpy",
    "js-debug-adapter",
    "delve",
}

function M.setup()
    local mason_ok, mason = pcall(require, "mason")
    if not mason_ok then
        vim.notify("mason.nvim not available — skipping mason setup", vim.log.levels.WARN)
        return
    end
    mason.setup({
        ui = {
            border = "rounded",
            icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
            width = 0.8,
            height = 0.8,
        },
        max_concurrent_installers = 4,
    })

    -- Configure mason-lspconfig
    local mlsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not mlsp_ok or not mason_lspconfig then
        vim.notify("mason-lspconfig not available; LSP auto-install skipped", vim.log.levels.WARN)
        return
    end

    -- Initialize ensure_installed table
    local ensure_installed_list = {}

    -- Verify that requested packages exist in the mason registry before installing
    local ok_reg, registry = pcall(require, "mason-registry")
    if ok_reg and registry and type(registry) == "table" then
        for _, name in ipairs(ENSURE_INSTALLED_LSPS) do
            -- Check if package exists in registry
            local pkg_ok, pkg = pcall(function() return registry.get_package(name) end)
            if pkg_ok and pkg then
                -- Package exists, add it to the installation list
                table.insert(ensure_installed_list, name)
            else
                vim.schedule(function()
                    vim.notify("mason: package not found in registry, skipping: " .. name, vim.log.levels.INFO)
                end)
            end
        end
    end

    mason_lspconfig.setup({
        ensure_installed = ensure_installed_list,
        automatic_installation = true,
    })

    -- Setup mason-nvim-dap if available
    local mason_dap_ok, mason_nvim_dap = pcall(require, "mason-nvim-dap")
    if mason_dap_ok and mason_nvim_dap then
        mason_nvim_dap.setup({
            ensure_installed = DAP_ADAPTERS,
            automatic_installation = true,
        })
    end
end

return M