--added-by-agent: java-setup 20251020-163000
-- mason: jdtls
-- manual: java-debug and vscode-java-test bundle build steps

local M = {}

function M.setup(config)
    --This module is deprecated. Java LSP (jdtls) is now configured in lspconfig.lua
    -- The configuration is now handled by the main lspconfig.lua file using the new
    -- vim.lsp.config() and vim.lsp.enable() APIs
    --
    -- For Java-specific features, jdtls should be configured separately if needed
end

return M