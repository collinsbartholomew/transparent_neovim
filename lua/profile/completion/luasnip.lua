local M = {}

function M.setup()
    local luasnip = require("luasnip")

    -- Core configuration for LuaSnip
    luasnip.config.setup({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
        delete_check_events = "TextChanged",
    })

    -- Load VSCode snippets with cache
    pcall(function()
        require("luasnip.loaders.from_vscode").lazy_load()
    end)
    
    -- Setup filetype associations for better snippet matching
    pcall(function()
        luasnip.filetype_extend("typescript", { "javascript" })
        luasnip.filetype_extend("typescriptreact", { "typescript", "javascript", "html" })
        luasnip.filetype_extend("javascriptreact", { "javascript", "html" })
        luasnip.filetype_extend("vue", { "html", "javascript", "css" })
        luasnip.filetype_extend("svelte", { "html", "javascript", "css" })
        luasnip.filetype_extend("php", { "html" })
    end)
end

return M