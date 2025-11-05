-- added-by-agent: flutter-setup 20251020-160000
-- mason: dart-debug-adapter
-- manual: flutter/dart/fvm install commands listed in README

local M = {}

function M.setup()
    local whichkey_status, wk = pcall(require, "which-key")
    if not whichkey_status then
        vim.notify("which-key not available for Flutter mappings", vim.log.levels.WARN)
        return
    end

    wk.register({
        f = {
            name = "Flutter",
            r = {
                name = "Run",
                f = { "<cmd>FlutterRun<cr>", "Run Flutter App" },
                d = { "<cmd>FlutterRunDev<cr>", "Run Dev Flavor" },
                p = { "<cmd>FlutterRunProd<cr>", "Run Prod Flavor" },
                h = { "<cmd>FlutterReload<cr>", "Hot Reload" },
                R = { "<cmd>FlutterRestart<cr>", "Full Restart" },
            },
            t = {
                name = "Test",
                t = { "<cmd>FlutterTest<cr>", "Run Tests" },
                w = { "<cmd>FlutterTestWatch<cr>", "Watch Tests" },
                c = { "<cmd>FlutterTestCoverage<cr>", "Test Coverage" },
            },
            b = {
                name = "Build",
                b = { "<cmd>FlutterBuild<cr>", "Build App" },
                a = { "<cmd>FlutterBuild apk<cr>", "Build APK" },
                A = { "<cmd>FlutterBuild appbundle<cr>", "Build App Bundle" },
                i = { "<cmd>FlutterBuild ios<cr>", "Build iOS" },
                I = { "<cmd>FlutterBuild ipa<cr>", "Build IPA" },
                w = { "<cmd>FlutterBuild web<cr>", "Build Web" },
                m = { "<cmd>FlutterBuild macos<cr>", "Build macOS" },
                l = { "<cmd>FlutterBuild linux<cr>", "Build Linux" },
                W = { "<cmd>FlutterBuild windows<cr>", "Build Windows" },
            },
            p = {
                name = "Packages",
                g = { "<cmd>FlutterPubGet<cr>", "Pub Get" },
                u = { "<cmd>FlutterPubUpgrade<cr>", "Pub Upgrade" },
                l = { "<cmd>FlutterPackages<cr>", "List Packages" },
                c = { "<cmd>FlutterClean<cr>", "Clean" },
            },
            d = {
                name = "Devices",
                d = { "<cmd>FlutterDevices<cr>", "List Devices" },
                e = { "<cmd>FlutterEmulators<cr>", "List Emulators" },
            },
            u = { "<cmd>FlutterUpgrade<cr>", "Upgrade Flutter" },
            c = { "<cmd>FlutterCreate<space>", "Create Project" },
            o = { "<cmd>lua require('flutter-tools').outline()<cr>", "Show Outline" },
        },
        d = {
            name = "Dart",
            a = { "<cmd>DartAnalyze<cr>", "Analyze Code" },
            f = { "<cmd>DartFormat<cr>", "Format Code" },
            x = { "<cmd>DartFix<cr>", "Apply Fixes" },
        },
        v = {
            name = "Devices/DevTools",
            d = {
                function()
                    local telescope_status, telescope = pcall(require, "telescope")
                    if telescope_status then
                        vim.cmd("FlutterDevices")
                    else
                        vim.cmd("FlutterDevices")
                    end
                end,
                "Select Device"
            },
            v = { "<cmd>DevTools<cr>", "Open DevTools" },
        },
        l = {
            name = "LSP",
            d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Go to Definition" },
            D = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Go to Declaration" },
            i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Go to Implementation" },
            r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
            a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Actions" },
            f = { "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", "Format" },
            s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Signature Help" },
            h = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover" },
            t = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
            w = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace Symbols" },
            R = { "<cmd>lua require('flutter-tools').reload()<cr>", "Reload Flutter" },
            O = { "<cmd>lua require('flutter-tools').outline()<cr>", "Flutter Outline" },
        },
        s = {
            name = "Software Engineering",
            e = {
                name = "Engineering",
                t = { "<cmd>FlutterTest<cr>", "Run Tests" },
                c = { "<cmd>FlutterTestCoverage<cr>", "Coverage Report" },
                r = { "<cmd>lua require('telescope.builtin').lsp_references()<cr>", "Find References" },
                f = { "<cmd>DartFix<cr>", "Apply Fixes" },
                a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Actions" },
            },
            m = {
                name = "Memory",
                p = { "<cmd>MemoryProfile<cr>", "Profile Memory" },
                a = { "<cmd>MemoryProfile<cr>", "Analyze Leaks" },
            },
            s = {
                name = "Security",
                a = { "<cmd>SecurityAudit<cr>", "Audit Dependencies" },
                s = { "<cmd>SecurityScan<cr>", "Scan Vulnerabilities" },
            },
        },
    }, { prefix = "<leader>" })
end

return M