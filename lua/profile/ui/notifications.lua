local M = {}

function M.setup()
    require("notify").setup({
        background_colour = "#000000",
        fps = 30,  -- Lower FPS for better performance
        render = "minimal",
        stages = "static",  -- Simpler animation for better performance
        timeout = 3000,
        top_down = false,
        max_width = 80,
        max_height = 10,
        minimum_width = 20,
        icons = {
            ERROR = "",
            WARN = "",
            INFO = "",
            DEBUG = "",
            TRACE = "✎",
        },
        on_open = function(win)
            if not win then return end
            
            -- Auto-dismiss notifications on buffer leave
            vim.api.nvim_create_autocmd("BufLeave", {
                buffer = vim.api.nvim_win_get_buf(win),
                once = true,
                callback = function()
                    pcall(require("notify").dismiss, { id = win })
                end,
            })
            
            -- Ensure proper window options
            pcall(function()
                local win_opts = {
                    winblend = 0,  -- No transparency for better readability
                    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
                }
                vim.api.nvim_win_set_config(win, win_opts)
            end)
        end,
        -- Throttle notifications to prevent spam
        throttle = {
            -- Allow 3 notifications per second max
            max_interval = 333,
            -- Only show one notification at a time in bursts
            max_pending = 1,
        },
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
