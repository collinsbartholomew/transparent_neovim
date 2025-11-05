---
-- Databases tools integration
-- Plugins: vim-dadbod, vim-dadbod-ui, toggleterm
local M = {}

function M.setup()
    -- Toggleterm setup (for psql / mongosh shells)
    local ok_toggle, toggleterm = pcall(require, "toggleterm")
    if ok_toggle and toggleterm and toggleterm.setup then
        toggleterm.setup({
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            open_mapping = [[<c-\>]],
            persist_mode = false,
            shade_terminals = true,
            direction = "horizontal",
        })
    end

    -- keymaps for Dadbod
    vim.api.nvim_set_keymap("n", "<leader>ds", ":DBUI<CR>", { noremap = true, silent = true })       -- open DB UI
    vim.api.nvim_set_keymap("n", "<leader>dq", ":DBUIToggle<CR>", { noremap = true, silent = true }) -- toggle

    -- Postgres example (DO NOT commit credentials)
    -- Use env vars or a separate ~/.db/credentials file in your .gitignore instead of plaintext.
    vim.g.dbs = {
        -- name = connection string
        dev = "postgres://webapp:secret@127.0.0.1:5432/webapp",
        -- example for sqlite
        -- localdb = "sqlite3:///home/you/.local/share/mydb.sqlite",
    }

    -- safer: read from env or file (example using env var)
    local dev_conn = os.getenv("DEV_DATABASE_URL") -- set in your shell or direnv
    if dev_conn then
        vim.g.dbs = { dev = dev_conn }
    end
end

-- run visual selection or current line helpers and mappings
function M.get_visual_selection()
    local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
    local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
    local lines = vim.api.nvim_buf_get_lines(0, csrow - 1, cerow, false)
    if #lines == 0 then
        return ""
    end
    lines[1] = string.sub(lines[1], cscol)
    lines[#lines] = string.sub(lines[#lines], 1, cecol - (cscol - 1))
    return table.concat(lines, "\n")
end

function M.run_sql_on_visual()
    local sql = M.get_visual_selection()
    M.db_execute_on_conn("dev", sql)
end

function M.run_sql_on_dev()
    local sql = vim.fn.getline(".")
    M.db_execute_on_conn("dev", sql)
end

function M.db_execute_on_conn(conn_name, sql)
    if sql == nil or sql == "" then
        vim.notify("No SQL to run", vim.log.levels.WARN)
        return
    end
    -- use :DB <conn> <sql>
    vim.cmd(string.format("DB %s %s", conn_name, vim.fn.shellescape(sql)))
end

-- Mongo: toggleable mongosh terminal (toggleterm)
local ok_term, toggleterm = pcall(require, "toggleterm.terminal")
if ok_term then
    local Terminal = toggleterm.Terminal
    local mongo_term = Terminal:new({
        cmd = "mongosh mongodb://127.0.0.1:27017/mydb",
        hidden = true,
        direction = "horizontal",
        on_open = function(term)
            vim.cmd("startinsert!")
        end,
    })

    function M._TOGGLE_MONGOSH()
        mongo_term:toggle()
    end

    -- send selection or line to mongosh
    function M.SendToMongo()
        local mode = vim.fn.mode()
        local text = ""
        if mode == "v" or mode == "V" then
            local _, srow, scol, _ = unpack(vim.fn.getpos("'<"))
            local _, erow, ecol, _ = unpack(vim.fn.getpos("'>"))
            local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
            lines[1] = string.sub(lines[1], scol)
            lines[#lines] = string.sub(lines[#lines], 1, ecol - (scol - 1))
            text = table.concat(lines, "\n")
        else
            text = vim.api.nvim_get_current_line()
        end

        if not mongo_term:is_open() then
            mongo_term:toggle()
        end
        mongo_term:send(text)
        mongo_term:send("\n")
    end
end

return M