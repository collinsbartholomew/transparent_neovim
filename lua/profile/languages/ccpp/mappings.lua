local M = {}

function M.setup()
    local which_key_ok, wk = pcall(require, "which-key")
    if not which_key_ok then
        vim.notify("which-key not available", vim.log.levels.WARN)
        return
    end

    -- Register C/C++ specific mappings
    wk.register({
        ["<leader>c"] = {
            name = "C/C++",
            c = { "<cmd>ClangTidy<cr>", "Run clang-tidy" },
            C = { "<cmd>CppCheck<cr>", "Run cppcheck" },
            f = { function()
                if pcall(require, "conform") then
                    require("conform").format()
                else
                    vim.lsp.buf.format()
                end
            end, "Format buffer" },
            h = { "<cmd>ClangdSwitchSourceHeader<cr>", "Switch header/source" },
            m = { "<cmd>MakeCompileDB<cr>", "Generate compile_commands.json" },
            v = { "<cmd>Valgrind<cr>", "Run valgrind" },
            a = { "<cmd>ASanBuild<cr>", "Build with AddressSanitizer" },
        },
        ["<leader>b"] = {
            name = "build",
            b = { "<cmd>CMakeBuild<cr>", "Build project" },
            d = { "<cmd>MakeCompileDB<cr>", "Generate compile_commands.json" },
            a = { "<cmd>ASanBuild<cr>", "Build with AddressSanitizer" },
        },
        ["<leader>q"] = {
            name = "QML/Qt",
            f = { function()
                vim.lsp.buf.format({ name = "qmlls" })
            end, "Format QML" },
            n = { "<cmd>edit qml.config<cr>", "Edit QML config" },
            r = { "<cmd>!qmlscene %<cr>", "Run QML scene" },
            d = { "<cmd>QtDeploy<cr>", "Deploy Qt application" },
        },
        ["<leader>t"] = {
            name = "tests",
            t = { "<cmd>TestNearest<cr>", "Run nearest test" },
            f = { "<cmd>TestFile<cr>", "Run test file" },
            s = { "<cmd>TestSuite<cr>", "Run test suite" },
            l = { "<cmd>TestLast<cr>", "Run last test" },
            v = { "<cmd>TestVisit<cr>", "Visit last test file" },
        },
        ["<leader>s"] = {
            name = "software engineering",
            e = { "<cmd>CTest<cr>", "Run CTest suite" },
            c = { "<cmd>CTestCoverage<cr>", "Generate coverage report" },
            f = { "<cmd>ClangFormatCheck<cr>", "Check code formatting" },
            t = { "<cmd>ClangTidy<cr>", "Run static analysis" },
        },
    })
end

return M
