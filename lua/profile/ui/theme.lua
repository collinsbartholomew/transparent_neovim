-- Configuration for themes with 100% transparency
local M = {}

-- Theme configurations (simplified - transparency handled globally)
local theme_configs = {
    ["rose-pine"] = function()
        require("rose-pine").setup({
            variant = "main",
            disable_background = true,
            disable_float_background = true,
        })
    end,
    ["onedark"] = function()
        require("onedarkpro").setup({
            style = "dark",
            options = {
                transparent = true,
                terminal_colors = true,
            },
        })
    end,
    ["tokyonight"] = function()
        require("tokyonight").setup({
            style = "moon",
            transparent = true,
            terminal_colors = true,
            styles = {
                sidebars = "transparent",
                floats = "transparent",
            },
        })
    end,
}

function M.setup()
    -- Setup default theme
    local default_theme = "onedark"
    if theme_configs[default_theme] then
        pcall(theme_configs[default_theme])
    end

    -- Set modern UI elements
    vim.opt.termguicolors = true
    vim.opt.cursorline = true
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.numberwidth = 4
    vim.opt.winblend = 0
    vim.opt.pumblend = 0
    vim.opt.laststatus = 3

    pcall(function() vim.cmd("colorscheme " .. default_theme) end)

    ----------------------------------------------------------------------
    -- Global transparency + visible borders (runs now + on ColorScheme)
    ----------------------------------------------------------------------
    local function set_transparent_background()
        local bg_none = { bg = "NONE", ctermbg = "NONE" }
        local border = { bg = "NONE", fg = "#555555" }
        local bg_select = { bg = "#2a2a3a" } -- Subtle bg for selected items

        -- Core UI
        vim.api.nvim_set_hl(0, "Normal", bg_none)
        vim.api.nvim_set_hl(0, "NormalFloat", bg_none)
        vim.api.nvim_set_hl(0, "NormalNC", bg_none)
        vim.api.nvim_set_hl(0, "FloatBorder", border)
        vim.api.nvim_set_hl(0, "SignColumn", bg_none)
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#444444", bg = "NONE" })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#dddddd", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "FoldColumn", bg_none)
        vim.api.nvim_set_hl(0, "EndOfBuffer", bg_none)
        vim.api.nvim_set_hl(0, "VertSplit", { bg = "NONE", fg = "#555555" })
        vim.api.nvim_set_hl(0, "WinSeparator", { bg = "NONE", fg = "#555555" })
        vim.api.nvim_set_hl(0, "StatusLine", bg_none)
        vim.api.nvim_set_hl(0, "StatusLineNC", bg_none)
        vim.api.nvim_set_hl(0, "TabLine", bg_none)
        vim.api.nvim_set_hl(0, "TabLineFill", bg_none)
        vim.api.nvim_set_hl(0, "TabLineSel", bg_select)

        -- Completion menu (selected item needs bg)
        vim.api.nvim_set_hl(0, "Pmenu", bg_none)
        vim.api.nvim_set_hl(0, "PmenuSel", bg_select)
        vim.api.nvim_set_hl(0, "PmenuSbar", bg_none)
        vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#555555" })

        -- CMP (selected item needs bg)
        vim.api.nvim_set_hl(0, "CmpNormal", bg_none)
        vim.api.nvim_set_hl(0, "CmpBorder", border)
        vim.api.nvim_set_hl(0, "CmpCursorLine", bg_select)
        -- Backwards-compatible names used by some configs
        vim.api.nvim_set_hl(0, "CmpPmenu", bg_none)
        vim.api.nvim_set_hl(0, "CmpSel", bg_select)
        -- Ghost text used by cmp experimental feature
        vim.api.nvim_set_hl(0, "CmpGhostText", { fg = "#6b7089", italic = true, bg = "NONE" })
        vim.api.nvim_set_hl(0, "CmpDocNormal", bg_none)
        vim.api.nvim_set_hl(0, "CmpDocBorder", border)
        vim.api.nvim_set_hl(0, "CmpDocCursor", bg_select)

        -- Telescope (selected item needs bg)
        vim.api.nvim_set_hl(0, "TelescopeNormal", bg_none)
        vim.api.nvim_set_hl(0, "TelescopeBorder", border)
        vim.api.nvim_set_hl(0, "TelescopePromptNormal", bg_none)
        vim.api.nvim_set_hl(0, "TelescopePromptBorder", border)
        vim.api.nvim_set_hl(0, "TelescopeResultsNormal", bg_none)
        vim.api.nvim_set_hl(0, "TelescopeResultsBorder", border)
        vim.api.nvim_set_hl(0, "TelescopePreviewNormal", bg_none)
        vim.api.nvim_set_hl(0, "TelescopePreviewBorder", border)
        vim.api.nvim_set_hl(0, "TelescopeSelection", bg_select)
        vim.api.nvim_set_hl(0, "TelescopeMultiIcon", bg_none)

        -- Neo-tree (selected/hovered items need bg)
        vim.api.nvim_set_hl(0, "NeoTreeNormal", bg_none)
        vim.api.nvim_set_hl(0, "NeoTreeNormalNC", bg_none)
        vim.api.nvim_set_hl(0, "NeoTreeCursorLine", bg_select)
        vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", border)
        vim.api.nvim_set_hl(0, "NeoTreeFloatNormal", bg_none)
        vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { bg = "NONE", fg = "#555555" })

        -- LSP popups with borders
        vim.api.nvim_set_hl(0, "LspHover", bg_none)
        vim.api.nvim_set_hl(0, "LspHoverBorder", border)
        vim.api.nvim_set_hl(0, "LspSignatureActive", bg_none)
        vim.api.nvim_set_hl(0, "LspSignatureHelp", bg_none)
        vim.api.nvim_set_hl(0, "LspSignatureBorder", border)

        -- Diagnostics with borders
        vim.api.nvim_set_hl(0, "DiagnosticFloat", bg_none)
        vim.api.nvim_set_hl(0, "DiagnosticFloatBorder", border)
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { underline = true, sp = "#e06c75" })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { underline = true, sp = "#d19a66" })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { underline = true, sp = "#61afef" })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { underline = true, sp = "#56b6c2" })

        -- Other popups with borders
        vim.api.nvim_set_hl(0, "ReferencesNormal", bg_none)
        vim.api.nvim_set_hl(0, "ReferencesBorder", border)
        vim.api.nvim_set_hl(0, "CodeActionMenu", bg_none)
        vim.api.nvim_set_hl(0, "CodeActionMenuBorder", border)
        vim.api.nvim_set_hl(0, "RenamePopup", bg_none)
        vim.api.nvim_set_hl(0, "RenamePopupBorder", border)
        vim.api.nvim_set_hl(0, "FloatTitle", bg_none)
        vim.api.nvim_set_hl(0, "FloatFooter", bg_none)

        -- Noice with borders
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", bg_none)
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", border)
        vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { bg = "NONE", fg = "#7aa2f7" })
        vim.api.nvim_set_hl(0, "NoiceCmdline", { bg = "NONE", fg = "#a9b1d6" })

        -- Notify with borders
        vim.api.nvim_set_hl(0, "NotifyBackground", bg_none)
        vim.api.nvim_set_hl(0, "NotifyINFOBody", bg_none)
        vim.api.nvim_set_hl(0, "NotifyINFOBorder", border)
        vim.api.nvim_set_hl(0, "NotifyWARNBody", bg_none)
        vim.api.nvim_set_hl(0, "NotifyWARNBorder", border)
        vim.api.nvim_set_hl(0, "NotifyERRORBody", bg_none)
        vim.api.nvim_set_hl(0, "NotifyERRORBorder", border)

        -- DAP
        vim.api.nvim_set_hl(0, "DapBreakpoint", { bg = "NONE", fg = "#e06c75" })
        vim.api.nvim_set_hl(0, "DapBreakpointCondition", { bg = "NONE", fg = "#d19a66" })
        vim.api.nvim_set_hl(0, "DapBreakpointRejected", { bg = "NONE", fg = "#98c379" })

        -- Trouble with borders
        vim.api.nvim_set_hl(0, "TroubleNormal", bg_none)
        vim.api.nvim_set_hl(0, "TroubleBorder", border)

        -- Which-key with borders
        vim.api.nvim_set_hl(0, "WhichKeyFloat", bg_none)
        vim.api.nvim_set_hl(0, "WhichKeyBorder", border)
    end

    set_transparent_background()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_transparent_background })
end

-- Toggle between the four themes
function M.toggle()
    local cur = vim.g.colors_name
    local next_theme

    if cur == "onedark" then
        next_theme = "tokyonight"
    elseif cur == "tokyonight" then
        next_theme = "rose-pine"
    else
        next_theme = "onedark"
    end

    -- Setup theme if not already configured
    if theme_configs[next_theme] then
        theme_configs[next_theme]()
    end

    vim.cmd("colorscheme " .. next_theme)
end

return M
