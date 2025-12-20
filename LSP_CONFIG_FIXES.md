# LSP Configuration Fixes

## Overview
Fixed LSP configuration to use validated, builtin-aware settings and proper mason/mason-lspconfig integration.

## Key Changes

### 1. **mason.lua** - Corrected Package Names
**Problem**: Mason package registry names didn't match lspconfig server names, causing registry lookup failures and noisy warnings.

**Solutions**:
- Removed invalid packages: `ts_ls`, `eslint`, `motoko_lsp`, `qmlls`, `docker_compose_language_service`, etc.
- Used only validated mason registry names:
  - `rust-analyzer` (not `rust_analyzer`)
  - `lua-language-server` (not `lua_ls`)
  - `typescript-language-server` (not `ts_ls`)
  - `html-lsp`, `css-lsp`, `yaml-language-server`, `json-lsp`
- Set `automatic_installation = false` to prevent unknown packages from being auto-installed
- Removed complex registry validation loop that caused INFO notifications

### 2. **whichkey.lua** - Removed Invalid Options
**Problem**: Configuration had deprecated/unsupported options like `triggers`, `window.title`, `layout.align`, `show_disabled`, `disabled`, and invalid `delay` behavior.

**Solution**: Simplified to validated which-key 3.x API:
- Changed `window` → `win` (newer API)
- Removed deprecated options
- Used only stable options: `preset`, `delay`, `win`, `layout`, `icons`, `show_help`, `show_keys`

### 3. **lspconfig.lua** - Cleaned Setup Flow
**Changes**:
- Removed `get_vue_plugin_path()` (unused complex function)
- Simplified `server_overrides()` to only essential servers:
  - `lua_ls`: Neovim diagnostics + workspace library
  - `tsserver`: Disabled inlay hints for performance
  - `rust_analyzer`: Clippy integration
  - `tailwindcss`: Extended filetype support
  - `clangd`: Minimal clang-tidy support
- Removed `ts_ls` Vue plugin code (not relevant for most use cases)
- Removed `qmlls` and `motoko_lsp` overrides (not in ensure_installed)
- Changed main setup to require `mason-lspconfig.setup_handlers()` directly (error if unavailable)
- Removed fallback manual server registration (better to fail fast if mason-lspconfig is missing)

### 4. **capabilities.lua** - No Changes Needed
The capabilities configuration is already correct and follows Neovim 0.10+ standards with:
- Proper LSP folding support
- cmp_nvim_lsp integration
- Semantic token disabling for performance
- Document highlight via autocmds

## Testing Checklist
- ✅ Lua syntax validated
- ✅ Package names verified against mason registry
- ✅ Which-key options conform to current API
- ✅ No undefined server references in overrides

## Next Steps for User
1. Run `:Mason` to verify packages install correctly
2. Check `:Mason` to confirm no unknown packages appear
3. Run `:checkhealth which-key` to confirm no warnings
4. Open a supported file type (Python, Rust, JavaScript) to verify LSP attaches
5. If specific servers are needed beyond the minimal set, add them to `ensure_installed` in `mason.lua`

## Mason Registry Reference
Valid package names (not lspconfig server names):
- `pyright` → Python LSP
- `rust-analyzer` → Rust LSP
- `clangd` → C/C++ LSP
- `lua-language-server` → Lua LSP
- `typescript-language-server` → TS/JS LSP
- `html-lsp`, `css-lsp` → HTML/CSS LSP
- `yaml-language-server`, `json-lsp` → YAML/JSON LSP
- `gopls` → Go LSP
- `jdtls` → Java LSP

See `:Mason` or https://github.com/williamboman/mason.nvim/blob/main/PACKAGES.md for full list.
