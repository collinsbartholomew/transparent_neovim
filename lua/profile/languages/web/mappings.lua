-- added-by-agent: web-setup 20251020-173000
-- mason: none
-- manual: none

local M = {}

function M.setup()
    local which_key_status, which_key = pcall(require, "which-key")
    if not which_key_status then
        vim.notify("which-key not available for web mappings", vim.log.levels.WARN)
        return
    end

    which_key.register({
        j = {
            name = "JavaScript/TypeScript",
            a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
            d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Definition" },
            D = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Declaration" },
            e = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Go to Definition" },
            f = { "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", "Format" },
            h = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover" },
            i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Implementation" },
            l = { "<cmd>lua vim.diagnostic.open_float()<cr>", "Line Diagnostics" },
            n = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
            r = { "<cmd>lua require('profile.core.functions').run_npm_script()<cr>", "Run NPM Script" },
            R = { "<cmd>lua vim.lsp.buf.references()<cr>", "References" },
            s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
            t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Type Definition" },
        },
        m = {
            name = "MERN Stack",
            c = { "<cmd>lua _G.web_utils.create_express_route()<cr>", "Create Express Route" },
            d = { "<cmd>lua require('dap').continue()<cr>", "Debug Application" },
            i = { "<cmd>MongoConnect<cr>", "Connect to MongoDB" },
            r = { "<cmd>StartDev<cr>", "Run Dev Server" },
            s = { "<cmd>StartDev<cr>", "Start Server" },
            t = { "<cmd>WebTest<cr>", "Run Tests" },
        },
        w = {
            name = "Web",
            b = { "<cmd>lua _G.web_utils.create_react_component()<cr>", "Create React Component" },
            B = { "<cmd>WebBuild<cr>", "Build Project" },
            c = { "<cmd>lua require('profile.core.functions').run_npm_script()<cr>", "Run NPM Script" },
            C = { "<cmd>lua require('profile.core.functions').run_yarn_script()<cr>", "Run Yarn Script" },
            d = { "<cmd>lua require('dap').continue()<cr>", "Debug Application" },
            f = { "<cmd>WebFormat<cr>", "Format Code" },
            i = { "<cmd>PnpmInstall<cr>", "Install Dependencies (pnpm)" },
            I = { "<cmd>NpmInstall<cr>", "Install Dependencies (npm)" },
            j = { "<cmd>lua require('profile.core.functions').run_npm_script()<cr>", "Run NPM Script" },
            r = { "<cmd>StartDevPnpm<cr>", "Start Dev Server (pnpm)" },
            R = { "<cmd>StartDev<cr>", "Start Dev Server (npm)" },
            s = { "<cmd>lua require('profile.core.functions').run_pnpm_script()<cr>", "Run PNPM Script" },
            t = { "<cmd>lua require('telescope.builtin').find_files({ cwd = 'src' })<cr>", "Find Source Files" },
            T = { "<cmd>WebTest<cr>", "Run Tests" },
        },
        s = {
            name = "Software Engineering",
            e = { "<cmd>lua require('telescope.builtin').diagnostics()<cr>", "Show Diagnostics" },
            f = { "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", "Format File" },
            r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename Symbol" },
            c = { "<cmd>lua require('telescope.builtin').git_status()<cr>", "Git Changes" },
        },
    }, { prefix = "<leader>" })
end

return M