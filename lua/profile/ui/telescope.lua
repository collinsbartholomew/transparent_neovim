local M = {}

function M.setup()
	local telescope = require("telescope")
	telescope.setup({
		defaults = {
			mappings = {
				i = { ["<C-h>"] = "which_key" },
			},
			file_ignore_patterns = {
				"node_modules/",
				".git/",
				"target/",
				"build/",
				"%.class",
			},
		},
	})
	pcall(telescope.load_extension, "harpoon")
	pcall(telescope.load_extension, "undo")
	pcall(telescope.load_extension, "colorscheme")
end

return M
