-- Rust Language Module
-- LSP: rust-analyzer
-- Mason: rust-analyzer, codelldb
local M = {}

function M.setup()
    -- Note: LSP setup is now handled in lspconfig.lua
    require('profile.languages.rust.debug').setup()
    require('profile.languages.rust.tools').setup()
end

return M