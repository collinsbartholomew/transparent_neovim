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
            -- Use the query files from helix-queries in the repo
            generate_requires_npm = false,
            requires_generate_from_grammar = false,
            branch = "main",
        },
        filetype = "motoko",
        -- Point treesitter to use queries from the parser repo's helix-queries folder
        -- This ensures we get the official Motoko syntax highlighting
        query_path = vim.fn.stdpath("data") .. "/treesitter-parsers/tree-sitter-motoko/helix-queries",
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
        -- Playground for debugging and learning Tree-sitter parsers
        playground = {
            enable = true,
            disable = {},
            updatetime = 25,
            persist_queries = false,
            keybindings = {
                toggle_query_editor = "o",
                toggle_hl_groups = "i",
                toggle_injected_languages = "t",
                toggle_anonymous_nodes = "a",
                toggle_language_display = "I",
                focus_language = "f",
                unfocus_language = "F",
                update = "R",
                goto_node = "<cr>",
                show_help = "?",
            },
        },
        -- Parser configuration
        parser_install_dir = parser_dir,
        parser_configs = {
            rust = {
                filter_allowlist = { "rust", "toml" },
            },
            lua = {
                filter_allowlist = { "lua" },
            },
        },
        -- Refactor module for advanced refactoring capabilities
        refactor = {
            highlight_definitions = {
                enable = true,
                clear_on_cursor_move = false,
            },
            highlight_references = {
                enable = true,
                terms_to_highlight = { "@@" },
            },
            smart_rename = {
                enable = true,
                keymaps = {
                    smart_rename = "grr",
                },
            },
            navigation = {
                enable = true,
                keymaps = {
                    goto_definition = "gnd",
                    list_definitions = "gnD",
                    list_definitions_toc = "gO",
                    goto_next_usage = "<a-*>",
                    goto_previous_usage = "<a-#>",
                },
            },
            auto_rename = {
                enable = false,
                exclude = {},
            },
            prompt_telescope = {
                enable = true,
                initial_mode = "insert",
            },
        },
        -- Enable folding via treesitter (this is now handled by ufo)
        fold = { enable = false },
        -- Enhanced syntax highlighting configuration
        highlight = {
            enable = true,
            disable = {},
            additional_vim_regex_highlighting = false,
            use_languagetree = true,
            custom_captures = {},
            indent = { enable = true },
            -- Performance optimizations
            max_file_lines = 50000,
            -- Modern features
            rainbow = {
                enable = true,
                extended_mode = true,
                max_file_lines = 2000,
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
            "comment",
        },
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        indent = {
            enable = true,
            disable = {},
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
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",
                    ["ic"] = "@class.inner",
                    ["ab"] = "@block.outer",
                    ["ib"] = "@block.inner",
                },
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
    })
end

return M
