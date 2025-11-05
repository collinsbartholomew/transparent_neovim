local M = {}

function M.setup()
    local luasnip = require("luasnip")
    
    -- Load VS Code style snippets
    require("luasnip.loaders.from_vscode").lazy_load()
    
    -- Configure LuaSnip
    luasnip.config.setup({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
    })
end

return M