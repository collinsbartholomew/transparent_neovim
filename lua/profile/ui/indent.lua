local M = {}

function M.setup()
    require('ibl').setup({
      enabled = true,
      exclude = {
        filetypes = { 'dashboard', 'lazy', 'mason', 'neotree' },
        buftypes = { 'terminal', 'nofile' },
      },

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
    })
    
    -- Add performance optimization for large files
    -- Removed invalid delay parameter that was causing an error
    require("ibl").update({
        enabled = true,
    })
end

return M