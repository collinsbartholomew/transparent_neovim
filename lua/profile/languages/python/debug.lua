---
-- Python DAP configuration (debugpy)
-- Mason package: debugpy
local M = {}

function M.setup()
    local dap_ok, dap = pcall(require, "dap")
    local dapui_ok, dapui = pcall(require, "dapui")
    local mason_dap_ok, mason_dap = pcall(require, "mason-nvim-dap")
    local virt_text_status_ok, virt_text = pcall(require, "nvim-dap-virtual-text")

    if not (dap_ok and dapui_ok and mason_dap_ok) then
        return
    end

    -- Setup virtual text if available
    if virt_text_status_ok then
        virt_text.setup({
            display_callback = function(variable)
                return string.format("%s = %s", variable.name, variable.value)
            end,
        })
    end

    -- Register dapui hooks (moved to main dap setup)
    -- Configuration is now handled by mason-nvim-dap
    
    -- Setup enhanced Python debug configurations
    -- These will extend the default configurations provided by mason-nvim-dap
    local python_config = {
        {
            type = "python",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            python = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                else
                    return "python"
                end
            end,
        },
        {
            type = "python",
            request = "launch",
            name = "Launch module",
            module = function()
                return vim.fn.input("Module: ", "", "file")
            end,
            python = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                else
                    return "python"
                end
            end,
        },
        {
            type = "python",
            request = "launch",
            name = "Launch Flask",
            module = "flask",
            env = {
                FLASK_APP = function()
                    return vim.fn.input("Flask App: ", "app.py", "file")
                end,
                FLASK_ENV = "development",
                FLASK_DEBUG = "1",
            },
            python = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                else
                    return "python"
                end
            end,
        },
        {
            type = "python",
            request = "launch",
            name = "Launch FastAPI",
            module = "uvicorn",
            args = { "main:app", "--reload" },
            python = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                else
                    return "python"
               end
            end,
        },
        {
            type = "python",
            request = "launch",
            name = "Launch Django",
            program = function()
                return vim.fn.input("Manage.py path: ", "manage.py", "file")
            end,
            args = { "runserver" },
            python = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                else
                    return "python"
                end
            end,
        },
        {
            type = "python",
            request = "launch",
            name = "Launch pytest",
            module = "pytest",
            args = { "-x", "-v", "${file}" },
            python = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                else
                    return "python"
                end
            end,
        },
        {
            type = "python",
            request = "attach",
            name = "Attach to process",
            connect = {
                host = "127.0.0.1",
                port = 5678,
            },
            python = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                else
                    return "python"
                end
            end,
        },
    }
    
    -- Extend the default configurations with our custom ones
    dap.configurations.python = python_config

    require('profile.languages.python.mappings').dap()
end

return M