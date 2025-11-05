-- Qt-specific functionality for C++ development
local M = {}

function M.setup()
    -- Command to deploy Qt applications
    vim.api.nvim_create_user_command("QtDeploy", function()
        local platform = vim.fn.input("Target platform (linux/windows/android/ios): ", "linux")
        local build_type = vim.fn.input("Build type (Debug/Release): ", "Release")
        
        local cmd
        if platform == "android" then
            cmd = string.format("cmake --build build-android --target apk && androiddeployqt --input android-deployment-settings.json --output build-android/android-build --deployment bundled --gradle --release")
        else
            cmd = string.format("cmake --build build-%s --config %s", platform, build_type)
        end
        
        vim.cmd(string.format("!%s", cmd))
    end, {})
    
    -- Command to run CTest
    vim.api.nvim_create_user_command("CTest", function()
        local args = vim.fn.input("CTest arguments: ", "")
        vim.cmd(string.format("!ctest %s", args))
    end, {})
    
    -- Command to generate coverage report
    vim.api.nvim_create_user_command("CTestCoverage", function()
        vim.cmd("!cmake --build build -t coverage && open build/coverage/index.html")
    end, {})
    
    -- Command to check code formatting
    vim.api.nvim_create_user_command("ClangFormatCheck", function()
        vim.cmd("!find . -name '*.cpp' -o -name '*.h' -o -name '*.hpp' | xargs clang-format --dry-run --Werror")
    end, {})
    
    -- Function to generate Qt signal/slot connections
    function M.generate_signal_slot()
        local line = vim.api.nvim_get_current_line()
        local class_name = vim.fn.input("Class name: ", "")
        local signal_name = vim.fn.input("Signal name: ", "")
        local slot_name = vim.fn.input("Slot name: ", "")
        
        local connection = string.format("connect(%s, &%s::%s, %s, &%s::%s);", 
            class_name, class_name, signal_name, class_name, class_name, slot_name)
            
        vim.api.nvim_put({connection}, "", true, true)
    end
    
    -- Function to create a basic Qt class
    function M.create_qt_class()
        local class_name = vim.fn.input("Class name: ", "")
        local header_file = class_name .. ".h"
        local impl_file = class_name .. ".cpp"
        
        -- Create header file
        local header_content = {
            string.format("#ifndef %s_H", string.upper(class_name)),
            string.format("#define %s_H", string.upper(class_name)),
            "",
            "#include <QObject>",
            "",
            string.format("class %s : public QObject", class_name),
            "{",
            "    Q_OBJECT",
            "",
            "public:",
            string.format("    explicit %s(QObject *parent = nullptr);", class_name),
            "    ~" .. class_name .. "();",
            "",
            "private:",
            "    // Private members",
            "};",
            "",
            string.format("#endif // %s_H", string.upper(class_name))
        }
        
        -- Create implementation file
        local impl_content = {
            string.format("#include \"%s.h\"", class_name),
            "",
            string.format("%s::%s(QObject *parent)", class_name, class_name),
            "    : QObject(parent)",
            "{",
            "}",
            "",
            string.format("%s::~%s()", class_name, class_name),
            "{",
            "}",
        }
        
        -- Write files
        local header_buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_lines(header_buf, 0, -1, false, header_content)
        vim.api.nvim_buf_set_name(header_buf, header_file)
        vim.api.nvim_command(string.format("buffer %d", header_buf))
        
        local impl_buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_lines(impl_buf, 0, -1, false, impl_content)
        vim.api.nvim_buf_set_name(impl_buf, impl_file)
    end
end

return M