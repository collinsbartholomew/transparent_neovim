---
-- Go Language Integration
-- LSP: gopls (Mason)
-- DAP: delve (Mason)
-- Formatters: gofumpt, goimports (Mason)
-- Linters: staticcheck, golangci-lint (Mason/manual)
-- Test runner: neotest-go
-- Mason packages: gopls, delve, gofumpt, goimports, staticcheck
-- See README.md for manual install steps if needed
local M = {}

function M.setup()
    require("profile.languages.go.debug").setup()
    require("profile.languages.go.tools").setup()
end

return M