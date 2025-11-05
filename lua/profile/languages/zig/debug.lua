-- added-by-agent: zig-setup 20251020
local M = {}

function M.setup()
    -- Check for DAP availability
    local has_dap, dap = pcall(require, "dap")
    if not has_dap then
        vim.notify("DAP is not available", vim.log.levels.WARN)
        return
    end

    -- Configure enhanced Zig debugging configurations
    local zig_config = {
        {
            name = "Launch Zig Program",
            type = "codelldb",
            request = "launch",
            program = function()
                local build_zig = vim.fn.findfile('build.zig', '.;')
                if build_zig ~= '' then
                    -- If build.zig exists, use zig build
                    local target = vim.fn.input('Build target (or empty for default): ', '')
                    if target ~= '' then
                        return vim.fn.input('Path to executable: ', './zig-out/bin/' .. target, 'file')
                    else
                        -- Try to find default executable
                        local files = vim.fn.glob('./zig-out/bin/*', false, true)
                        if #files > 0 then
                            return vim.fn.input('Path to executable: ', files[1], 'file')
                        else
                            return vim.fn.input('Path to executable: ', './zig-out/bin/', 'file')
                        end
                    end
                else
                    -- No build.zig, compile current file
                    local file = vim.fn.expand('%:p')
                    if vim.fn.filereadable(file) == 1 and vim.bo.filetype == 'zig' then
                        local output = vim.fn.fnamemodify(file, ':r')
                        vim.fn.system({'zig', 'build-exe', file})
                        return output
                    else
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end
                end
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            runInTerminal = false,
            console = "internalConsole",
            args = function()
                return vim.split(vim.fn.input('Arguments: ', ""), " ")
            end,
        },
        {
            name = "Debug Zig Tests",
            type = "codelldb",
            request = "launch",
            program = function()
                -- Build tests
                vim.fn.system({'zig', 'build-exe', '--test', vim.fn.expand('%:p')})
                local test_file = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':r') .. '.test'
                return test_file
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            runInTerminal = false,
            console = "internalConsole",
            args = { "--listen=-" },
        },
        {
            name = "Attach to Process",
            type = "codelldb",
            request = "attach",
            pid = require('dap.utils').pick_process,
            args = {},
        },
        {
            name = "Debug Current File",
            type = "codelldb",
            request = "launch",
            program = function()
                local file = vim.fn.expand('%:p:r')
                vim.fn.system('zig build-exe ' .. vim.fn.expand('%:p'))
                return file
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            runInTerminal = false,
        }
    }

    -- Apply the configurations
    dap.configurations.zig = zig_config

    -- Load DAP UI if available
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

    -- Load virtual text if available
    local virt_text_status_ok, virt_text = pcall(require, "nvim-dap-virtual-text")
    if virt_text_status_ok then
        virt_text.setup()
    end
end

return M