---
-- Python Language Integration
-- LSP: pyright (Mason)
-- DAP: debugpy (Mason)
-- Formatters: black, ruff, isort (Mason/pipx)
-- Linters: ruff (Mason/pipx)
-- Test runner: neotest-python
-- Mason packages: pyright, debugpy, black, ruff, isort
-- See README.md for manual install steps if needed
local M = {}

function M.setup()
    require('profile.languages.python.debug').setup()
    require('profile.languages.python.tools').setup()
end

return M