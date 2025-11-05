-- added-by-agent: ccpp-setup 20251020
-- mason: none
-- manual: sudo pacman -S clang-format clang-tidy cppcheck cmake bear valgrind

local M = {}

function M.setup()
    -- Setup conform.nvim for formatting if available
    local conform_ok, conform = pcall(require, "conform")
    if conform_ok then
        -- Using centralized conform.lua configuration
    end

    -- Helper function to run commands in a terminal buffer
    local function run_in_term(cmd, title)
        vim.cmd("botright new")
        local buf = vim.api.nvim_get_current_buf()
        local chan = vim.api.nvim_open_term(buf, {})
        vim.api.nvim_buf_set_name(buf, title)
        vim.fn.jobstart(cmd, {
            on_stdout = function(_, data)
                data = table.concat(data, "\n")
                vim.api.nvim_chan_send(chan, data)
            end,
            on_stderr = function(_, data)
                data = table.concat(data, "\n")
                vim.api.nvim_chan_send(chan, data)
            end,
            stdout_buffered = true,
            stderr_buffered = true,
        })
    end

    -- Create compile_commands.json using CMake or Bear
    vim.api.nvim_create_user_command("MakeCompileDB", function()
        local choice = vim.fn.input({
            prompt = "Choose build system:\n1) CMake\n2) Bear + Make\nChoice (1/2): ",
        })

        if choice == "1" then
            run_in_term(
                    { "sh", "-c", "cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build && ln -sf build/compile_commands.json ." },
                    "[CompileDB - CMake]"
            )
        elseif choice == "2" then
            run_in_term(
                    { "sh", "-c", "bear -- make" },
                    "[CompileDB - Bear]"
            )
        end
    end, {})

    -- Run clang-tidy on current file
    vim.api.nvim_create_user_command("ClangTidy", function()
        local file = vim.fn.expand("%:p")
        run_in_term(
                { "sh", "-c", string.format("clang-tidy -p=./ %s", file) },
                "[Clang-Tidy]"
        )
    end, {})

    -- Run cppcheck on project
    vim.api.nvim_create_user_command("CppCheck", function()
        local dir = vim.fn.input("Directory to check: ", vim.fn.getcwd(), "dir")
        run_in_term(
                { "sh", "-c", string.format("cppcheck --enable=all %s", dir) },
                "[CppCheck]"
        )
    end, {})
    
    -- Run valgrind on executable
    vim.api.nvim_create_user_command("Valgrind", function()
        local exec = vim.fn.input("Executable to check: ", "./", "file")
        local args = vim.fn.input("Arguments: ", "")
        run_in_term(
                { "sh", "-c", string.format("valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes %s %s", exec, args) },
                "[Valgrind]"
        )
    end, {})
    
    -- Run AddressSanitizer build
    vim.api.nvim_create_user_command("ASanBuild", function()
        local build_type = vim.fn.input("Build type (Debug/Release): ", "Debug")
        run_in_term(
                { "sh", "-c", string.format("cmake -S . -B build-asan -DCMAKE_BUILD_TYPE=%s -DCMAKE_CXX_FLAGS='-fsanitize=address -g' -DCMAKE_C_FLAGS='-fsanitize=address -g' -DCMAKE_LINKER_FLAGS='-fsanitize=address' && cmake --build build-asan", build_type) },
                "[ASan Build]"
        )
    end, {})
end

return M