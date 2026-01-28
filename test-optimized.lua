#!/usr/bin/env lua

-- Test script to validate Neovim configuration
local function test_config()
    print("Testing optimized Neovim configuration...")
    
    -- Test 1: Check if required modules exist
    local modules = {
        "profile.ui.theme",
        "profile.core.options",
        "profile.core.keymaps",
        "profile.completion.init"
    }
    
    for _, module in ipairs(modules) do
        local ok, _ = pcall(require, module)
        if ok then
            print("✓ Module " .. module .. " loaded successfully")
        else
            print("✗ Failed to load module " .. module)
        end
    end
    
    -- Test 2: Check theme functionality
    local theme_ok, theme = pcall(require, "profile.ui.theme")
    if theme_ok then
        print("✓ Theme module loaded")
        if type(theme.toggle_theme) == "function" then
            print("✓ Theme toggle function available")
        end
        if type(theme.get_current_theme) == "function" then
            print("✓ Get current theme function available")
        end
    end
    
    -- Test 3: Check built-in features
    local builtin_features = {
        "vim.snippet",
        "vim.treesitter",
        "vim.diagnostic",
        "vim.lsp"
    }
    
    for _, feature in ipairs(builtin_features) do
        local parts = vim.split(feature, ".", { plain = true })
        local obj = vim
        for _, part in ipairs(parts) do
            if part ~= "vim" then
                obj = obj[part]
                if not obj then break end
            end
        end
        if obj then
            print("✓ Built-in feature " .. feature .. " available")
        else
            print("✗ Built-in feature " .. feature .. " not available")
        end
    end
    
    print("Configuration test completed!")
end

-- Run test if executed directly
if arg and arg[0] and arg[0]:match("test%-optimized%.lua$") then
    test_config()
end

return { test = test_config }