-- Centralized DAP configurations for all supported languages
local M = {}

function M.setup()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
        vim.notify("nvim-dap not available", vim.log.levels.WARN)
        return
    end

    -- Get python path helper
    local function get_python_path()
        local venv = os.getenv("VIRTUAL_ENV")
        if venv then
            return venv .. "/bin/python"
        end
        return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
    end

    -- Initialize configurations table
    dap.configurations = {
        -- Python configurations
        python = {
            {
                type = "python",
                request = "launch",
                name = "Launch file",
                program = "${file}",
                python = get_python_path(),
                console = "integratedTerminal",
            },
            {
                type = "python",
                request = "launch",
                name = "FastAPI",
                module = "uvicorn",
                args = { "main:app", "--reload" },
                python = get_python_path(),
                console = "integratedTerminal",
            },
            {
                type = "python",
                request = "launch",
                name = "Django",
                program = "${workspaceFolder}/manage.py",
                args = { "runserver" },
                python = get_python_path(),
                console = "integratedTerminal",
            },
            {
                type = "python",
                request = "launch",
                name = "pytest",
                module = "pytest",
                args = { "${file}" },
                python = get_python_path(),
                console = "integratedTerminal",
            },
        },

        -- C/C++/Rust configurations (using codelldb)
        cpp = {
            {
                type = "codelldb",
                request = "launch",
                name = "Launch file",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
            },
        },
        c = "${cpp}",
        rust = "${cpp}", -- Note: rustaceanvim handles this differently

        -- Go configurations
        go = {
            {
                type = "delve",
                name = "Debug",
                request = "launch",
                program = "${file}",
            },
            {
                type = "delve",
                name = "Debug test",
                request = "launch",
                mode = "test",
                program = "${file}",
            },
        },

        -- Node.js configurations
        javascript = {
            {
                type = "node2",
                request = "launch",
                name = "Launch file",
                program = "${file}",
                cwd = "${workspaceFolder}",
                sourceMaps = true,
            },
        },
        typescript = "${javascript}",

        -- C# configurations
        cs = {
            {
                type = "coreclr",
                name = "Launch",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
                end,
            },
        },

        -- PHP configurations
        php = {
            {
                type = "php",
                request = "launch",
                name = "Listen for XDebug",
                port = 9000,
            },
        },

        -- Java configurations are handled by jdtls

        -- Dart/Flutter configurations
        dart = {
            {
                type = "dart",
                request = "launch",
                name = "Launch Dart",
                program = "${file}",
                cwd = "${workspaceFolder}",
            },
        },

        -- Zig configurations (using codelldb)
        zig = {
            {
                type = "codelldb",
                request = "launch",
                name = "Launch file",
                program = function()
                    -- Find the executable in zig-out/bin
                    local handle = io.popen("find zig-out/bin -type f -executable")
                    if handle then
                        local result = handle:read("*a")
                        handle:close()
                        if result and result ~= "" then
                            return result:gsub("%s+$", "") -- Trim whitespace
                        end
                    end
                    -- Fallback to manual input
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/zig-out/bin/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
            },
        },
    }

    -- Special case for Rust - let rustaceanvim handle it
    pcall(function()
        require("rustaceanvim").setup_dap()
    end)
end

return M