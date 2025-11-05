-- PHP language support
local M = {}

function M.setup()
    -- Setup autocommands for PHP files
    vim.api.nvim_create_augroup("PHP", { clear = true })

    
    -- Set PHP-specific options
    vim.api.nvim_create_autocmd("FileType", {
        group = "PHP",
        pattern = "php,blade",
        callback = function()
            -- Set tabstop and shiftwidth to 4 for PHP (PSR-12)
            vim.opt_local.tabstop = 4
            vim.opt_local.shiftwidth = 4
            vim.opt_local.expandtab = true
            
            -- Enable matchparen for better parenthesis matching
            vim.opt_local.matchpairs:append("<:>")
        end,
    })
end

return M