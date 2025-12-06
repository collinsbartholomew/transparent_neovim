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

    -- Modern fs_stat helper (Neovim 0.9+)
    local function safe_fs_stat(path)
        if not path or path == "" then
            return nil
        end
        local ok, stat = pcall(vim.uv.fs_stat, path)
        return ok and stat or nil
    end

    -- Setup additional treesitter modules
    local status_ok, configs = pcall(require, "nvim-treesitter.configs")
    if not status_ok then
        return
    end

    configs.setup({
        sync_install = false,
        -- Keep installation explicit to reduce startup IO
        auto_install = false,
        ignore_install = {},
        parser_install_dir = parser_dir,
        
        -- Enhanced syntax highlighting configuration
        highlight = {
            enable = true,
            disable = function(lang, bufnr)
                -- Disable highlighting for very large files to preserve responsiveness
                    local max_filesize = 1024 * 1024 -- 1 MB
                local stats = safe_fs_stat(vim.api.nvim_buf_get_name(bufnr))
                if stats and stats.size and stats.size > max_filesize then
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
            -- Essential for most projects
            "lua",
            "vim",
            "python",
            "javascript",
            "typescript",
            "tsx",
            "html",
            "css",
            
            -- Common dev languages
            "java",
            "cpp",
            "c",
            "bash",
            "regex",
            "rust",
            "go",
            
            -- Config files
            "yaml",
            "json",
            "toml",
            "markdown",
            "markdown_inline",
            "dockerfile",
            
            -- Version control
            "gitignore",
            "git_rebase",
            "gitcommit",
            
            -- Others
            "php",
            "sql",
            "xml",
            "diff",
            "comment",
        },
    })
end

return M