-- added-by-agent: rust-setup 20251020
local M = {}
local wk_status_ok, wk = pcall(require, 'which-key')
if not wk_status_ok then
    vim.notify("which-key not available", vim.log.levels.WARN)
    return
end

function M.setup()
    wk.register({
        r = {
            name = 'Rust',
            r = { '<cmd>RustRunnables<CR>', 'Runnables' },
            t = { function()
                local neotest_ok, neotest = pcall(require, 'neotest')
                if neotest_ok then
                    neotest.run.run(vim.fn.expand('%'))
                end
            end, 'Run tests in file' },
            d = { function()
                local dap_ok, dap = pcall(require, 'dap')
                if dap_ok then
                    dap.continue()
                end
            end, 'Debug (DAP continue)' },
            c = { '<cmd>CargoClippy<CR>', 'Cargo clippy' },
            f = { function()
                local conform_ok, conform = pcall(require, 'conform')
                if conform_ok then
                    conform.format()
                end
            end, 'Format buffer' },
            e = { '<cmd>CargoExpand<CR>', 'Expand macros' },
            h = { '<cmd>RustHoverActions<CR>', 'Hover actions' },
            v = { '<cmd>CargoCheck<CR>', 'Cargo check' },
        },
        c = {
            name = 'Cargo',
            b = { '<cmd>CargoBuild<CR>', 'Build' },
            r = { '<cmd>CargoRun<CR>', 'Run' },
            t = { '<cmd>CargoTest<CR>', 'Test' },
            c = { '<cmd>CargoCheck<CR>', 'Check' },
            f = { '<cmd>CargoFmt<CR>', 'Format' },
            d = { '<cmd>CargoDoc<CR>', 'Documentation' },
            a = { '<cmd>CargoAudit<CR>', 'Audit' },
            e = { '<cmd>CargoExpand<CR>', 'Expand' },
            v = { '<cmd>CargoValgrind<CR>', 'Valgrind' },
            l = { '<cmd>CargoCoverage<CR>', 'Coverage' },
            B = { '<cmd>CargoBench<CR>', 'Benchmark' },
        },
        s = {
            name = 'Software Eng.',
            e = { 
                name = 'Rust',
                c = { '<cmd>CargoCoverage<CR>', 'Coverage' },
                r = { '<cmd>CargoFmt<CR>', 'Reformat' },
                t = { '<cmd>CargoTest<CR>', 'Test' },
                a = { '<cmd>CargoAudit<CR>', 'Audit' },
                d = { '<cmd>CargoDoc<CR>', 'Documentation' },
            },
        },
    }, { prefix = '<leader>' })
end

function M.lsp(bufnr)
    wk.register({
        ['<leader>lh'] = { function()
            vim.lsp.buf.hover()
        end, 'Hover' },
        ['<leader>lr'] = { function()
            vim.lsp.buf.rename()
        end, 'Rename' },
        ['<leader>la'] = { function()
            vim.lsp.buf.code_action()
        end, 'Code Action' },
        ['<leader>ld'] = { function()
            vim.diagnostic.open_float()
        end, 'Diagnostics' },
        ['<leader>lf'] = { function()
            require('conform').format()
        end, 'Format' },
        ['<leader>lg'] = { function()
            require('rust-tools.inlay_hints').toggle_inlay_hints()
        end, 'Toggle Inlay Hints' },
        ['<leader>le'] = { function()
            require('rust-tools.expand_macro').expand_macro()
        end, 'Expand Macro' },
        ['<leader>lm'] = { function()
            require('rust-tools.parent_module').parent_module()
        end, 'Parent Module' },
        ['<leader>ls'] = { function()
            require('rust-tools.join_lines').join_lines()
        end, 'Join Lines' },
    }, { buffer = bufnr })
end

return M