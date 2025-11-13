-- lua/profile/mason.lua
-- Minimal, modern mason integration: resolve canonical registry names, ensure common LSPs and DAP adapters are installed.
local M = {}

-- Use canonical/current mason registry names only (no legacy aliases)
local LSP_GROUPS = {
    web = {
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
    },
    systems = { "clangd", "cmake", "rust_analyzer", "zls" },
    scripting = {
        "pyright",
        "ruff_lsp",
        "lua_ls",
        "gopls",
        "jdtls",
        "omnisharp",
        "intelephense",
        "bashls",
    },
    config = {
        "yamlls",
        "jsonls",
        "taplo",
        "lemminx",
        "docker_compose_language_service",
        "helm_ls",
        "marksman",
        "ltex",
    },
    other = { "motoko_lsp" },
}

-- Useful development/debug tools (kept conservative)
local DAP_ADAPTERS = {
    "codelldb",
    "debugpy",
    "js-debug-adapter",
    "chrome-debug-adapter",
    "delve",
}

-- Helper: check if a package exists in the registry
local function registry_has(registry, name)
    local ok, pkg = pcall(registry.get_package, name)
    return ok and pkg ~= nil
end

-- Build a flattened list of unique servers from LSP_GROUPS,
-- preferring registry-validated names when registry is available.
local function build_server_list(registry)
    local list = {}
    local seen = {}
    for _, group in pairs(LSP_GROUPS) do
        for _, name in ipairs(group) do
            local candidate = name
            if registry then
                if registry_has(registry, name) then
                    candidate = name
                else
                    -- If the canonical name isn't present in the registry, skip it (avoid noisy messages)
                    candidate = nil
                end
            end
            if candidate and not seen[candidate] then
                table.insert(list, candidate)
                seen[candidate] = true
            end
        end
    end
    return list
end

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

    -- Try to use the registry to validate names; if unavailable, fall back to conservative defaults.
    local registry_ok, registry = pcall(require, "mason-registry")
    local servers = {}

    if registry_ok and registry then
        servers = build_server_list(registry)
        if #servers == 0 then
            -- Registry present but none of the canonical names matched: fall back to a small default set
            servers = { "ts_ls", "html", "cssls", "clangd", "rust_analyzer", "pyright", "lua_ls" }
            vim.notify(
                "mason: registry present but no canonical names matched — using conservative fallback list",
                vim.log.levels.WARN
            )
        end
    else
        -- No registry module available — use a conservative default set
        servers = { "tsserver", "html", "cssls", "clangd", "rust_analyzer", "pyright", "lua_ls" }
    end

    -- Remove duplicates (just in case)
    local dedup = {}
    local seen = {}
    for _, s in ipairs(servers) do
        if not seen[s] then
            table.insert(dedup, s)
            seen[s] = true
        end
    end

    -- Configure mason-lspconfig
    local mlsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
    if mlsp_ok and mason_lspconfig then
        mason_lspconfig.setup({
            ensure_installed = dedup,
            -- Use lspconfig's automatic installation behavior for servers not in the list
            automatic_installation = true,
        })
    else
        vim.notify("mason-lspconfig not available; LSP auto-install skipped", vim.log.levels.WARN)
    end

    -- Setup mason-nvim-dap if available; keep adapter list conservative
    local mason_dap_ok, mason_nvim_dap = pcall(require, "mason-nvim-dap")
    if mason_dap_ok and mason_nvim_dap then
        mason_nvim_dap.setup({
            ensure_installed = DAP_ADAPTERS,
            automatic_installation = true,
        })
    end

    -- Note: intentionally omitted automated mason-tool-installer usage to avoid
    -- installing a large set of formatters/linters by default. If you want
    -- that behavior, re-enable mason-tool-installer and provide an explicit list.
end

return M
