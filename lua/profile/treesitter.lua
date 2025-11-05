local M = {}

function M.setup()
    local install_status, install = pcall(require, 'nvim-treesitter.install')
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
            branch = "main",
        },
        filetype = "motoko",
    }

    local ts_context_ok, ts_context = pcall(require, 'ts_context_commentstring')
    if ts_context_ok then
        ts_context.setup({
            enable_autocmd = false,
        })
    end

    -- Setup additional treesitter modules
    local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
    if not status_ok then
        return
    end

    configs.setup({
        -- Playground for debugging and learning Tree-sitter parsers
        playground = {
            enable = true,
            disable = {},
            updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
            persist_queries = false, -- Whether the query persists across vim sessions
            keybindings = {
                toggle_query_editor = 'o',
                toggle_hl_groups = 'i',
                toggle_injected_languages = 't',
                toggle_anonymous_nodes = 'a',
                toggle_language_display = 'I',
                focus_language = 'f',
                unfocus_language = 'F',
                update = 'R',
                goto_node = '<cr>',
                show_help = '?',
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
                terms_to_highlight = {"@@"},
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
    })

    require('nvim-treesitter.configs').setup({
        -- Enable folding based on syntax structure
        fold = {
            enable = true,
        },
        ensure_installed = {
            'lua',
            'vim',
            'python',
            'javascript',
            'typescript',
            'tsx',
            'html',
            'css',
            'java',
            'cpp',
            'c',
            'bash',
            'regex',
            'rust',
            'go',
            'yaml',
            'json',
            'toml',
            'markdown',
            'markdown_inline',
            'dockerfile',
            'gitignore',
            'php',
            'blade',
            'zig',
            'dart',
            'sql',
            'scss',
            'xml',
            'diff',
            'git_rebase',
            'gitcommit',
            'query',
            'comment',
        },
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = {
            enable = true,
            disable = {},
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = '<CR>',
                node_incremental = '<CR>',
                scope_incremental = '<S-CR>',
                node_decremental = '<BS>',
            },
        },
        textobjects = {
            -- Additional textobjects for more precise selection
            repeat_select = {
                enable = true,
                keymaps = {
                    [';a'] = '@parameter.outer',
                    [';f'] = '@function.outer',
                    [';c'] = '@class.outer',
                },
            },
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@class.outer',
                    ['ic'] = '@class.inner',
                    ['ab'] = '@block.outer',
                    ['ib'] = '@block.inner',
                },
            },
            move = {
                enable = true,
                set_jumps = true,
                goto_next_start = {
                    [']m'] = '@function.outer',
                    [']]'] = '@class.outer',
                },
                goto_next_end = {
                    [']M'] = '@function.outer',
                    [']['] = '@class.outer',
                },
                goto_previous_start = {
                    ['[m'] = '@function.outer',
                    ['[['] = '@class.outer',
                },
                goto_previous_end = {
                    ['[M'] = '@function.outer',
                    ['[]'] = '@class.outer',
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ['<leader>sp'] = '@parameter.inner',
                },
                swap_previous = {
                    ['<leader>sP'] = '@parameter.inner',
                },
            },
        },
    })
end

return M
