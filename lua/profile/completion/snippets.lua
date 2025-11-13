local M = {}

function M.setup()
    -- This module intentionally keeps snippet mappings and configuration
    -- centralized in `luasnip.lua`. Here we only ensure custom snippet
    -- paths are loaded and provide a light-weight reload handler.
    pcall(function()
        require("luasnip.loaders.from_vscode").lazy_load()
    end)
    pcall(function()
        require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets" })
    end)

    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.lua", "*.json", "*.jsonc" },
        callback = function()
            pcall(function()
                require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets" })
            end)
            pcall(function()
                require("luasnip.loaders.from_vscode").lazy_load()
            end)
        end,
    })
end

return M