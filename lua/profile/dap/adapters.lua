-- lua/profile/dap.lua
-- Centralized DAP adapter configurations
local M = {}

function M.setup()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
        vim.notify("nvim-dap not available", vim.log.levels.WARN)
        return
    end
    -- Codelldb (C/C++/Rust)
    if vim.fn.executable("codelldb") == 1 then
        dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
                command = "codelldb",
                args = { "--port", "${port}" },
            },
        }
    end
    -- Python (debugpy)
    if vim.fn.executable("python") == 1 then
        dap.adapters.python = {
            type = "executable",
            command = "python",
            args = { "-m", "debugpy.adapter" },
        }
    end
    -- Go (delve)
    if vim.fn.executable("dlv") == 1 then
        dap.adapters.go = {
            type = "server",
            port = "${port}",
            executable = {
                command = "dlv",
                args = { "dap", "-l", "127.0.0.1:${port}" },
            },
        }
    end
    -- JavaScript/Node.js (js-debug-adapter)
    if vim.fn.executable("js-debug-adapter") == 1 then
        dap.adapters["pwa-node"] = {
            type = "server",
            host = "127.0.0.1",
            port = "${port}",
            executable = {
                command = "js-debug-adapter",
                args = { "${port}" },
            },
        }
    end
    -- Chrome (using js-debug-adapter for pwa-chrome)
    if vim.fn.executable("js-debug-adapter") == 1 then
        dap.adapters["pwa-chrome"] = {
            type = "server",
            host = "127.0.0.1",
            port = "${port}",
            executable = {
                command = "js-debug-adapter",
                args = { "${port}" },
            },
        }
    end
    -- C# (.NET Core)
    if vim.fn.executable("netcoredbg") == 1 then
        dap.adapters.netcoredbg = {
            type = "executable",
            command = "netcoredbg",
            args = { "--interpreter=vscode" },
        }
    end
    -- PHP
    if vim.fn.executable("php-debug-adapter") == 1 then
        dap.adapters.php = {
            type = "executable",
            command = "php-debug-adapter",
        }
    end
    -- Java (handled by jdtls)
    pcall(function()
        require("jdtls.dap").setup_dap_main_class_configs()
    end)
    -- Dart/Flutter
    if vim.fn.executable("dart") == 1 then
        dap.adapters.dart = {
            type = "executable",
            command = "dart",
            args = { "debug_adapter" },
        }
    end
    -- Zig and Qt/C++ (use codelldb)
    if dap.adapters.codelldb then
        dap.adapters.zig = dap.adapters.codelldb
        dap.adapters.cpp = dap.adapters.codelldb
    end
end

return M
