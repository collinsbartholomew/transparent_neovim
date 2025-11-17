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
				".venv",
				"vendor/",
				"dist/",
				"%.o$",
			},
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					preview_width = 0.6,
				},
			},
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--max-count=500",
			},
		},
		pickers = {
			find_files = {
				find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
				hidden = true,
			},
		},
	})
	pcall(telescope.load_extension, "harpoon")
	pcall(telescope.load_extension, "undo")
	pcall(telescope.load_extension, "colorscheme")
end

return M
