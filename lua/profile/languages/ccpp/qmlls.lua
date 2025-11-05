--added-by-agent: ccpp-setup 20251020
-- mason: none
-- manual: Requires Qt installation with qmlls in PATH or QT_QMLLS_BIN set

local M = {}

function M.setup()
   -- This module is deprecated. QML LSP (qmlls) is now configured in lspconfig.lua
    -- The configuration is now handled by the main lspconfig.lua file using the new
    -- vim.lsp.config() and vim.lsp.enable() APIs
end

return M