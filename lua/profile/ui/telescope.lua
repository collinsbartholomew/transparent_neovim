local M = {}

function M.setup()
	require("telescope").setup({
		defaults = {
			file_ignore_patterns = {
				"node_modules/",
				".git/",
				"target/",
				"build/",
				"dist/",
				"__pycache__/",
				".venv",
				"vendor/",
				"lazy-lock.json",
			},
		},
		pickers = {
			find_files = {
				find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
				hidden = true,
			},
			buffers = {
				theme = "dropdown",
				previewer = false,
				initial_mode = "normal",
				mappings = {
					i = { ["<C-d>"] = "delete_buffer" },
					n = { ["dd"] = "delete_buffer" },
				},
			},
		},
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	})

	require("telescope").load_extension("fzf")
end

return M
