-- PHP tools configuration
local M = {}

function M.setup()
    if vim.fn.executable("php") == 0 then
        vim.notify("PHP not found in PATH. Install from https://www.php.net/downloads", vim.log.levels.WARN)
        return
    end
    
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