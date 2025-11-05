-- PHP key mappings
local M = {}

function M.setup()
    -- Setup PHP key mappings
    local status_ok, wk = pcall(require, "which-key")
    if not status_ok then
        return
    end
    
    -- Register PHP key mappings
    wk.register({
        -- PHP general operations
        ["<leader>P"] = {
            name = "PHP",
            f = { "<cmd>lua require('phpactor').navigate('file')<cr>", "Find file" },
            m = { "<cmd>lua require('phpactor').navigate('module')<cr>", "Navigate module" },
            
            -- Composer operations
            c = {
                name = "Composer",
                i = { "<cmd>!composer install<cr>", "Install packages" },
                u = { "<cmd>!composer update<cr>", "Update packages" },
                d = { "<cmd>!composer dump-autoload<cr>", "Dump autoload" },
            },
            
            -- Laravel operations
            l = {
                name = "Laravel",
                a = { "<cmd>lua require('laravel').commands()<cr>", "Artisan commands" },
                r = { "<cmd>lua require('laravel').routes()<cr>", "List routes" },
                e = { "<cmd>lua require('laravel').tinker()<cr>", "Tinker" },
            },
            
            -- PHP testing
            t = {
                name = "Tests",
                t = { "<cmd>TestFile<cr>", "Run test file" },
                n = { "<cmd>TestNearest<cr>", "Run nearest test" },
                s = { "<cmd>TestSuite<cr>", "Run test suite" },
                l = { "<cmd>TestLast<cr>", "Run last test" },
            },
            
            -- PHP refactoring
            r = {
                name = "Refactor",
                a = { "<cmd>lua require('phpactor').refactor()<cr>", "Refactor" },
                e = { "<cmd>lua require('phpactor').context_menu()<cr>", "Context menu" },
            },
        },
    }, {
        mode = "n",
        prefix = "<leader>",
        buffer = nil,
        silent = true,
        noremap = true,
        nowait = true,
    })
end

return M