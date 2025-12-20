-- Which-key configuration
local M = {}

function M.setup()
    local ok, wk = pcall(require, "which-key")
    if not ok then
        return
    end

    wk.setup({
        preset = "modern",
        delay = 300,
        win = {
            no_overlap = true,
            padding = { 1, 2 },
            title_pos = "left",
            border = "rounded",
        },
        layout = {
            height = { min = 4, max = 25 },
            width = { min = 20, max = 50 },
            spacing = 2,
        },
        icons = {
            breadcrumb = "»",
            separator = "➜",
            group = "+",
        },
        show_help = false,
        show_keys = true,
    })
end

return M