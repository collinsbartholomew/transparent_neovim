local M = {}

function M.setup()
    vim.opt.laststatus = 3 -- Global statusline
    vim.opt.winbar = ""    -- Disable winbar/topbar

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
                },
            },
            lualine_b = {
                {
                    'branch',
                    padding = 1,
                },
                {
                    'diff',
                    padding = 1,
                },
                {
                    'diagnostics',
                    padding = 1,
                },
            },
            lualine_c = {
                {
                    'filename',
                    file_status = true,
                    path = 1,
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

    local function make_transparent_borders()
        local modes = { 'normal', 'insert', 'visual', 'replace', 'command' }
        local sections = { 'a', 'b', 'c', 'x', 'y', 'z' }
        for _, mode in ipairs(modes) do
            for _, section in ipairs(sections) do
                vim.cmd(string.format('highlight lualine_%s_%s ctermbg=NONE guibg=NONE', section, mode))
            end
        end
    end

    vim.defer_fn(make_transparent_borders, 100)
end

return M
