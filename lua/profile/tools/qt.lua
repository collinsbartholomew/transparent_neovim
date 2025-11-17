-- Qt/QML Build and Development Tools
local M = {}

function M.setup()
    -- Build Qt project with CMake
    vim.api.nvim_create_user_command("QtBuild", function()
        local generator = vim.fn.executable("ninja") == 1 and "Ninja" or "Unix Makefiles"
        local build_dir = vim.fn.getcwd() .. "/build"
        vim.fn.mkdir(build_dir, "p")
        vim.cmd("!cd " .. build_dir .. " && cmake -G '" .. generator .. "' .. && " .. (generator == "Ninja" and "ninja" or "make"))
    end, { desc = "Build Qt project" })

    -- Run Qt application
    vim.api.nvim_create_user_command("QtRun", function()
        local app_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        local app_path = vim.fn.getcwd() .. "/build/" .. app_name
        if vim.fn.executable(app_path) == 1 then
            vim.cmd("!" .. app_path)
        else
            vim.notify("Executable not found: " .. app_path, vim.log.levels.WARN)
        end
    end, { desc = "Run Qt application" })

    -- Generate compile_commands.json for clangd
    vim.api.nvim_create_user_command("QtCompdb", function()
        local build_dir = vim.fn.getcwd() .. "/build"
        vim.fn.mkdir(build_dir, "p")
        vim.cmd("!cd " .. build_dir .. " && cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..")
    end, { desc = "Generate compile_commands.json" })

    -- QML hot reload
    vim.api.nvim_create_user_command("QtHotReload", function()
        if vim.fn.executable("watchexec") == 0 then
            vim.notify("watchexec not installed", vim.log.levels.WARN)
            return
        end
        local qml_file = vim.fn.expand("%:p")
        vim.cmd("terminal watchexec -r -e qml -- qmlscene " .. qml_file)
    end, { desc = "QML hot reload" })
end

return M
