local M = {}

function M.setup()
    -- Undotree is a simple plugin that doesn't require setup
    -- Configuration is done via vim.g variables if needed
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_ShortIndicators = 1
    vim.g.undotree_SetFocusWhenToggle = 1
end

return M
