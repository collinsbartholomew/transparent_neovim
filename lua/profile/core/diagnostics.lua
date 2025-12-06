local M = {}

function M.setup()
    -- Modern diagnostic signs
    local signs = {
        Error = "",
        Warn = "",
        Hint = "",
        Info = "",
    }

    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    -- Configure diagnostics display
    vim.diagnostic.config({
        underline = {
            severity = { min = vim.diagnostic.severity.INFO }
        },
        virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
            severity_sort = true,
        },
        signs = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
            style = "minimal",
            format = function(diagnostic)
                if diagnostic.code then
                    return string.format("[%s] %s", diagnostic.code, diagnostic.message)
                end
                return diagnostic.message
            end,
        },
    })

    -- Add better diagnostic navigation
    local function diagnostic_goto(next, severity)
        local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
        severity = severity and vim.diagnostic.severity[severity] or nil
        return function()
            go({ severity = severity })
        end
    end

    -- Setup modern diagnostic keymaps
    vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
    vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
    vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
    vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
    vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
    vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

    -- LSP handlers are configured centrally in profile.lsp.helpers
end

return M