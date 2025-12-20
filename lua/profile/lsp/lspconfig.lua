-- lua/profile/lsp.lua
-- Simplified, defensive LSP config using vim.lsp.config (Neovim 0.11+).
-- Registers servers for on-demand activation.
-- Inlay hints are explicitly disabled.
local M = {}

-- =======================
-- Configuration
-- =======================
M.config = {
    handlers = {
        hover = {
            border = "rounded",
            max_width = 80,
            max_height = 20,
            focusable = true,
            silent = true,
            wrap = true,
            style = "minimal",
            title = " 󰋖 Hover ",
            title_pos = "left",
        },
        signature = {
            border = "rounded",
            max_width = 60,
            max_height = 10,
            focusable = true,
            silent = true,
            style = "minimal",
            title = " 󰯂 Signature ",
            title_pos = "left",
        },
        diagnostic = {
            float = {
                border = "rounded",
                focusable = true,
                style = "minimal",
                source = "if_many",
                header = "",
                prefix = "",
                title = " 󰨮 Diagnostic ",
                title_pos = "left",
            },
            signs = true,
            update_in_insert = false,
            underline = true,
            severity_sort = true,
            virtual_text = false, -- Disabled inline diagnostics
        },
    },
    features = {
        inlay_hints = false, -- Explicitly disabled
        codelens = false, -- Disabled for performance
        semantic = true,
    },
}

-- =======================
-- Utilities
-- =======================
local function executable(cmd)
    return vim.fn.executable(cmd) == 1
end

-- =======================
-- Server-specific overrides
-- =======================
local function server_overrides(server_name)
    local overrides = {
        lua_ls = {
            settings = {
                Lua = {
                    diagnostics = { globals = { "vim", "describe", "it", "before_each", "after_each" } },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                    },
                    telemetry = { enable = false },
                },
            },
        },
        tsserver = {
            settings = {
                javascript = { inlayHints = { enabled = false } },
                typescript = { inlayHints = { enabled = false } },
            },
        },
        rust_analyzer = {
            settings = {
                ["rust-analyzer"] = {
                    cargo = { allFeatures = true },
                    checkOnSave = { command = "clippy" },
                },
            },
        },
        tailwindcss = {
            filetypes = {
                "html",
                "css",
                "scss",
                "sass",
                "less",
                "javascript",
                "javascriptreact",
                "typescript",
                "typescriptreact",
                "vue",
                "svelte",
                "astro",
            },
        },
        clangd = {
            cmd = { "clangd", "--background-index", "--clang-tidy" },
        },
    }
    return overrides[server_name] or {}
end

-- =======================
-- UI Handlers
-- =======================
local function setup_ui_handlers()
    local h = M.config.handlers or {}
    vim.lsp.handlers["textDocument/hover"] =
        vim.lsp.with(vim.lsp.handlers.hover, vim.tbl_extend("force", h.hover or {}, { silent = true }))
    vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, vim.tbl_extend("force", h.signature or {}, { silent = true }))
    vim.diagnostic.config({
        virtual_text = h.diagnostic.virtual_text,
        signs = h.diagnostic.signs,
        underline = h.diagnostic.underline,
        update_in_insert = h.diagnostic.update_in_insert,
        severity_sort = h.diagnostic.severity_sort,
    })
    M._diagnostic_float_opts = h.diagnostic.float or { border = "rounded", source = "if_many" }
end

function M.open_diagnostic_float(opts)
    opts = vim.tbl_deep_extend("force", M._diagnostic_float_opts or {}, opts or {})
    vim.diagnostic.open_float(nil, opts)
end

-- =======================
-- Per-buffer attach handlers
-- =======================
local function setup_handlers(client, bufnr)
    if not client or not bufnr then
        return
    end
    -- Set omnifunc defensively
    pcall(function()
        vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end)
    -- Inlay hints are explicitly disabled
    if M.config.features.codelens and client.capabilities.codeLens then
        pcall(vim.lsp.codelens.refresh)
        local group = vim.api.nvim_create_augroup("lsp_codelens_" .. bufnr, { clear = true })
        -- Refresh codelens less frequently to avoid performance issues
        vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
            group = group,
            buffer = bufnr,
            callback = function()
                pcall(vim.lsp.codelens.refresh)
            end,
        })
    end

    if client.supports_method("textDocument/documentHighlight") then
        local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = group,
            buffer = bufnr,
            callback = function()
                pcall(vim.lsp.buf.document_highlight)
            end,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            group = group,
            buffer = bufnr,
            callback = function()
                pcall(vim.lsp.buf.clear_references)
            end,
        })
    end
end

local function on_attach(client, bufnr)
    setup_handlers(client, bufnr)
end

-- =======================
-- Capabilities
-- =======================
local function make_capabilities()
    local ok, caps_mod = pcall(require, "profile.lsp.capabilities")
    if ok and caps_mod and type(caps_mod.get_capabilities) == "function" then
        return caps_mod.get_capabilities()
    end
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok2, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if ok2 then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end
    return capabilities
end

-- =======================
-- Main setup via mason-lspconfig
-- =======================
function M.setup()
    pcall(setup_ui_handlers)
    local capabilities = make_capabilities()
    vim.lsp.log.set_level(vim.log.levels.WARN)

    -- Require mason-lspconfig and use setup_handlers
    local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not ok or not mason_lspconfig or not mason_lspconfig.setup_handlers then
        vim.notify("mason-lspconfig not available; cannot setup LSP servers", vim.log.levels.ERROR)
        return
    end

    -- Register setup_handlers to handle each installed server
    mason_lspconfig.setup_handlers({
        -- Default handler for any server
        function(server_name)
            -- rust-analyzer is managed by rustaceanvim
            if server_name == "rust_analyzer" then
                return
            end

            local lsp = require("lspconfig")

            -- Skip if lspconfig doesn't recognize this server
            if not lsp[server_name] then
                return
            end

            local base_config = {
                on_attach = on_attach,
                capabilities = capabilities,
                flags = {
                    debounce_text_changes = 300,
                    allow_incremental_sync = true,
                },
            }

            local overrides = server_overrides(server_name) or {}
            local config = vim.tbl_deep_extend("force", base_config, overrides)

            pcall(function()
                lsp[server_name].setup(config)
            end)
        end,
    })
end

return M