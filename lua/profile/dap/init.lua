local M = {}

function M.setup()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
        vim.notify("nvim-dap is not available", vim.log.levels.WARN)
        return false
    end

    local dapui_ok, dapui = pcall(require, "dapui")
    if not dapui_ok then
        vim.notify("nvim-dap-ui is not available", vim.log.levels.WARN)
        return false
    end

    -- Load centralized adapter and configuration setups
    local adapters_ok = pcall(require("profile.dap.adapters").setup)
    if not adapters_ok then
        vim.notify("Failed to load DAP adapters", vim.log.levels.WARN)
    end

    local configs_ok = pcall(require("profile.dap.configurations").setup)
    if not configs_ok then
        vim.notify("Failed to load DAP configurations", vim.log.levels.WARN)
    end

    -- Optional: ensure required DAP adapters are installed via mason-nvim-dap
    local mason_dap_ok, mason_dap = pcall(require, "mason-nvim-dap")
    if mason_dap_ok then
        mason_dap.setup({
            ensure_installed = {
                "debugpy",           -- Python
                "delve",            -- Go
                "js-debug-adapter",  -- JavaScript/TypeScript
                "php-debug-adapter", -- PHP
                "codelldb",         -- C/C++/Rust/Zig
                "netcoredbg",       -- C#
            },
            automatic_installation = true,
        })
    end

    dapui.setup()

    dap.listeners.before.attach.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
    end

    local wk = require("which-key")
    wk.add({
        { "<leader>d", group = "Debug" },
        { "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", desc = "Toggle Breakpoint" },
        {
            "<leader>dB",
            "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
            desc = "Conditional Breakpoint",
        },
        { "<leader>dc", "<cmd>lua require('dap').continue()<cr>", desc = "Continue" },
        { "<leader>dC", "<cmd>lua require('dap').run_to_cursor()<cr>", desc = "Run To Cursor" },
        { "<leader>di", "<cmd>lua require('dap').step_into()<cr>", desc = "Step Into" },
        { "<leader>do", "<cmd>lua require('dap').step_over()<cr>", desc = "Step Over" },
        { "<leader>dO", "<cmd>lua require('dap').step_out()<cr>", desc = "Step Out" },
        { "<leader>dr", "<cmd>lua require('dap').repl.toggle()<cr>", desc = "Toggle REPL" },
        { "<leader>dt", "<cmd>lua require('dap').terminate()<cr>", desc = "Terminate" },
        { "<leader>du", "<cmd>lua require('dapui').toggle()<cr>", desc = "Toggle UI" },
    })

    return true
end

return M