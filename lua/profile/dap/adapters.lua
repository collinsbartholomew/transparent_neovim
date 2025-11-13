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
    if vim.fn.executable("debugpy") == 1 then
        dap.adapters.python = {
            type = "executable",
            command = "debugpy",
            args = { "-m", "debugpy.adapter" },
        }
    end

    -- Go (delve)
    if vim.fn.executable("dlv") == 1 then
        dap.adapters.delve = {
            type = "server",
            port = "${port}",
            executable = {
                command = "dlv",
                args = { "dap", "-l", "127.0.0.1:${port}" },
            },
        }
    end

    -- Node.js
    if vim.fn.executable("node") == 1 then
        dap.adapters.node2 = {
            type = "executable",
            command = "node",
            args = { vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
        }
    end

    -- C# (.NET Core)
    if vim.fn.executable("netcoredbg") == 1 then
        dap.adapters.coreclr = {
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

    -- Java
    -- Note: Java debugging is typically handled by jdtls setup
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

    -- Zig (using codelldb)
    if dap.adapters.codelldb then
        dap.adapters.zig = dap.adapters.codelldb
    end
end

return M