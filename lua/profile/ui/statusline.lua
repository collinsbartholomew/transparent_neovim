local M = {}

-- Cache tables for storing state
M.lsp_cache = {}
M.lsp_cache_time = {}
M.navic_cache = {}
M.navic_cache_time = {}

function M.setup()
    vim.opt.laststatus = 3 -- Global statusline
    vim.opt.winbar = ""    -- Disable winbar/topbar
    
    -- Clear cache when buffer is deleted
    vim.api.nvim_create_autocmd("BufDelete", {
        callback = function(args)
            M.lsp_cache[args.buf] = nil
            M.lsp_cache_time[args.buf] = nil
            M.navic_cache[args.buf] = nil
            M.navic_cache_time[args.buf] = nil
        end,
    })

    local status_ok, lualine = pcall(require, "lualine")
    if not status_ok then
        return
    end

    local function trailing_whitespace()
        return vim.fn.search([[\s\+$]], 'nwc') ~= 0 and '󰧟' or ''
    end

    local function mixed_indent()
        local space_indent = vim.fn.search([[\v^ +]], 'nwc')
        local tab_indent = vim.fn.search([[\v^\t+]], 'nwc')
        local mixed = (space_indent > 0 and tab_indent > 0)
        local mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], 'nwc')
        return (mixed_same_line ~= 0 or mixed) and '󰉞' or ''
    end

    lualine.setup({
        options = {
            icons_enabled = true,
            component_separators = { left = '│', right = '│' },
            section_separators = { left = '', right = '' },
            theme = {
                normal = {
                    a = { fg = '#89b4fa', bg = 'NONE' },
                    b = { fg = '#a6adc8', bg = 'NONE' },
                    c = { fg = '#cdd6f4', bg = 'NONE' },
                },
                insert = { a = { fg = '#a6e3a1', bg = 'NONE' } },
                visual = { a = { fg = '#f5c2e7', bg = 'NONE' } },
                replace = { a = { fg = '#f38ba8', bg = 'NONE' } },
                command = { a = { fg = '#fab387', bg = 'NONE' } },
            },
            disabled_filetypes = {
                statusline = { "alpha", "dashboard", "neo-tree" },
                winbar = { "alpha", "dashboard", "neo-tree" },
            },
            always_divide_middle = true,
            globalstatus = true,
            refresh = {
                statusline = 1000,
                winbar = 1000,
            },
            padding = 1,
        },
        sections = {
            lualine_a = {
                {
                    'mode',
                    padding = 1,
                    separator = { left = '█', right = '█' },
                    fmt = function(str)
                        -- Cache mode names to avoid repeated substring operations
                        local mode_map = {
                            ['NORMAL'] = 'N',
                            ['INSERT'] = 'I',
                            ['VISUAL'] = 'V',
                            ['V-LINE'] = 'V',
                            ['V-BLOCK'] = 'V',
                            ['COMMAND'] = 'C',
                            ['TERMINAL'] = 'T',
                            ['REPLACE'] = 'R',
                            ['SELECT'] = 'S',
                        }
                        return mode_map[str] or str:sub(1,1)
                    end
                },
            },
            lualine_b = {
                {
                    'branch',
                    icon = '',
                    padding = { left = 1, right = 1 },
                },
                {
                    'diff',
                    symbols = { added = ' ', modified = ' ', removed = ' ' },
                    source = function()
                        local gitsigns = vim.b.gitsigns_status_dict
                        if gitsigns then
                            return {
                                added = gitsigns.added,
                                modified = gitsigns.changed,
                                removed = gitsigns.removed
                            }
                        end
                    end,
                    padding = 1,
                },
                {
                    'diagnostics',
                    sources = { 'nvim_lsp', 'nvim_diagnostic' },
                    sections = { 'error', 'warn', 'info', 'hint' },
                    symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                    update_in_insert = false,
                    always_visible = false,
                    padding = 1,
                },
                {
                    function()
                        local clients = vim.lsp.get_clients()
                        if not clients or next(clients) == nil then
                            return ''
                        end
                        local count = #clients
                        return count > 1 and tostring(count) or ''
                    end,
                    padding = 1,
                    color = { fg = '#61afef' }
                },
            },
            lualine_c = {
                {
                    'filename',
                    file_status = true,
                    path = 1,
                    symbols = {
                        modified = ' ',
                        readonly = ' ',
                        unnamed = '[No Name]',
                        newfile = '[New]',
                    },
                    fmt = (function()
                        local git_root_cache = {}
                        local last_check = {}
                        local cache_time = 5000  -- Cache git root for 5 seconds
                        
                        return function(str)
                            local path = vim.fn.expand('%:p')
                            if vim.fn.winwidth(0) < 90 then
                                return vim.fn.expand('%:t')
                            end
                            
                            local current_time = vim.loop.now()
                            if not git_root_cache[path] or (current_time - (last_check[path] or 0) > cache_time) then
                                -- Only check git root every 5 seconds per path
                                git_root_cache[path] = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
                                last_check[path] = current_time
                            end
                            
                            if git_root_cache[path] and path:find(git_root_cache[path], 1, true) then
                                return path:sub(#git_root_cache[path] + 2)
                            end
                            return str
                        end
                    end)(),
                    padding = 1,
                },
                {
                    function()
                        return require('nvim-navic').get_location()
                    end,
                    cond = function()
                        return package.loaded['nvim-navic'] and
                            require('nvim-navic').is_available()
                    end,
                    padding = 1,
                },
            },
            lualine_x = {
                {
                    'encoding',
                    fmt = string.upper,
                    padding = 1,
                },
                {
                    'fileformat',
                    padding = 1,
                },
                {
                    'filetype',
                    padding = 1,
                },
            },
            lualine_y = {
                {
                    'progress',
                    padding = 1,
                },
            },
            lualine_z = {
                {
                    'location',
                    padding = 1,
                    separator = { left = '█', right = '█' },
                },
                {
                    mixed_indent,
                    padding = 1,
                },
                {
                    trailing_whitespace,
                    padding = 1,
                },
            },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { 'filename' },
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {},
        },
        tabline = {},
        winbar = {},
        extensions = {},
    })

    vim.defer_fn(function()
        local modes = { 'normal', 'insert', 'visual', 'replace', 'command' }
        local sections = { 'a', 'b', 'c', 'x', 'y', 'z' }
        for _, mode in ipairs(modes) do
            for _, section in ipairs(sections) do
                vim.cmd(string.format('highlight lualine_%s_%s ctermbg=NONE guibg=NONE', section, mode))
            end
        end
    end, 100)
end

return M
