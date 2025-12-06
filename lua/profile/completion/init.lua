local M = {}

function M.setup()
    local luasnip_ok, luasnip = pcall(require, "profile.completion.luasnip")
    if luasnip_ok and type(luasnip) == "table" and type(luasnip.setup) == "function" then
        luasnip.setup()
    end
    
    local cmp_ok, cmp = pcall(require, "profile.completion.cmp")
    if cmp_ok and type(cmp) == "table" and type(cmp.setup) == "function" then
        cmp.setup()
    end
end

return M