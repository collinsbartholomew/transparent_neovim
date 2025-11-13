local M = {}

function M.setup()
    local luasnip = require("luasnip")

    -- Core configuration for LuaSnip
    luasnip.config.setup({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
        delete_check_events = "TextChanged",
        ext_opts = {
            [require("luasnip.util.types").choiceNode] = {
                active = { virt_text = { { "●", "DiagnosticSignInfo" } } },
            },
            [require("luasnip.util.types").insertNode] = {
                active = { virt_text = { { "●", "DiagnosticSignHint" } } },
            },
        },
    })

    -- Optimize snippet loading
    pcall(function()
        -- Load snippets lazily with cache
        require("luasnip.loaders").lazy_load({
            paths = { vim.fn.stdpath("config") .. "/snippets" },
            include = nil,  -- Load all snippet files
            exclude = {},
        })
        
        -- Load VSCode snippets with cache
        require("luasnip.loaders.from_vscode").lazy_load({
            -- Load only when needed
            paths = nil,
            exclude = {},
            include = nil,
        })
    end)
    
    -- Setup filetype associations for better snippet matching
    local ft_functions = {
        typescript = function()
            luasnip.filetype_extend("typescript", { "javascript" })
            luasnip.filetype_extend("typescriptreact", { "typescript", "javascript", "html" })
        end,
        javascript = function()
            luasnip.filetype_extend("javascript", { "html" })
            luasnip.filetype_extend("javascriptreact", { "javascript", "html" })
        end,
        vue = function()
            luasnip.filetype_extend("vue", { "html", "javascript", "css" })
        end,
        svelte = function()
            luasnip.filetype_extend("svelte", { "html", "javascript", "css" })
        end,
        php = function()
            luasnip.filetype_extend("php", { "html" })
        end,
    }
    
    -- Load filetype extensions on demand
    vim.api.nvim_create_autocmd("FileType", {
        pattern = vim.tbl_keys(ft_functions),
        callback = function(event)
            local ft = event.match
            if ft_functions[ft] then
                ft_functions[ft]()
            end
        end,
    })
end

return M