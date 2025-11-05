local M = {}

function M.setup()
    require("profile.lsp.mason").setup()
    require("profile.lsp.lspconfig").setup()
end

return M

