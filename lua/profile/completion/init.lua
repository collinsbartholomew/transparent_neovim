local M = {}

function M.setup()
    require("profile.completion.luasnip").setup()
    require("profile.completion.cmp").setup()
end

return M