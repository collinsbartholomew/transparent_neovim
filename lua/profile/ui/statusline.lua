local M = {}

function M.setup()
	require("lualine").setup({
		options = {
			theme = "tokyonight",
			globalstatus = true,
			component_separators = { left = "│", right = "│" },
			section_separators = { left = "", right = "" },
			-- Refresh handles automatically in lualine
			-- Don't render statusline in these windows (performance)
			disabled_filetypes = {
				statusline = {
					"oil",
					"lazy",
					"mason",
					"TelescopePrompt",
					"NoFile",
					"help",
					"quickfix",
				},
			},
			-- Don't render for these buffer types
			ignore_focus = {
				"oil",
				"lazy",
				"mason",
				"TelescopePrompt",
			},
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { { "filename", path = 1 } },
			lualine_x = { "encoding", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		-- Only enable extensions for active buffer
		extensions = { "lazy", "oil", "trouble" },
	})
end

return M
