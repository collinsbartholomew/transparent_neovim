-- added-by-agent: java-setup 20251020-163000
-- mason: jdtls
-- manual: java-debug and vscode-java-test bundle build steps

local M = {}

function M.get_bundles()
    local java_debug_root = vim.fn.stdpath('data') .. '/java_debug'
    local bundles = {}

    -- Check if java-debug bundle exists
    local java_debug_jar = java_debug_root .. '/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar'
    local java_test_jar = java_debug_root .. '/vscode-java-test/server/*.jar'

    -- Find actual jar files
    local java_debug_jars = vim.fn.glob(java_debug_jar, true, true)
    local java_test_jars = vim.fn.glob(java_test_jar, true, true)

    -- Add found jars to bundles
    for _, jar in ipairs(java_debug_jars) do
        if vim.fn.filereadable(jar) == 1 then
            table.insert(bundles, jar)
        end
    end

    for _, jar in ipairs(java_test_jars) do
        if vim.fn.filereadable(jar) == 1 then
            table.insert(bundles, jar)
        end
    end

    -- Only show warning if we're actually trying to debug Java
    -- The warning will be shown when Java debugging is actually attempted
    -- if #bundles == 0 then
    --     vim.notify("Java debug bundles not found. Debug functionality will be limited.", vim.log.levels.WARN)
    -- end

    return bundles
end

function M.setup(config)
    config = config or {}

    local dap_status, dap = pcall(require, "dap")
    if not dap_status then
        vim.notify("nvim-dap not available for Java debug setup", vim.log.levels.WARN)
        return
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

    -- Get bundles
    local bundles = M.get_bundles()

    -- Setup enhanced Java debug configurations
    local java_config = {
        {
            type = 'java',
            request = 'launch',
            name = 'Debug (Attach) - Remote',
            hostName = '127.0.0.1',
            port = 5005,
        },
        {
            type = 'java',
            request = 'launch',
            name = 'Debug Main Class',
            mainClass = function()
                return vim.fn.input('Main class: ', '', 'file')
            end,
            projectName = function()
                local root_dir = vim.fn.getcwd()
                return vim.fn.fnamemodify(root_dir, ':t')
            end,
        },
        {
            type = 'java',
            request = 'launch',
            name = 'Debug (Attach) - Remote Host',
            hostName = function()
                return vim.fn.input('Host: ', 'localhost', 'file')
            end,
            port = function()
                return tonumber(vim.fn.input('Port: ', '5005'))
            end,
        },
        {
            type = 'java',
            request = 'launch',
            name = 'Debug JUnit Test',
            mainClass = 'org.junit.runner.JUnitCore',
            args = function()
                return vim.fn.input('Test class: ', '', 'file')
            end,
            projectName = function()
                local root_dir = vim.fn.getcwd()
                return vim.fn.fnamemodify(root_dir, ':t')
            end,
        },
        {
            type = 'java',
            request = 'launch',
            name = 'Debug with Arguments',
            mainClass = function()
                return vim.fn.input('Main class: ', '', 'file')
            end,
            args = function()
                return vim.fn.input('Program arguments: ')
            end,
            projectName = function()
                local root_dir = vim.fn.getcwd()
                return vim.fn.fnamemodify(root_dir, ':t')
            end,
        }
    }
    
    -- Extend the default configurations with our custom ones
    dap.configurations.java = java_config

    -- Register DAP keymaps
    require("profile.languages.java.mappings").dap()
    
    -- Only show the warning if we actually need Java debugging and bundles are missing
    if #bundles == 0 and dap.configurations.java then
        vim.notify("Java debug bundles not found. Debug functionality will be limited. Install with :MasonInstall java-debug-adapter", vim.log.levels.WARN)
    end
end

return M