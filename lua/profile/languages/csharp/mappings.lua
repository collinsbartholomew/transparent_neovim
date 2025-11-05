-- added-by-agent: csharp-setup 20251020-153000
-- mason: none
-- manual: none

local M = {}

function M.setup()
    local whichkey_ok, wk = pcall(require, "which-key")
    if not whichkey_ok then
        vim.notify("which-key not available for C# mappings", vim.log.levels.WARN)
        return
    end

    wk.register({
        c = {
            name = "C#",
            s = {
                name = "C#",
                b = { "<cmd>DotnetBuild<cr>", "Build project" },
                t = { "<cmd>DotnetTest<cr>", "Run tests" },
                r = { "<cmd>DotnetRun<cr>", "Run project" },
                f = { "<cmd>DotnetFormat<cr>", "Format code" },
                w = { "<cmd>DotnetWatch<cr>", "Watch project" },
                p = { "<cmd>DotnetPublish<cr>", "Publish project" },
                c = { "<cmd>DotnetClean<cr>", "Clean project" },
                R = { "<cmd>DotnetRestore<cr>", "Restore packages" },
            },
            g = {
                name = "Game/Unity",
                b = { "<cmd>DotnetBuild -c Release -o Build<cr>", "Build Unity project" },
                r = { "<cmd>DotnetRun --project Unity<cr>", "Run Unity project" },
                p = { "<cmd>DotnetPublish -c Release -r win-x64 --self-contained<cr>", "Publish Unity (Windows)" },
            },
            g = {
                name = "GUI",
                b = { "<cmd>DotnetBuild -c Release -o Build<cr>", "Build GUI project" },
                r = { "<cmd>DotnetRun --project GUI<cr>", "Run GUI project" },
                w = { "<cmd>DotnetWatch --project GUI<cr>", "Watch GUI project" },
                p = { "<cmd>DotnetPublish -c Release -r win-x64 --self-contained<cr>", "Publish GUI (Windows)" },
                m = { "<cmd>DotnetPublish -c Release -r osx-x64 --self-contained<cr>", "Publish GUI (macOS)" },
                l = { "<cmd>DotnetPublish -c Release -r linux-x64 --self-contained<cr>", "Publish GUI (Linux)" },
            },
            b = {
                name = "Backend",
                b = { "<cmd>DotnetBuild<cr>", "Build backend" },
                r = { "<cmd>DotnetRun<cr>", "Run backend" },
                w = { "<cmd>DotnetWatch<cr>", "Watch backend" },
                m = { "<cmd>DotnetRun --project Migrations<cr>", "Run migrations" },
                s = { "<cmd>DotnetRun --project Migrations -- update-database<cr>", "Update database" },
            },
            p = {
                name = "Packages",
                a = { "<cmd>DotnetAddPackage<cr>", "Add package" },
                r = { "<cmd>DotnetRemovePackage<cr>", "Remove package" },
                l = { "<cmd>DotnetListPackages<cr>", "List packages" },
                o = { "<cmd>DotnetOutdated<cr>", "List outdated packages" },
                v = { "<cmd>DotnetVulnerabilities<cr>", "Check vulnerabilities" },
            },
            m = {
                name = "Memory/Performance",
                t = { "<cmd>DotnetTrace<cr>", "Collect trace" },
                c = { "<cmd>DotnetCounters<cr>", "Monitor counters" },
            },
        },
        o = {
            name = "OmniSharp",
            r = { "<cmd>OmniReload<cr>", "Reload OmniSharp" },
            p = { "<cmd>lua require('telescope.builtin').find_files({prompt_title='Projects', cwd=vim.fn.getcwd(), hidden=false})<cr>", "Pick project" },
        },
        s = {
            name = "Software Eng.",
            e = {
                name = "C#",
                c = { "<cmd>DotnetTest --collect:\"XPlat Code Coverage\"<cr>", "Coverage" },
                r = { "<cmd>DotnetFormat<cr>", "Reformat" },
                t = { "<cmd>DotnetTest<cr>", "Test" },
                f = { "<cmd>DotnetRestore<cr>", "Restore packages" },
                l = { "<cmd>DotnetBuild<cr>", "Lint/Build" },
            },
        },
    }, { prefix = "<leader>" })
end

function M.lsp(bufnr)
    local whichkey_ok, wk = pcall(require, "which-key")
    if not whichkey_ok then
        return
    end

    wk.register({
        ["<leader>lh"] = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover" },
        ["<leader>lr"] = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
        ["<leader>la"] = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
        ["<leader>ld"] = { "<cmd>lua vim.diagnostic.open_float()<CR>", "Diagnostics" },
        ["<leader>lf"] = { "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", "Format" },
        ["<leader>lg"] = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Go to Definition" },
        ["<leader>li"] = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation" },
        ["<leader>ls"] = { "<cmd>lua vim.lsp.buf.document_symbol()<CR>", "Document Symbols" },
        ["<leader>lw"] = { "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", "Workspace Symbols" },
        ["<leader>lt"] = { "<cmd>lua vim.lsp.codelens.run()<CR>", "Run CodeLens" },
    }, { buffer = bufnr })
end

function M.dap()
    -- DAP keymaps are now centralized in the main DAP setup
    -- This function is kept for API consistency
end

return M