local M = {}

local themes = {
	["rose-pine"] = {
		setup = function()
			require("rose-pine").setup({
				variant = "moon",
				dark_variant = "moon",
				styles = {
					bold = true,
					italic = true,
					transparency = true,
				},
				highlight_groups = {
					-- Base
					Normal = { bg = "none" },
					NormalFloat = { bg = "none" },
					SignColumn = { bg = "none" },
					EndOfBuffer = { bg = "none" },
					-- Cursor
					CursorLine = { bg = "none" },
					CursorLineNr = { fg = "rose", bold = true },
					LineNr = { fg = "muted" },
					-- Borders
					FloatBorder = { fg = "rose", bg = "none" },
					WinSeparator = { fg = "muted", bg = "none" },
					-- Completion
					Pmenu = { bg = "none", fg = "text" },
					PmenuSel = { bg = "overlay", fg = "text", bold = true },
					PmenuSbar = { bg = "surface" },
					PmenuThumb = { bg = "rose" },
					CmpPmenu = { bg = "none", fg = "text" },
					CmpSel = { bg = "overlay", fg = "text", bold = true },
					CmpDoc = { bg = "none", fg = "text" },
					CmpGhostText = { fg = "muted", italic = true },
					-- Telescope
					TelescopeBorder = { fg = "rose", bg = "none" },
					TelescopePromptBorder = { fg = "pine", bg = "none" },
					TelescopeResultsBorder = { fg = "rose", bg = "none" },
					TelescopePreviewBorder = { fg = "rose", bg = "none" },
					TelescopeNormal = { bg = "none" },
					TelescopePromptNormal = { bg = "none" },
					TelescopeResultsNormal = { bg = "none" },
					TelescopePreviewNormal = { bg = "none" },
					-- Diagnostics
					DiagnosticVirtualTextError = { fg = "love", bg = "none" },
					DiagnosticVirtualTextWarn = { fg = "gold", bg = "none" },
					DiagnosticVirtualTextInfo = { fg = "foam", bg = "none" },
					DiagnosticVirtualTextHint = { fg = "iris", bg = "none" },
					-- Neo-tree
					NeoTreeNormal = { bg = "none" },
					NeoTreeNormalNC = { bg = "none" },
					NeoTreeEndOfBuffer = { bg = "none" },
				},
			})
		end,
		colorscheme = "rose-pine",
	},
	["onedark"] = {
		setup = function()
			require("onedarkpro").setup({
				theme = "onedark",
				styles = {
					comments = "italic",
					keywords = "bold,italic",
					functions = "italic",
					conditionals = "italic",
				},
				highlights = {
					-- Base
					Normal = { bg = "NONE" },
					NormalFloat = { bg = "NONE" },
					SignColumn = { bg = "NONE" },
					EndOfBuffer = { bg = "NONE" },
					-- Cursor
					CursorLine = { bg = "NONE" },
					CursorLineNr = { fg = "${orange}", bold = true },
					-- Completion
					Pmenu = { bg = "NONE", fg = "${fg}" },
					PmenuSel = { bg = "${bg_visual}", fg = "${fg}", bold = true },
					CmpPmenu = { bg = "NONE", fg = "${fg}" },
					CmpSel = { bg = "${bg_visual}", fg = "${fg}", bold = true },
					CmpDoc = { bg = "NONE", fg = "${fg}" },
					CmpGhostText = { fg = "${comment}", italic = true },
					-- Telescope
					TelescopeBorder = { fg = "${gray}", bg = "NONE" },
					TelescopePromptBorder = { fg = "${orange}", bg = "NONE" },
					TelescopeResultsBorder = { fg = "${gray}", bg = "NONE" },
					TelescopePreviewBorder = { fg = "${gray}", bg = "NONE" },
					TelescopeNormal = { bg = "NONE" },
					TelescopePromptNormal = { bg = "NONE" },
					TelescopeResultsNormal = { bg = "NONE" },
					TelescopePreviewNormal = { bg = "NONE" },
					-- Diagnostics
					DiagnosticVirtualTextError = { fg = "${red}", bg = "NONE" },
					DiagnosticVirtualTextWarn = { fg = "${yellow}", bg = "NONE" },
					DiagnosticVirtualTextInfo = { fg = "${blue}", bg = "NONE" },
					DiagnosticVirtualTextHint = { fg = "${purple}", bg = "NONE" },
					-- Neo-tree
					NeoTreeNormal = { bg = "NONE" },
					NeoTreeNormalNC = { bg = "NONE" },
					NeoTreeEndOfBuffer = { bg = "NONE" },
				},
				options = {
					cursorline = false,
					transparency = true,
					terminal_colors = true,
					lualine_transparency = true,
					highlight_inactive_windows = false,
				},
			})
		end,
		colorscheme = "onedark",
	},
}

local current_theme = "rose-pine"

function M.setup()
	-- Setup all themes
	for _, theme in pairs(themes) do
		theme.setup()
	end

	-- Set default theme
	vim.cmd.colorscheme(themes[current_theme].colorscheme)

	-- Apply transparency and common highlights
	M.apply_transparency()
end

function M.apply_transparency()
	-- Base transparency
	vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TabLineSel", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE" })
end

function M.toggle_theme()
	local theme_order = { "rose-pine", "onedark" }
	local current_index = 1
	
	for i, theme in ipairs(theme_order) do
		if theme == current_theme then
			current_index = i
			break
		end
	end
	
	local next_index = (current_index % #theme_order) + 1
	current_theme = theme_order[next_index]
	
	vim.cmd.colorscheme(themes[current_theme].colorscheme)
	M.apply_transparency()
	
	print("Switched to " .. current_theme .. " theme")
end

function M.get_current_theme()
	return current_theme
end

return M
