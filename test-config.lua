#!/usr/bin/env lua

-- Test script to validate Neovim configuration
local function test_config()
    print("Testing Neovim configuration...")
    
    -- Test 1: Check if required modules exist
    local modules = {
        "profile.init",
        "profile.core.options",
        "profile.core.keymaps", 
        "profile.core.autocmds",
        "profile.core.diagnostics",
        "profile.ui.theme",
        "profile.ui.statusline",
        "profile.ui.telescope",
        "profile.completion.init",
        "profile.lsp.init",
        "profile.lazy.plugins"
    }
    
    local success_count = 0
    local total_count = #modules
    
    for _, module in ipairs(modules) do
        local ok, _ = pcall(require, module)
        if ok then
            print("✓ " .. module .. " loaded successfully")
            success_count = success_count + 1
        else
            print("✗ " .. module .. " failed to load")
        end
    end
    
    print(string.format("\nModule test results: %d/%d passed", success_count, total_count))
    
    -- Test 2: Check theme functionality
    local theme_ok, theme = pcall(require, "profile.ui.theme")
    if theme_ok and type(theme.toggle_theme) == "function" then
        print("✓ Theme toggle function available")
    else
        print("✗ Theme toggle function not available")
    end
    
    -- Test 3: Check if essential vim options are set correctly
    local essential_opts = {
        { "mouse", "" },
        { "number", true },
        { "relativenumber", true },
        { "termguicolors", true },
        { "undofile", true },
        { "smartindent", true }
    }
    
    print("\nChecking essential options:")
    for _, opt in ipairs(essential_opts) do
        local name, expected = opt[1], opt[2]
        if vim.opt[name]:get() == expected then
            print("✓ " .. name .. " is set correctly")
        else
            print("✗ " .. name .. " is not set correctly")
        end
    end
    
    print("\nConfiguration test completed!")
end

-- Only run if this file is executed directly
if arg and arg[0] and arg[0]:match("test%-config%.lua$") then
    test_config()
end

return { test = test_config }