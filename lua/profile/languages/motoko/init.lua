local M = {}

function M.setup()
    -- Set Motoko-specific options
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "motoko",
        callback = function()
            vim.opt_local.commentstring = "// %s"
            vim.opt_local.tabstop = 4
            vim.opt_local.shiftwidth = 4
            vim.opt_local.expandtab = false
        end,
    })

    -- Setup Motoko tools
    local tools_ok, tools = pcall(require, "profile.languages.motoko.tools")
    if tools_ok and tools.setup then
        tools.setup()
    end
end

return M
