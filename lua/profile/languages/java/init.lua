-- added-by-agent: java-setup 20251020-163000
-- mason: jdtls
-- manual: java-debug and vscode-java-test bundle build steps

local M = {}

function M.setup(config)
    -- Idempotency check
    if _G.java_setup_done then
        return true
    end

    -- Load all Java modules
    -- Note: LSP setup is now handled in lspconfig.lua
    require('profile.languages.java.dap').setup(config)
    require('profile.languages.java.tools').setup(config)

    _G.java_setup_done = true
    return true
end

return M