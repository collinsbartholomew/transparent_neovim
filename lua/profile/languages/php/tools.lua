-- PHP tools configuration
local M = {}

function M.setup()
    -- Setup Laravel support
    local laravel_status, laravel = pcall(require, "laravel")
    if laravel_status then
        laravel.setup({
            -- Default command to run artisan commands
            default_cmd = "php artisan",
            
            -- Path to the artisan binary
            artisan_path = "artisan",
            
            -- Whether to automatically detect Laravel projects
            auto_detect = true,
        })
    end
end

return M