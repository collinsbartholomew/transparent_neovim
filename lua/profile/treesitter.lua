local M = {}

function M.setup()
    local install_status, install = pcall(require, "nvim-treesitter.install")
    if install_status then
        install.prefer_git = false
    end

    -- Custom parser directory
    local parser_dir = vim.fn.stdpath("data") .. "/parsers"
    vim.opt.runtimepath:append(parser_dir)

    -- Register custom Motoko parser BEFORE treesitter setup
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.motoko = {
        install_info = {
            url = "https://github.com/polychromatist/tree-sitter-motoko.git",
            files = { "src/parser.c", "src/scanner.c" },
            generate_requires_npm = false,
            requires_generate_from_grammar = false,
            branch = "main",
        },
        filetype = "motoko",
    }

    local ts_context_ok, ts_context = pcall(require, "ts_context_commentstring")
    if ts_context_ok then
        ts_context.setup({
            enable_autocmd = false,
        })
    end

    -- Setup additional treesitter modules
    local status_ok, configs = pcall(require, "nvim-treesitter.configs")
    if not status_ok then
        return
    end

    configs.setup({
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        parser_install_dir = parser_dir,
        
        -- Enhanced syntax highlighting configuration
        highlight = {
            enable = true,
            disable = function(lang, bufnr)
                -- Disable highlighting for very large files
                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
                return false
            end,
            additional_vim_regex_highlighting = false,
            use_languagetree = true,
        },
        
        indent = {
            enable = true,
            disable = { "yaml" }, -- YAML indentation breaks with treesitter
        },
        
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<CR>",
                node_incremental = "<CR>",
                scope_incremental = "<S-CR>",
                node_decremental = "<BS>",
            },
        },
        
        textobjects = {
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",
                    ["ic"] = "@class.inner",
                    ["as"] = "@statement.outer",
                    ["is"] = "@statement.inner",
                    ["ab"] = "@block.outer",
                    ["ib"] = "@block.inner",
                    ["al"] = "@loop.outer",
                    ["il"] = "@loop.inner",
                    ["ai"] = "@conditional.outer",
                    ["ii"] = "@conditional.inner",
                    ["ap"] = "@parameter.outer",
                    ["ip"] = "@parameter.inner",
                },
                selection_modes = {
                    ["@parameter.outer"] = "v",
                    ["@function.outer"] = "V",
                    ["@class.outer"] = "V",
                },
                include_surrounding_whitespace = false,
            },
            move = {
                enable = true,
                set_jumps = true,
                goto_next_start = {
                    ["]m"] = "@function.outer",
                    ["]]"] = "@class.outer",
                },
                goto_next_end = {
                    ["]M"] = "@function.outer",
                    ["]["] = "@class.outer",
                },
                goto_previous_start = {
                    ["[m"] = "@function.outer",
                    ["[["] = "@class.outer",
                },
                goto_previous_end = {
                    ["[M"] = "@function.outer",
                    ["[]"] = "@class.outer",
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ["<leader>sp"] = "@parameter.inner",
                },
                swap_previous = {
                    ["<leader>sP"] = "@parameter.inner",
                },
            },
        },
        
        ensure_installed = {
            "lua",
            "vim",
            "python",
            "javascript",
            "typescript",
            "tsx",
            "html",
            "css",
            "motoko",
            "java",
            "cpp",
            "c",
            "bash",
            "regex",
            "rust",
            "go",
            "yaml",
            "json",
            "toml",
            "markdown",
            "markdown_inline",
            "dockerfile",
            "gitignore",
            "php",
            "blade",
            "zig",
            "dart",
            "sql",
            "scss",
            "xml",
            "diff",
            "git_rebase",
            "gitcommit",
            "query",
            "comment",        },
    })
end

return M