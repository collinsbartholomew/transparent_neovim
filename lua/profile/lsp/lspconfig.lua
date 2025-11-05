local motoko_lsp_registered = false

local M = {}

local function setup_handlers()
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
        max_width = 40,
        max_height = 15,
        focusable = false,
        silent = true,
        wrap = true,
    })

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
        max_width = 50,
        max_height = 8,
        focusable = false,
        silent = true,
    })
end

local function on_attach(client, bufnr)
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    local navic_status_ok, navic = pcall(require, "nvim-navic")
    if navic_status_ok then
        navic.attach(client, bufnr)
    end

    -- Disable inlay hints by default
    if client:supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    end

    -- Setup illuminate for reference highlighting
    local illuminate_ok, illuminate = pcall(require, 'illuminate')
    if illuminate_ok then
        illuminate.on_attach(client)
    end
end

local function get_vue_plugin_path()
    local ok, result = pcall(function()
        local npm_root = vim.fn.system("npm root -g"):gsub("\n", "")
        if vim.v.shell_error == 0 then
            return npm_root .. "/@vue/typescript-plugin"
        end
        return nil
    end)
    return ok and result or nil
end

-- Server settings configuration
local function get_server_settings(server_name)
    local server_settings = {
        emmet_ls = {
            filetypes = { "html", "css", "html.handlebars", "jsx", "tsx", "vue" },
        },
        lua_ls = {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "describe", "it", "before_each", "after_each" },
                    },
                    workspace = {
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.expand("$VIMRUNTIME")] = true,
                            [vim.fn.stdpath("data") .. "/lazy/plenary.nvim/lua"] = true,
                            [vim.fn.stdpath("data") .. "/lazy/nvim-dap/lua"] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                        checkThirdParty = false,
                    },
                    completion = {
                        callSnippet = "Replace",
                    },
                    hint = {
                        enable = true,
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        },
        rust_analyzer = {
            settings = {
                ["rust-analyzer"] = {
                    cargo = {
                        loadOutDirsFromCheck = true,
                    },
                    check = {
                        command = "clippy",
                    },
                    procMacro = {
                        enable = true,
                    },
                },
            },
        },
        gopls = {
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                    },
                    staticcheck = true,
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                },
            },
        },
        clangd = {
            cmd = {
                "clangd",
                "--background-index",
                "--suggest-missing-includes",
                "--clang-tidy",
                "--header-insertion=iwyu",
            },
        },
        qmlls = {
            cmd = { "qmlls" },
            filetypes = { "qml", "qmlproject" },
        },
        zls = {
            settings = {
                zls = {
                    enable_build_on_save = true,
                    semantic_tokens = "full",
                },
            },
        },

        ts_ls = {
            init_options = {
                plugins = (function()
                    local vue_path = get_vue_plugin_path()
                    if vue_path then
                        return {
                            {
                                name = "@vue/typescript-plugin",
                                location = vue_path,
                                languages = { "vue" },
                            },
                        }
                    end
                    return {}
                end)(),
            },
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
            settings = {
                typescript = {
                    inlayHints = {
                        includeInlayParameterNameHints = 'all',
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayEnumMemberValueHints = true,
                    },
                },
                javascript = {
                    inlayHints = {
                        includeInlayParameterNameHints = 'all',
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayEnumMemberValueHints = true,
                    },
                },
            },
        },
        pyright = {
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        diagnosticMode = "workspace",
                        useLibraryCodeForTypes = true,
                    },
                },
            },
        },
        jdtls = {
            settings = {
                java = {
                    eclipse = {
                        downloadSources = true,
                    },
                    configuration = {
                        updateBuildConfiguration = "interactive",
                    },
                    maven = {
                        downloadSources = true,
                    },
                    implementationsCodeLens = {
                        enabled = true,
                    },
                    referencesCodeLens = {
                        enabled = true,
                    },
                    references = {
                        includeDecompiledSources = true,
                    },
                    format = {
                        enabled = true,
                    },
                    signatureHelp = {
                        enabled = true,
                    },
                    contentProvider = {
                        preferred = "fernflower",
                    },
                    completion = {
                        favoriteStaticMembers = {
                            "org.hamcrest.MatcherAssert.assertThat",
                            "org.hamcrest.Matchers.*",
                            "org.hamcrest.CoreMatchers.*",
                            "org.junit.jupiter.api.Assertions.*",
                            "java.util.Objects.requireNonNull",
                            "java.util.Objects.requireNonNullElse",
                            "org.mockito.Mockito.*",
                        },
                    },
                    sources = {
                        organizeImports = {
                            starThreshold = 9999,
                            staticStarThreshold = 9999,
                        },
                    },
                    codeGeneration = {
                        toString = {
                            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                        },
                        useBlocks = true,
                    },
                },
            },
        },
        omnisharp = {
            cmd = { "omnisharp" },
            filetypes = { "cs", "vb" },
            settings = {
                FormattingOptions = {
                    EnableEditorConfigSupport = true,
                    OrganizeImports = true,
                },
                MsBuild = {
                    LoadProjectsOnDemand = true,
                    UseLegacySdkResolver = false,
                },
                RoslynExtensionsOptions = {
                    EnableAnalyzersSupport = true,
                    EnableImportCompletion = true,
                    EnableAsyncCompletion = true,
                    DocumentAnalysisTimeoutMs = 30000,
                },
                OmniSharp = {
                    UseModernNet = true,
                    EnableDecompilationSupport = true,
                    EnableLspDriver = true,
                },
            },
        },
        intelephense = {
            filetypes = { "php", "blade" },
            settings = {
                intelephense = {
                    environment = {
                        phpVersion = "8.3",
                    },
                    completion = {
                        insertUseDeclaration = true,
                        fullyQualifyGlobalConstantsAndFunctions = false,
                        quoteStyle = "double",
                    },
                    format = {
                        enable = true,
                    },
                },
            },
        },
        asm_lsp = {
            filetypes = { "asm", "s", "S", "nasm", "gas" },
            settings = {
                asm = {
                    includePaths = {
                        "/usr/include",
                    },
                    defines = {
                        ["ARCH_X86_64"] = "1",
                    },
                },
            },
        },
        html = {
            settings = {
                html = {
                    suggest = {
                        html5 = true,
                    },
                    autoCompletion = true,
                    hover = {
                        documentation = true,
                        references = true,
                    },
                },
            },
            filetypes = {
                "html",
                "handlebars",
                "hbs",
                "eruby",
                "erb",
                "ejs",
            },
        },
        cssls = {
            settings = {
                css = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
                scss = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
                less = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
            },
            filetypes = {
                "css",
                "scss",
                "less",
            },
        },
        jsonls = {
            settings = {
                json = {
                    validate = { enable = true },
                    schemas = {
                        {
                            fileMatch = { "package.json" },
                            url = "https://json.schemastore.org/package.json",
                        },
                        {
                            fileMatch = { "tsconfig*.json" },
                            url = "https://json.schemastore.org/tsconfig.json",
                        },
                        {
                            fileMatch = { ".eslintrc.json", ".eslintrc" },
                            url = "https://json.schemastore.org/eslintrc.json",
                        },
                        {
                            fileMatch = { ".prettierrc", ".prettierrc.json" },
                            url = "https://json.schemastore.org/prettierrc.json",
                        },
                    },
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
            init_options = {
                userLanguages = {
                    eelixir = "html-eex",
                    eruby = "erb",
                },
            },
            settings = {
                tailwindCSS = {
                    classAttributes = { "class", "className", "classList", "ngClass" },
                    lint = {
                        cssConflict = "warning",
                        invalidApply = "error",
                    },
                },
            },
        },
        eslint = {},
    }

    return server_settings[server_name] or {}
end

function M.setup()
    setup_handlers()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument = capabilities.textDocument or {}
    capabilities.textDocument.colorProvider = { dynamicRegistration = true }
    local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if ok then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- Setup mason-lspconfig with handlers
    local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not mason_lspconfig_ok then
        vim.notify("mason-lspconfig not available", vim.log.levels.WARN)
        return
    end

    mason_lspconfig.setup({
        handlers = {
            function(server_name)
                local config = {
                    on_attach = on_attach,
                    capabilities = capabilities,
                }

                -- Merge server-specific settings
                local server_settings = get_server_settings(server_name)
                config = vim.tbl_deep_extend("force", config, server_settings)

                -- Setup the server
                local lsp_ok, lspconfig = pcall(require, "lspconfig")
                if lsp_ok and lspconfig[server_name] then
                    lspconfig[server_name].setup(config)
                end
            end,
        },
    })

    -- Setup Motoko LSP manually (not in mason)
    local lsp_ok, lspconfig = pcall(require, "lspconfig")
    if lsp_ok and not motoko_lsp_registered then
        local configs = require('lspconfig.configs')
        if not configs.motoko_lsp then
            configs.motoko_lsp = {
                default_config = {
                    cmd = { "motoko-lsp", "--stdio" },
                    filetypes = { "motoko" },
                    root_dir = lspconfig.util.root_pattern("dfx.json", ".git"),
                    settings = {},
                },
            }
        end
        lspconfig.motoko_lsp.setup({
            on_attach = on_attach,
            capabilities = capabilities,
        })
        motoko_lsp_registered = true
    end
end

return M
