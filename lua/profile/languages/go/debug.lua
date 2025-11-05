---
-- Go DAP configuration (delve)
-- Mason package: delve
local M = {}

function M.setup()
    local dap_status_ok, dap = pcall(require, "dap")
    if not dap_status_ok then
        vim.notify("nvim-dap not available", vim.log.levels.WARN)
        return
    end

    -- Setup enhanced debug configurations
    -- These will extend the default configurations provided by mason-nvim-dap
    local go_config = {
        {
            type = "go",
            name = "Debug",
            request = "launch",
            program = ".",
        },
        {
            type = "go",
            name = "Debug test",
            request = "launch",
            mode = "test",
            program = ".",
        },
        {
            type = "go",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}",
        },
        {
            type = "go",
            name = "Debug executable",
            request = "launch",
            mode = "exec",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
        },
        {
            type = "go",
            name = "Attach",
            request = "attach",
            processId = require("dap.utils").pick_process,
        },
        {
            type = "go",
            name = "Debug benchmark",
            request = "launch",
            mode = "test",
            program = ".",
            args = {"-test.bench=."},
        },
    }
    
    -- Extend the default configurations with our custom ones
    dap.configurations.go = go_config

    -- Setup dap-go
    local dapgo_status_ok, dapgo = pcall(require, "dap-go")
    if dapgo_status_ok then
        dapgo.setup({
            dap_configurations = {
                {
                    type = "go",
                    name = "Attach remote",
                    mode = "remote",
                    request = "attach",
                },
            },
            delve = {
                path = "dlv",
                initialize_timeout_sec = 20,
                port = "${port}",
                args = {},
                build_flags = "",
            },
        })
    end

    -- Setup DAP UI if available
    local dapui_status_ok, dapui = pcall(require, "dapui")
    if dapui_status_ok then
        -- Auto-open DAP UI when debug session starts
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end

        -- Auto-close DAP UI when debug session ends
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end
    end

    -- Setup virtual text if available
    local virt_text_status_ok, virt_text = pcall(require, "nvim-dap-virtual-text")
    if virt_text_status_ok then
        virt_text.setup({
            display_callback = function(variable)
                return string.format("%s = %s", variable.name, variable.value)
            end,
        })
    end

    require("profile.languages.go.mappings").dap()
end

return M