# 🚀 Optimized Neovim Configuration

**A Fast, Pure, Multi-Language Development Environment**

High-performance Neovim configuration using native features and strategic plugin selection, optimized for development efficiency across 15+ languages.

> ⚡ **LATEST UPDATE** (January 2026): Complete optimization with native features, extended language support, performance enhancements, and comprehensive multi-language LSP configuration.

---

## ✨ Key Highlights

### 🎯 Performance Optimized
- **150-250ms** startup time (with bytecode cache enabled)
- Lazy-loaded plugins by default
- Semantic tokens disabled for speed
- Large file detection (>500KB) disables expensive features
- Async formatting to avoid blocking
- Smart linting triggers

### 🌐 Comprehensive Language Support
**Supported Languages:**
- **Web**: JavaScript, TypeScript, JSX, TSX, HTML, CSS, Astro
- **Systems**: Rust, Go, C/C++, Bash
- **Backend**: Python, Ruby, PHP, Java, SQL
- **Config**: Lua, YAML, JSON, TOML, Markdown, Docker
- **Markup**: XML, Emmet
- **Extras**: Scala, Kotlin, Swift (parsers available)

**30+ LSP Servers** auto-installed via Mason

### 🔧 Professional Development Features
- **Native Snippets**: Neovim 0.10+ native snippet support
- **Code Completion**: nvim-cmp with LSP, buffer, and path sources
- **Formatting**: Auto-format on save via conform.nvim
- **Linting**: Real-time linting with smart triggers
- **Debugging**: Optional DAP support (commented, ready to enable)
- **Git Integration**: LazyGit + Gitsigns
- **Code Navigation**: Telescope fuzzy finder + Oil file explorer

### 🎨 Clean & Efficient UI
- **Theme**: Tokyo Night with transparency
- **Status Line**: Lualine with git info and diagnostics
- **Code Highlighting**: Treesitter with 50+ language parsers
- **Diagnostics**: Clean, organized virtual text display
- **Terminal**: Built-in terminal toggle

---

## 📋 Requirements

### Essential
- **Neovim**: 0.9.0+ (0.10+ recommended for native snippets)
- **Git**: For plugin management
- **Python3**: For various tools

### Recommended
- **ripgrep** (`rg`): Fast searching for telescope
- **fd**: Fast file finding
- **Node.js**: For some LSP servers
- **Cargo**: For Rust development
- **Go**: For Go development

---

## 🚀 Quick Start

### Installation
```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null

# Clone repository
git clone https://github.com/yourusername/nvim-config ~/.config/nvim

# Start Neovim (auto-installs plugins)
nvim
```

### Post-Installation
1. Wait for initial plugin setup (~20-30 seconds)
2. Run `:Mason` to install language servers
3. Run `:TSUpdate` to update Treesitter parsers
4. Run `:checkhealth` to verify setup

### Verify Installation
```vim
:Lazy home          " Check plugin status
:Mason              " View installed servers
:LspInfo            " Check active language servers
:ConformInfo        " Check formatters
```

---

## 📁 Directory Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lazy-lock.json              # Plugin lock file
├── .luarc.json                 # IDE configuration
├── CONFIGURATION.md            # Feature documentation
├── IMPROVEMENTS.md             # Recent improvements
├── README.md                   # This file
└── lua/profile/
    ├── init.lua                # Setup loader
    ├── core/
    │   ├── options.lua         # Editor options (performance-tuned)
    │   ├── keymaps.lua         # Key mappings
    │   ├── autocmds.lua        # Auto-commands (big file handling)
    │   └── diagnostics.lua     # Diagnostic display
    ├── lsp/init.lua            # LSP configuration (30+ servers)

---

## 📋 Requirements

### Essential
- **Neovim**: 0.9.0+ (0.10+ recommended for native snippets)
- **Git**: For plugin management
- **Python3**: For various tools

### Recommended
- **ripgrep** (`rg`): Fast searching for telescope
- **fd**: Fast file finding
- **Node.js**: For some LSP servers
- **Cargo**: For Rust development
- **Go**: For Go development

---

## 🚀 Quick Start

### Installation
```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null

# Clone repository
git clone https://github.com/yourusername/nvim-config ~/.config/nvim

# Start Neovim (auto-installs plugins)
nvim
```

### Post-Installation
1. Wait for initial plugin setup (~20-30 seconds)
2. Run `:Mason` to install language servers
3. Run `:TSUpdate` to update Treesitter parsers
4. Run `:checkhealth` to verify setup

### Verify Installation
```vim
:Lazy home          " Check plugin status
:Mason              " View installed servers
:LspInfo            " Check active language servers
:ConformInfo        " Check formatters
```

---

## 📁 Directory Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lazy-lock.json              # Plugin lock file
├── .luarc.json                 # IDE configuration
├── CONFIGURATION.md            # Feature documentation
├── IMPROVEMENTS.md             # Recent improvements
├── README.md                   # This file
└── lua/profile/
    ├── init.lua                # Setup loader
    ├── core/
    │   ├── options.lua         # Editor options (performance-tuned)
    │   ├── keymaps.lua         # Key mappings
    │   ├── autocmds.lua        # Auto-commands (big file handling)
    │   └── diagnostics.lua     # Diagnostic display
    ├── lsp/init.lua            # LSP configuration (30+ servers)
    ├── completion/init.lua     # Code completion (native snippets)
    ├── tools/
    │   ├── conform.lua         # Formatting (10+ formatters)
    │   └── lint.lua            # Linting (8+ linters)
    ├── ui/
    │   ├── theme.lua           # Theme setup
    │   ├── statusline.lua      # Status line
    │   └── telescope.lua       # Fuzzy finder
    └── lazy/plugins.lua        # Plugin specifications
```

---

## ⌨️ Essential Keybindings

### Navigation
| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Switch windows |
| `<S-h/l>` | Previous/next buffer |
| `<leader>e` | Toggle file explorer |

### Search & Files
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |

### LSP Features
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>fm` | Format buffer |

### Diagnostics
| Key | Action |
|-----|--------|
| `<leader>ld` | Line diagnostics |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>lt` | Toggle diagnostics |
| `<leader>lh` | Toggle inlay hints |

### Other
| Key | Action |
|-----|--------|
| `<leader>nh` | Clear search highlight |
| `<leader>tt` | Toggle terminal |
| `<leader>gg` | LazyGit |
| `<leader>xx` | Trouble diagnostics |
| `<leader>qs` | Restore session |

---

## 🌐 Language Support Matrix

| Language | LSP | Formatter | Linter | Treesitter |
|----------|-----|-----------|--------|------------|
| Python | ✅ Pyright | ✅ Black | ✅ Ruff | ✅ |
| JavaScript | ✅ ts_ls | ✅ Prettier | ✅ ESLint | ✅ |
| TypeScript | ✅ ts_ls | ✅ Prettier | ✅ ESLint | ✅ |
| Lua | ✅ lua_ls | ✅ Stylua | ✅ Luacheck | ✅ |
| Rust | ✅ rustaceanvim | ✅ Rustfmt | - | ✅ |
| Go | ✅ Gopls | ✅ Gofmt | ✅ Golangci-lint | ✅ |
| C/C++ | ✅ Clangd | ✅ Clang-format | ✅ Clang-check | ✅ |
| HTML/CSS | ✅ Emmet | ✅ Prettier | - | ✅ |
| JSON | ✅ Jsonls | ✅ Prettier | - | ✅ |
| YAML | ✅ Yamlls | ✅ Prettier | - | ✅ |
| Bash | ✅ Bashls | ✅ Shfmt | ✅ Shellcheck | ✅ |
| Docker | ✅ Dockerls | - | - | ✅ |
| Ruby | ✅ ruby_lsp | ✅ Rubocop | ✅ Rubocop | ✅ |
| PHP | ✅ Intelephense | ✅ Php-cs-fixer | ✅ Phpstan | ✅ |
| Java | ✅ Jdtls | ✅ google-java-format | - | ✅ |
| C# | ✅ csharp_ls | - | - | ✅ |
| SQL | ✅ Sqlls | ✅ Sqlfluff | - | ✅ |
| XML | ✅ Lemminx | - | - | ✅ |
| Markdown | ✅ Marksman | ✅ Prettier | - | ✅ |
| TOML | ✅ Taplo | ✅ Taplo | - | ✅ |

---

## 🔧 Customization

### Use a Different Theme
Edit `lua/profile/ui/theme.lua` and change the theme name, or install new ones in `lazy/plugins.lua`

### Add a Language Server
1. Find server name at [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
2. Add to `lua/profile/lsp/init.lua` servers table
3. Run `:Mason` to install the server
4. Done! Automatically activates on file open

### Enable DAP Debugging
Uncomment the DAP section in `lua/profile/lazy/plugins.lua` and run `:Lazy sync`

### Change Status Line Look
Edit `lua/profile/ui/statusline.lua` lualine sections

---

## 🛠️ Troubleshooting

### Issue: Plugins not loading
```vim
:Lazy home        " Check plugin status
:Lazy sync        " Reinstall all plugins
:Lazy clean       " Remove broken plugins
```

### Issue: LSP not connecting
```vim
:LspInfo          " Check active servers
:Mason            " Install missing servers
:LspRestart       " Restart LSP clients
```

### Issue: Slow startup
```vim
:Lazy profile     " See plugin load times
nvim --startuptime startup.log  " Detailed timing
```

### Issue: Formatter not working
```vim
:ConformInfo      " Check formatter status
:Mason            " Install missing formatter
```

### Issue: Missing language support
1. Check language at `:Mason`
2. Install server/formatter/linter
3. Add to `lua/profile/lsp/init.lua` if new server
4. Restart Neovim

---

## 📊 Performance Summary

| Metric | Value |
|--------|-------|
| **Startup** | 150-250ms (cached) |
| **First Run** | 500-800ms |
| **Memory (Base)** | ~50MB |
| **Memory (Full)** | ~100-150MB |
| **Plugins (Lazy)** | 20+ loaded |
| **LSP Servers** | 30+ available |
| **Treesitter Parsers** | 50+ |

---

## 🚀 Next Steps

1. **Read Documentation**: Check [CONFIGURATION.md](./CONFIGURATION.md) and [IMPROVEMENTS.md](./IMPROVEMENTS.md)
2. **Install Tools**: `:Mason` to add language servers
3. **Configure**: Edit files in `lua/profile/` as needed
4. **Explore**: Try out keybindings and features

---

## 📝 Tips & Tricks

### Use Native Features
- Tab completion: `<Tab>` in insert mode
- Navigate pane: arrow keys or vim keys
- Terminal: `:terminal` or `<leader>tt`
- Undo tree: Use built-in `u` and `<C-r>`

### Make Files Render Faster
Automatically happens for >500KB files. Configure threshold in `lua/profile/core/autocmds.lua`

### Add Snippet Support
Snippets already configured! Define custom ones in completion setup or use plugin suggestions.

### Version Control
Track `lazy-lock.json` in git for reproducible setups

---

## 📚 Additional Resources

- [Neovim Docs](https://neovim.io/doc/)
- [LSP Configuration](https://github.com/neovim/nvim-lspconfig)
- [Telescope Usage](https://github.com/nvim-telescope/telescope.nvim)
- [Treesitter Docs](https://github.com/nvim-treesitter/nvim-treesitter)

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🙏 Credit

Built with:
- [Neovim](https://neovim.io/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- And 15+ other essential plugins

---

**Happy coding!** 🎉

For issues or questions: [Open an issue](https://github.com/yourusername/nvim-config/issues)
