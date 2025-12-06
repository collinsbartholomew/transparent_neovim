local M = {}

function M.setup()
    -- Defer mason setup slightly to ensure proper initialization order
    vim.schedule(function()
        local mason_ok, mason = pcall(require, "profile.lsp.mason")
        if mason_ok and type(mason) == "table" and type(mason.setup) == "function" then
            mason.setup()
        else
            vim.notify("Failed to setup Mason", vim.log.levels.WARN)
        end
        
        local lspconfig_ok, lspconfig = pcall(require, "profile.lsp.lspconfig")
        if lspconfig_ok and type(lspconfig) == "table" and type(lspconfig.setup) == "function" then
            lspconfig.setup()
        else
            vim.notify("Failed to setup LSP config", vim.log.levels.WARN)
        end
    end)
end

return M
