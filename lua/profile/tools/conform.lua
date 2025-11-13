-- lua/profile/conform.lua
local M = {}

local function executable(cmd)
    return vim.fn.executable(cmd) == 1
end

local function file_readable(path)
    return path ~= nil and path ~= "" and vim.fn.filereadable(path) == 1
end

local function has_node_local_bin(dirname, binname)
    -- check for node_modules/.bin/<binname> upward from dirname
    local path = vim.fs.find({ "node_modules/.bin/" .. binname }, { path = dirname, upward = true, type = "file" })
    return path and #path > 0
end

local function has_node_module(dirname, module_path)
    -- module_path e.g. "prettier-plugin-motoko/package.json"
    local path = vim.fs.find({ "node_modules/" .. module_path }, { path = dirname, upward = true, type = "file" })
    return path and #path > 0
end

function M.setup()
    local ok, conform = pcall(require, "conform")
    if not ok or not conform then
        vim.notify("conform.nvim not available", vim.log.levels.WARN)
        return
    end

    conform.setup({
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "ruff_format", "black", "isort" },
            ["requirements.txt"] = { "requirements_txt_fixer" },
            ["pyproject.toml"] = { "taplo" },
            java = { "google-java-format" },
            javascript = { "prettier", "eslint_d" },
            typescript = { "prettier", "eslint_d" },
            javascriptreact = { "prettier", "eslint_d" },
            typescriptreact = { "prettier", "eslint_d" },
            go = { "goimports", "gofumpt" },
            html = { "prettier" },
            css = { "prettier" },
            scss = { "prettier" },
            less = { "prettier" },
            json = { "prettier" },
            jsonc = { "prettier" },
            markdown = { "prettier" }, -- removed markdownlint (was unavailable)
            mdx = { "prettier" },
            handlebars = { "prettier" },
            motoko = { "mo_fmt", "motoko_prettier" }, -- prefer mo-fmt, fallback to motoko_prettier only if plugin exists
            asm = { "asmfmt" },
            nasm = { "asmfmt" },
            gas = { "asmfmt" },
            php = { "phpcbf", "php_cs_fixer" },
            ["composer.json"] = { "prettier" },
            ["*.blade.php"] = { "blade-formatter" },
            vue = { "prettier" },
            svelte = { "prettier" },
            astro = { "prettier" },
            c = { "clang-format" },
            cpp = { "clang-format" },
            cuda = { "clang-format" },
            rust = { "rustfmt" },
            -- removed cmake/cmakelang/cmakelint/cpplint entries (they were not defined)
            sh = { "shfmt" },
            bash = { "shfmt" },
            zsh = { "shfmt" },
            ruby = { "rubocop" },
            dart = { "dart_format" },
            zig = { "zigfmt" },
            csharp = { "csharpier" },
            sql = { "sqlfluff" }, -- sqlfluff is defined below and will run only if available
            graphql = { "prettier" },
            yaml = { "prettier" }, -- removed yamlfmt (was unavailable)
            toml = { "taplo" },
            properties = { "prettier" },
            ["docker-compose.yml"] = { "prettier" },
            ["*.env"] = { "dotenv-linter" }, -- if you don't have dotenv-linter, remove this
            fish = { "fish_indent" },
            elixir = { "mix_format" },
            erlang = { "erlfmt" },
            haskell = { "fourmolu" },
            scala = { "scalafmt" },
        },

        -- Always return a table or false. Keep small timeout; allow toggle via vim.g.disable_conform_format
        format_on_save = function(bufnr)
            if vim.g.disable_conform_format then
                return false
            end
            return {
                timeout_ms = 1500,
                lsp_fallback = true,
            }
        end,

        formatters = {
            injected = {
                options = { ignore_errors = true },
            },

            -- PRETTIER (general)
            prettier = {
                condition = function(self, ctx)
                    -- If prettier config exists in project or prettier is available, allow formatting
                    local config_files = {
                        ".prettierrc", ".prettierrc.json", ".prettierrc.yml", ".prettierrc.yaml",
                        ".prettierrc.js", ".prettierrc.cjs", "prettier.config.js", "prettier.config.cjs",
                        ".editorconfig",
                    }
                    local found = false
                    for _, fname in ipairs(config_files) do
                        local t = vim.fs.find({ fname }, { path = ctx.dirname, upward = true, type = "file" })
                        if t and #t > 0 then
                            found = true
                            break
                        end
                    end

                    local has_package_json = (vim.fs.find({ "package.json" }, { path = ctx.dirname, upward = true, type = "file" }) or {})[1] ~= nil
                    local local_prettier = has_node_local_bin(ctx.dirname, "prettier")
                    local has_prettier = executable("prettier")

                    -- Accept if any evidence of prettier exists
                    return found or has_package_json or local_prettier or has_prettier
                end,
                args = function(self)
                    -- ensure Prettier can infer parser by giving the filename
                    -- do not hardset parser; let Prettier infer from stdin-filepath.
                    return {
                        "--stdin-filepath", "$FILENAME",
                        "--tab-width", tostring(self._tabWidth or 4),
                        "--use-tabs", "false",
                        "--print-width", "120",
                        "--prose-wrap", "preserve",
                    }
                end,
                -- set tab width at time of invocation using filetype heuristics
                on_run = function(self, ctx)
                    local bufnr = (ctx and ctx.bufnr) or vim.api.nvim_get_current_buf()
                    local ft = vim.bo[bufnr].filetype
                    local xml_like = {
                        html = true, xml = true, jsx = true, tsx = true,
                        vue = true, svelte = true, blade = true,
                        typescriptreact = true, javascriptreact = true,
                        astro = true
                    }
                    self._tabWidth = xml_like[ft] and 3 or 4
                end,
            },

            -- clang-format (use project .clang-format if present)
            ["clang-format"] = {
                prepend_args = { "--style=file:" .. vim.fn.expand("~/.config/nvim/.clang-format") },
            },

            rustfmt = {
                prepend_args = { "--config-path", vim.fn.expand("~/.config/nvim/rustfmt.toml") },
            },

            shfmt = {
                prepend_args = function()
                    local args = { "-i", "4" }
                    local config = vim.fn.expand("~/.config/nvim/.shfmt.toml")
                    if file_readable(config) then
                        table.insert(args, "--filename")
                        table.insert(args, config)
                    end
                    return args
                end,
                condition = function()
                    return executable("shfmt")
                end,
            },

            stylua = {
                prepend_args = { "--config-path", vim.fn.expand("~/.config/nvim/stylua.toml") },
            },

            ruff_format = {
                prepend_args = { "--config", vim.fn.expand("~/.config/nvim/pyproject.toml") },
            },

            rubocop = {
                prepend_args = { "-c", vim.fn.expand("~/.config/nvim/.rubocop.yml") },
            },

            csharpier = {
                command = "dotnet-csharpier",
                args = function()
                    local args = { "--write-stdout" }
                    local config = vim.fn.expand("~/.config/nvim/.csharpierrc.json")
                    if file_readable(config) then
                        table.insert(args, "--config-path")
                        table.insert(args, config)
                    end
                    return args
                end,
                stdin = true,
                condition = function()
                    if not executable("dotnet-csharpier") then
                        vim.notify("dotnet-csharpier not found. Install with: dotnet tool install -g csharpier", vim.log.levels.WARN)
                        return false
                    end
                    return true
                end,
            },

            sqlfluff = {
                command = "sqlfluff",
                args = { "format", "--dialect", "ansi", "--config", vim.fn.expand("~/.config/nvim/.sqlfluff"), "-" },
                stdin = true,
                condition = function()
                    return executable("sqlfluff")
                end,
            },

            taplo = {
                command = "taplo",
                args = { "format", "--config", vim.fn.expand("~/.config/nvim/.taplo.toml"), "-" },
                stdin = true,
            },

            fish_indent = {
                command = "fish_indent",
                args = {},
                stdin = true,
            },

            mix_format = {
                command = "mix",
                args = { "format", "-" },
                stdin = true,
            },

            erlfmt = {
                command = "erlfmt",
                args = { "-" },
                stdin = true,
            },

            fourmolu = {
                command = "fourmolu",
                args = { "--stdin-input-file", "$FILENAME", "-" },
                stdin = true,
            },

            scalafmt = {
                command = "scalafmt",
                args = { "--stdin", "--config-str", "version=3.7.3,indentSize=4,style=defaultWithAlign" },
                stdin = true,
            },

            gofumpt = { command = "gofumpt" },
            goimports = { command = "goimports" },

            ["google-java-format"] = {
                command = "google-java-format",
                args = { "-" },
                stdin = true,
            },

            -- mo-fmt (native Motoko formatter) — preferred if available
            mo_fmt = {
                command = "mo-fmt",
                args = { "-" },
                stdin = true,
                condition = function()
                    return executable("mo-fmt")
                end,
            },

            -- motoko via Prettier + plugin — only enable when plugin exists in project (or global install)
            motoko_prettier = {
                command = "prettier",
                args = { "--stdin-filepath", "$FILENAME", "--plugin", "prettier-plugin-motoko" },
                stdin = true,
                condition = function(_, ctx)
                    -- ctx may be nil if Conform calls without context; be defensive
                    local dirname = (ctx and ctx.dirname) or vim.fn.getcwd()
                    -- plugin present locally?
                    if has_node_module(dirname, "prettier-plugin-motoko/package.json") then
                        return true
                    end
                    -- Otherwise, check if global prettier and user installed plugin globally (less common)
                    if executable("prettier") and has_node_module(vim.fn.expand("~"), "prettier-plugin-motoko/package.json") then
                        return true
                    end
                    -- not found — do not try to run motoko_prettier (avoids 'Cannot find package' error)
                    return false
                end,
            },

            asmfmt = {
                command = "asmfmt",
                args = { "-" },
                stdin = true,
            },

            phpcbf = {
                command = "phpcbf",
                args = { "--standard=PSR12", "-" },
                stdin = true,
            },

            eslint_d = {
                command = "eslint_d",
                args = function()
                    return { "--fix-to-stdout", "--stdin", "--stdin-filename", vim.api.nvim_buf_get_name(0) }
                end,
                stdin = true,
                condition = function()
                    return executable("eslint_d")
                end,
            },

            -- css / other from your original list kept where they are commonly available
            -- (if you see "unknown formatter" messages for any of these, remove the ft mapping above
            -- or install the formatter binary)
        },
    })

    -- Create ToggleFormatOnSave command safely (if already exists, don't error)
    pcall(function()
        vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
            vim.g.disable_conform_format = not vim.g.disable_conform_format
            local status = vim.g.disable_conform_format and "disabled" or "enabled"
            vim.notify("Format on save " .. status, vim.log.levels.INFO)
        end, { desc = "Toggle conform.nvim format on save" })
    end)
end

return M
