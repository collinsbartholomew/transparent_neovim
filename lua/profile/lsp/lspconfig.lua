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
        illuminate = true,
        navic = true,
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

local function get_vue_plugin_path()
    local ok, out = pcall(function()
        if not executable("npm") then
            return nil
        end
        local root = vim.trim(vim.fn.system("npm root -g"))
        if vim.v.shell_error ~= 0 or root == "" then
            return nil
        end
        return root .. "/@vue/typescript-plugin"
    end)
    if not ok or not out or out == "" then
        return nil
    end
    return out
end

-- =======================
-- Server-specific overrides
-- =======================
local function server_overrides(server_name)
    local vue_path = get_vue_plugin_path()
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
        ts_ls = (function()
            if vue_path then
                return {
                    init_options = {
                        plugins = {
                            {
                                name = "@vue/typescript-plugin",
                                location = vue_path,
                                languages = { "vue" },
                            },
                        },
                    },
                    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
                }
            end
            return {}
        end)(),
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
                "mdx",
            },
            init_options = { userLanguages = { eelixir = "html-eex", eruby = "erb" } },
        },
        qmlls = {
            filetypes = { "qml", "qmljs" },
            root_dir = function(fname)
                return vim.fn.getcwd()
            end,
            settings = {
                qml = {
                    import_dirs = { ".", "./imports" },
                },
            },
        },
        clangd = {
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders=false",
            },
            init_options = {
                fallbackFlags = { "-std=c++17", "-fPIC" },
                clangdFileStatus = true,
            },
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
    if M.config.features.navic and client.capabilities.documentSymbolProvider then
        local ok, navic = pcall(require, "nvim-navic")
        if ok then
            navic.attach(client, bufnr)
        end
    end
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
    if M.config.features.illuminate then
        local ok, illuminate = pcall(require, "illuminate")
        if ok then
            illuminate.on_attach(client)
        end
    end
    if client.supports_method("textDocument/documentHighlight") then
        local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })
        vim.api.nvim_create_autocmd("CursorMoved", {
            group = group,
            buffer = bufnr,
            callback = function()
                pcall(vim.lsp.buf.document_highlight)
            end,
        })
        vim.api.nvim_create_autocmd("CursorMovedI", {
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
-- Main setup (Mason + vim.lsp.config)
-- =======================
function M.setup()
    pcall(setup_ui_handlers)
    local capabilities = make_capabilities()
    vim.lsp.log.set_level(vim.log.levels.WARN)
    
    -- Add Motoko filetype mapping
    vim.filetype.add({
        extension = {
            mo = "motoko",
        },
    })
    
    local lsp_configs = require("lspconfig.configs")
    local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not mason_lspconfig_ok or not mason_lspconfig.setup_handlers then
        vim.notify("mason-lspconfig not available or missing setup_handlers; skipping automatic LSP registration", vim.log.levels.WARN)
        return
    end
    
    mason_lspconfig.setup({ automatic_installation = true })

    -- Use setup_handlers so each server is configured reliably and lazily by mason-lspconfig.
    pcall(function()
        mason_lspconfig.setup_handlers({
        -- Default handler for any server
        function(server_name)
            local lsp = require("lspconfig")
            if not lsp[server_name] then
                vim.notify("lspconfig does not have a server named: " .. server_name, vim.log.levels.WARN)
                return
            end

            local base_config = {
                on_attach = on_attach,
                capabilities = capabilities,
                flags = {
                    debounce_text_changes = 300, -- Increased debounce for better performance
                    allow_incremental_sync = true,
                },
            }

            local overrides = server_overrides(server_name) or {}
            local cfg = vim.tbl_deep_extend("force", base_config, overrides)

            -- Use lspconfig's setup to register the server. This is the standard, supported API.
            pcall(function()
                lsp[server_name].setup(cfg)
            end)
        end,
    })
    end)
end

return M