local M = {}

function M.setup()
    local status_ok, autotag = pcall(require, "nvim-ts-autotag")
    if not status_ok then
        return
    end

    autotag.setup({
        opts = {
            enable_close = true,
            enable_rename = true,
            enable_close_on_slash = false,
        },
    })
end

return M

