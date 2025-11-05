---
-- Database keymaps and which-key registration
local M = {}
local wk = require('which-key')

function M.setup()
    wk.add({
        { "<leader>d", group = "Database" },
        { "<leader>ds", "<cmd>DBUI<cr>", desc = "Open DB UI" },
        { "<leader>dq", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
        { "<leader>dr", "<cmd>lua require('profile.languages.dbs.tools').run_sql_on_dev()<cr>", desc = "Run SQL on current line" },
        { "<leader>dm", "<cmd>lua require('profile.languages.dbs.tools')._TOGGLE_MONGOSH()<cr>", desc = "Toggle Mongo shell" },
    })

    -- Visual mode mappings
    vim.api.nvim_set_keymap("v", "<leader>dr", ":<C-U>lua require('profile.languages.dbs.tools').run_sql_on_visual()<CR>",
            { noremap = true, silent = true })
    vim.api.nvim_set_keymap("v", "<leader>sm", ":<C-U>lua require('profile.languages.dbs.tools').SendToMongo()<CR>",
            { noremap = true, silent = true })
end

-- These functions are defined in tools.lua for database operations
-- Placeholder to satisfy the language module structure
function M.lsp(bufnr)
    -- No LSP support for databases
end

function M.dap()
    -- No DAP support for databases
end

return M