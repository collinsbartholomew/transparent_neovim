-- Which-key configuration
-- Enhanced keymap visualization and guide

local M = {}

function M.setup()
    local ok, wk = pcall(require, 'which-key')
    if not ok then
        return
    end

    wk.setup({
        preset = 'modern',
        delay = 300,
        triggers = {
            { "<leader>", mode = "n", desc = "leader key" },
        },
        window = {
            border = 'rounded',
            padding = { 2, 2, 2, 2 },
            no_overlap = true,
            title = {
                show = true,
                position = 'center',
            },
            zindex = 1000,
        },
        layout = {
            height = { min = 4, max = 25 },
            width = { min = 20, max = 50 },
            spacing = 3,
            align = 'left',
        },
        keys = {
            scroll_down = '<C-d>',
            scroll_up = '<C-u>',
        },
        sort = { 'local', 'order', 'group', 'alphanum', 'mod' },
        icons = {
            breadcrumb = '»',
            separator = '➜',
            group = '+',
            ellipsis = '…',
            mappings = true,
            colors = true,
        },
        show_disabled = false,
        disabled = {
            buftypes = {},
            filetypes = { 'nofile', 'help' },
        },
    })
end

return M