-- lua/profile/lsp.lua
-- Self-contained, defensive LSP config using Neovim's vim.lsp.config (0.11+).
-- Registers servers for on-demand activation (does NOT start them proactively).
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
            virtual_text = {
                spacing = 4,
                source = "if_many",
                prefix = "●",
            },
        },
    },
    features = {
        -- Inlay hints are explicitly disabled (do not call vim.lsp.inlay_hint anywhere).
        inlay_hints = false,
        illuminate = true,
        navic = true,
        codelens = true,
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

local function normalize_name(name)
    local map = {
        tsserver = "tsserver",
        typescript = "tsserver",
        ts_ls = "tsserver",
        sumneko_lua = "lua_ls",
        lua = "lua_ls",
        lua_ls = "lua_ls",
        rust = "rust_analyzer",
        rust_analyzer = "rust_analyzer",
        pyright = "pyright",
        clangd = "clangd",
    }
    return map[name] or name
end

-- =======================
-- Server-specific overrides
-- =======================
local function server_overrides(server_name)
    local name = normalize_name(server_name)
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
        tsserver = (function()
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
    }

    return overrides[name] or {}
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
        virtual_text = h.diagnostic and h.diagnostic.virtual_text or false,
        signs = h.diagnostic and h.diagnostic.signs or true,
        underline = h.diagnostic and h.diagnostic.underline or true,
        update_in_insert = h.diagnostic and h.diagnostic.update_in_insert or false,
        severity_sort = h.diagnostic and h.diagnostic.severity_sort or true,
    })

    M._diagnostic_float_opts = h.diagnostic and h.diagnostic.float or { border = "rounded", source = "if_many" }
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

    -- set omnifunc defensively
    pcall(function()
        vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end)

    if M.config.features.navic and client.server_capabilities and client.server_capabilities.documentSymbolProvider then
        local ok, navic = pcall(require, "nvim-navic")
        if ok and navic and navic.attach then
            pcall(navic.attach, client, bufnr)
        end
    end

    -- Inlay hints are explicitly disabled — this gate will prevent enabling them.
    if
        M.config.features.inlay_hints
        and client.supports_method
        and client.supports_method("textDocument/inlayHint")
    then
        pcall(function()
            vim.lsp.inlay_hint(bufnr, true)
        end)
    end

    if M.config.features.codelens and client.server_capabilities and client.server_capabilities.codeLensProvider then
        pcall(vim.lsp.codelens.refresh)
        local group = vim.api.nvim_create_augroup("lsp_codelens_" .. bufnr, { clear = true })
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            group = group,
            buffer = bufnr,
            callback = function()
                pcall(vim.lsp.codelens.refresh)
            end,
        })
    end

    if M.config.features.illuminate then
        local ok, illuminate = pcall(require, "illuminate")
        if ok and illuminate and illuminate.on_attach then
            pcall(illuminate.on_attach, client)
        end
    end

    if client.supports_method and client.supports_method("textDocument/documentHighlight") then
        local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = group,
            buffer = bufnr,
            callback = function()
                pcall(vim.lsp.buf.document_highlight)
            end,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
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
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    capabilities.textDocument = vim.tbl_deep_extend("force", capabilities.textDocument or {}, {
        colorProvider = { dynamicRegistration = true },
        completion = {
            completionItem = {
                snippetSupport = true,
                preselectSupport = true,
                insertReplaceSupport = true,
                labelDetailsSupport = true,
                deprecatedSupport = true,
                commitCharactersSupport = true,
                documentationFormat = { "markdown", "plaintext" },
            },
        },
        semanticTokens = {
            dynamicRegistration = true,
            multilineTokenSupport = true,
            tokenModifiers = true,
            formats = { "relative" },
        },
    })

    local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if ok and cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    return capabilities
end

-- =======================
-- Register a server using vim.lsp.config and create lazy enable autocmd
-- =======================
local function register_server_with_native_api(server_name, cfg)
    -- cfg should include on_attach, capabilities, filetypes, settings, init_options, flags, etc.
    if not vim.lsp or type(vim.lsp.config) ~= "function" and type(vim.lsp.config) ~= "table" then
        return false, "vim.lsp.config not available"
    end

    -- Normalize name; vim.lsp.config uses the config name (we keep server_name)
    local ok_set, set_err
    if type(vim.lsp.config) == "function" then
        ok_set, set_err = pcall(vim.lsp.config, server_name, cfg)
    else
        -- vim.lsp.config as table: assign directly
        ok_set, set_err = pcall(function()
            vim.lsp.config[server_name] = cfg
        end)
    end
    if not ok_set then
        return false, "failed to register config: " .. tostring(set_err)
    end

    -- If cfg.filetypes exists, create a one-shot FileType autocmd to enable the server lazily
    if
        cfg.filetypes
        and type(cfg.filetypes) == "table"
        and #cfg.filetypes > 0
        and type(vim.lsp.enable) == "function"
    then
        local group_name = "lsp_enable_" .. server_name
        local ok_grp, grp = pcall(function()
            return vim.api.nvim_create_augroup(group_name, { clear = true })
        end)
        if not ok_grp then
            -- ignore grouping failure; continue without autocmd
            return true, "registered_no_autocmd"
        end

        for _, ft in ipairs(cfg.filetypes) do
            -- For each filetype, create an autocmd that enables the server the first time that filetype appears.
            pcall(vim.api.nvim_create_autocmd, "FileType", {
                group = grp,
                pattern = ft,
                once = true,
                callback = function()
                    -- Use schedule to avoid running during FileType handling synchronously.
                    vim.schedule(function()
                        pcall(function()
                            vim.lsp.enable({ server_name })
                        end)
                    end)
                end,
            })
        end
    end

    return true, "registered"
end

-- =======================
-- Main setup (Mason + native LSP config)
-- =======================
function M.setup()
    pcall(setup_ui_handlers)

    local capabilities = make_capabilities()
    vim.lsp.log.set_level(vim.log.levels.WARN)

    local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not ok or not mason_lspconfig then
        vim.notify("mason-lspconfig not available; skipping automatic LSP registration", vim.log.levels.WARN)
        return
    end

    local function default_register(server_name)
        local base_config = {
            on_attach = on_attach,
            capabilities = capabilities,
            flags = { debounce_text_changes = 150 },
        }

        local overrides = server_overrides(server_name)
        local cfg = vim.tbl_deep_extend("force", {}, base_config, overrides)

        -- Ensure we don't attempt to enable inlay hints anywhere.
        -- (M.config.features.inlay_hints is false; on_attach handles gating.)
        local ok_reg, reg_msg = register_server_with_native_api(server_name, cfg)
        if not ok_reg then
            vim.notify(("Failed to register %s: %s"):format(server_name, tostring(reg_msg)), vim.log.levels.WARN)
        end
    end

    -- Call mason.setup() defensively
    local ok_setup, setup_err = pcall(function()
        mason_lspconfig.setup({})
    end)
    if not ok_setup then
        vim.notify("mason-lspconfig.setup() failed: " .. tostring(setup_err), vim.log.levels.WARN)
    end

    -- Use get_installed_servers() when available to register installed servers (registration is lazy).
    local ok_get, get_installed = pcall(function()
        return mason_lspconfig.get_installed_servers
    end)
    if ok_get and type(get_installed) == "function" then
        local ok_call, list_or_err = pcall(get_installed)
        if ok_call and type(list_or_err) == "table" and #list_or_err > 0 then
            for _, srv in ipairs(list_or_err) do
                pcall(default_register, srv)
            end
        else
            if not ok_call then
                vim.notify(
                    "Failed to fetch installed servers from mason-lspconfig: " .. tostring(list_or_err),
                    vim.log.levels.WARN
                )
            end
            -- If no servers installed, nothing else to do.
        end
    else
        -- Fallback: mason-lspconfig.setup_handlers (legacy) — it expects a handler that calls lspconfig.setup.
        if mason_lspconfig.setup_handlers and type(mason_lspconfig.setup_handlers) == "function" then
            local ok_legacy, err_legacy = pcall(function()
                mason_lspconfig.setup_handlers({
                    function(server_name)
                        -- For legacy path, still try to register using the native API.
                        default_register(server_name)
                    end,
                })
            end)
            if not ok_legacy then
                vim.notify("mason-lspconfig.setup_handlers() failed: " .. tostring(err_legacy), vim.log.levels.WARN)
            end
        else
            vim.notify(
                "mason-lspconfig does not expose get_installed_servers() or setup_handlers(); manual server registration may be required",
                vim.log.levels.WARN
            )
        end
    end
end

return M
