-- Which-key configuration
-- Enhanced keymap visualization and guide

local M = {}

function M.setup()
    local ok, wk = pcall(require, 'which-key')
    if not ok then
        vim.notify('which-key.nvim is not available', vim.log.levels.WARN)
        return
    end

    wk.setup({
        preset = 'modern',
        delay = 300,
        popup_mappings = {
            scroll_down = '<c-d>',
            scroll_up = '<c-u>',
        },
        window = {
            border = 'rounded',
            padding = { 2, 2, 2, 2 },
        },
        show_help = false,  -- Disable help to reduce visual clutter
        show_keys = true,   -- Keep keys visible
        win = {
            no_overlap = true,
            padding = { 1, 1 },
            title = true,
            title_pos = 'center',
            zindex = 1000,
            border = 'rounded',
        },
        layout = {
            height = { min = 4, max = 25 },
            width = { min = 20, max = 50 },
            spacing = 3,
            align = 'left',
        },
        keys = {
            scroll_forward = '<C-d>',
            scroll_backward = '<C-u>',
            expand = '<CR>',
            close = 'q',
            next = '<C-n>',
            prev = '<C-p>',
            help = '?',
        },
        sort = { 'local', 'order', 'group', 'alphanum', 'mod' },
        icons = {
            breadcrumb = '»',
            separator = '➜',
            group = '+',
            ellipsis = '…',
            mappings = true,
            colors = true,
            rules = {},
        },
        spec = {},
        replace = {
            desc = {
                { '<Plug>%(.-%)', '' },
                { '^%^', '' },
                { '<[cC]md>', '' },
                { '<[cC]r>', '' },
                { '<[sS]ilent>', '' },
                { '^lua ', '' },
                { '^call ', '' },
                { '^:%s*', '' },
            },
        },
        show_disabled = false,
        disable = {
            bt = {},
            ft = { 'nofile', 'help' },
        },
    })
end

return M
