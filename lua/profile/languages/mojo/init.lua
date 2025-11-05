---
-- Mojo Language Integration
-- LSP: mojo-lsp (from Modular)
-- DAP: lldb/codelldb
-- Formatters: mojo format
-- Linters: mojo check
-- Test runner: neotest-mojo (custom)
-- Mason packages: lldb, valgrind
-- See README.md for manual install steps if needed
local M = {}

function M.setup()
    require('profile.languages.mojo.debug').setup()
    require('profile.languages.mojo.tools').setup()
    require('profile.languages.mojo.mappings').setup()
end

return M