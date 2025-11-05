---
-- Mojo keymaps and which-key registration
local M = {}
local wk = require('which-key')

function M.setup()
    wk.add({
        { "<leader>m", group = "Mojo" },
        { "<leader>mo", group = "Mojo" },
        { "<leader>mor", "<cmd>MojoRun<cr>", desc = "Run file" },
        { "<leader>mob", "<cmd>MojoBuild<cr>", desc = "Build project" },
        { "<leader>mot", "<cmd>MojoTest<cr>", desc = "Run tests" },
        { "<leader>mof", "<cmd>MojoFormat<cr>", desc = "Format code" },
        { "<leader>moc", "<cmd>MojoCheck<cr>", desc = "Check code" },
        { "<leader>mob", "<cmd>MojoBench<cr>", desc = "Run benchmarks" },
        { "<leader>mod", "<cmd>MojoDoc<cr>", desc = "Generate documentation" },
        { "<leader>mop", "<cmd>MojoPackage<cr>", desc = "Package project" },
        { "<leader>mom", "<cmd>MojoMemory<cr>", desc = "Memory check" },
        { "<leader>mos", "<cmd>MojoSecurity<cr>", desc = "Security scan" },
    })

    wk.add({
        { "<leader>t", group = "Test" },
        { "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "Run file tests" },
        { "<leader>tt", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run nearest test" },
        { "<leader>to", "<cmd>lua require('neotest').output.open({ enter = true })<cr>", desc = "Show test output" },
        { "<leader>ts", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "Toggle test summary" },
        { "<leader>tc", "<cmd>lua require('neotest').run.run({ strategy = 'dap' })<cr>", desc = "Debug nearest test" },
    })

    wk.add({
        { "<leader>s", group = "Software Eng." },
        { "<leader>se", group = "Mojo" },
        { "<leader>sec", "<cmd>MojoTest<cr>", desc = "Coverage/Test" },
        { "<leader>ser", "<cmd>MojoFormat<cr>", desc = "Reformat" },
        { "<leader>set", "<cmd>MojoTest<cr>", desc = "Test" },
        { "<leader>sel", "<cmd>MojoCheck<cr>", desc = "Lint" },
        { "<leader>ses", "<cmd>MojoSecurity<cr>", desc = "Security scan" },
        { "<leader>sem", "<cmd>MojoMemory<cr>", desc = "Memory check" },
    })
end

function M.lsp(bufnr)
    wk.add({
        { "<leader>lh", "<cmd>lua vim.lsp.buf.hover()<cr>", desc = "Hover", buffer = bufnr },
        { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename", buffer = bufnr },
        { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action", buffer = bufnr },
        { "<leader>ld", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Diagnostics", buffer = bufnr },
        { "<leader>lf", "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", desc = "Format", buffer = bufnr },
        { "<leader>lg", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Go to Definition", buffer = bufnr },
        { "<leader>li", "<cmd>lua vim.lsp.buf.implementation()<cr>", desc = "Implementation", buffer = bufnr },
        { "<leader>ls", "<cmd>lua vim.lsp.buf.document_symbol()<cr>", desc = "Document Symbols", buffer = bufnr },
        { "<leader>lw", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", desc = "Workspace Symbols", buffer = bufnr },
        { "<leader>lt", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "Run CodeLens", buffer = bufnr },
    })
end

function M.dap()
    -- DAP keymaps are now centralized in the main DAP setup
    -- This function is kept for API consistency
end

return M