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

    -- Configure DAP handlers
    local handlers = {
        -- Python handler
        debugpy = function(config)
            require("mason-nvim-dap.mappings.source").python(config)
        end,

        -- Java handler
        ["java-debug"] = function(config)
            require("mason-nvim-dap.mappings.source").java(config)
        end,

        -- C/C++ handler
        cppdbg = function(config)
            require("mason-nvim-dap.mappings.source").cppdbg(config)
        end,

        -- Go handler
        delve = function(config)
            require("mason-nvim-dap.mappings.source").go(config)
        end,

        -- JavaScript/TypeScript handler
        chrome = function(config)
            require("mason-nvim-dap.mappings.source").chrome(config)
        end,
        node2 = function(config)
            require("mason-nvim-dap.mappings.source").node2(config)
        end,

        -- C# handler
        netcoredbg = function(config)
            require("mason-nvim-dap.mappings.source").netcoredbg(config)
        end,

        -- PHP handler
        ["php-debug"] = function(config)
            require("mason-nvim-dap.mappings.source").php(config)
        end,

        -- Dart/Flutter handler
        ["dart-debug"] = function(config)
            require("mason-nvim-dap.mappings.source").dart(config)
        end,
    }

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