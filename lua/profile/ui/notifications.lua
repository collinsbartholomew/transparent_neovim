local M = {}

function M.setup()
    require("notify").setup({
        background_colour = "#000000",
        fps = 60,
        render = "minimal",
        stages = "fade_in_slide_out",
        timeout = 3000,
        transparency = 100,
        top_down = false,
        max_width = 80,
        max_height = 10,
        on_open = function(win)
            vim.api.nvim_create_autocmd("BufLeave", {
                buffer = vim.api.nvim_win_get_buf(win),
                once = true,
                callback = function()
                    pcall(function()
                        require("notify").dismiss({ id = win })
                    end)
                end,
            })
        end,
    })

    vim.notify = require("notify")

    pcall(function()
        local dressing = require("dressing")
        dressing.setup({
            input = {
                enabled = true,
                default_prompt = "➤ ",
                win_options = {
                    winblend = 0,
                },
                relative = "cursor",
                prefer_width = 40,
                max_width = 60,
                min_width = 20,
            },
            select = {
                enabled = true,
                backend = { "telescope", "builtin" },
                telescope = {
                    layout_config = {
                        width = 0.3,
                        height = 0.4,
                    },
                },
            },
        })
    end)
end

return M
