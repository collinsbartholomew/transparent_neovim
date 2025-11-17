# Qt/QML Integration

Qt support is now fully integrated into your Neovim configuration without separate boilerplate configs.

## LSP Integration
- **qmlls**: Automatic QML language server (system-wide Qt installation)
- **clangd**: C++ with Qt optimizations (C++17, -fPIC flags)
- Both configured in `lua/profile/lsp/lspconfig.lua` alongside other LSPs

## Build & Debug Tools
- **QtBuild**: CMake build with auto-detected Ninja/Make
- **QtRun**: Execute compiled application
- **QtCompdb**: Generate compile_commands.json for clangd
- **QtHotReload**: Watch & reload QML with watchexec
- Configured in `lua/profile/tools/qt.lua`

## Debugging
- **codelldb** used for both C++ and Qt debugging (cpp adapter alias)
- Configured in `lua/profile/dap/adapters.lua`

## Keybindings
```
<leader>q     Qt command group
<leader>qb    Build
<leader>qr    Run
<leader>qh    Hot reload
<leader>qc    Generate compile_commands.json
```

## Requirements
- Qt 6.7+ (system-wide installation)
- CMake 3.24+
- Ninja or Make
- clangd (auto-installed via Mason)
- codelldb (auto-installed via Mason for DAP)
- watchexec (optional, for hot reload)

## Notes
- No hardcoded Qt paths (uses system-wide installation)
- Minimal config - only essential features
- All tools must be available in PATH
- integrate seamlessly with existing config structure
