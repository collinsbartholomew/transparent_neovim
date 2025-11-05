local M = {}

function M.setup()
    require("ibl").setup({
        indent = {
            char = "│",
            tab_char = "│",
            highlight = "IblIndent",
            smart_indent_cap = true,
        },
        whitespace = {
            highlight = "IblWhitespace",
            remove_blankline_trail = true,
        },
        scope = {
            enabled = false,
        },
        exclude = {
            filetypes = {
                "Trouble",
                "alpha",
                "dashboard",
                "help",
                "lazy",
                "mason",
                "neo-tree",
                "notify",
                "trouble",
            },
            buftypes = {
                "nofile",
                "prompt",
                "quickfix",
                "terminal",
            },
        },
    })
end

return M
