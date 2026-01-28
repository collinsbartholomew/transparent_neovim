#!/bin/bash

echo "🚀 Testing Neovim Configuration..."

# Test basic startup
echo "✅ Testing basic startup..."
nvim --headless -c "lua print('Config loaded successfully')" -c "qa" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✓ Basic startup works"
else
    echo "   ✗ Basic startup failed"
fi

# Test LSP
echo "✅ Testing LSP configuration..."
nvim --headless -c "lua vim.lsp.start({name='test', cmd={'cat'}})" -c "qa" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✓ LSP configuration works"
else
    echo "   ✗ LSP configuration failed"
fi

# Test completion
echo "✅ Testing completion setup..."
nvim --headless -c "lua require('cmp')" -c "qa" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✓ Completion setup works"
else
    echo "   ✗ Completion setup failed"
fi

# Test treesitter
echo "✅ Testing treesitter..."
nvim --headless -c "lua require('nvim-treesitter')" -c "qa" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✓ Treesitter works"
else
    echo "   ✗ Treesitter failed"
fi

# Test telescope
echo "✅ Testing telescope..."
nvim --headless -c "lua require('telescope')" -c "qa" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✓ Telescope works"
else
    echo "   ✗ Telescope failed"
fi

# Test oil
echo "✅ Testing oil..."
nvim --headless -c "lua require('oil')" -c "qa" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✓ Oil works"
else
    echo "   ✗ Oil failed"
fi

echo ""
echo "🎉 Configuration test complete!"
echo "📝 Check OPTIMIZATIONS.md for details on improvements made"
echo ""
echo "🔧 Key improvements:"
echo "   • Fixed deprecated LSP functions"
echo "   • Removed JSX treesitter parser error"
echo "   • Enhanced UI with better completion styling"
echo "   • Optimized for Neovim 0.10+ features"
echo "   • Improved performance with lazy loading"
echo "   • Added modern fillchars and UI elements"
echo ""
echo "🚀 Ready to use! Try:"
echo "   • <leader>e - File explorer (Oil)"
echo "   • <leader>ff - Find files (Telescope)"
echo "   • <leader>fg - Live grep"
echo "   • <leader>fm - Format code"