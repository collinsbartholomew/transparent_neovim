local M = {}

function M.setup()
	vim.diagnostic.config({
		virtual_text = {
			spacing = 4,
			prefix = "●",
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "",
				[vim.diagnostic.severity.WARN] = "",
				[vim.diagnostic.severity.HINT] = "",
				[vim.diagnostic.severity.INFO] = "",
			},
		},
		float = { border = "rounded" },
	})
end

return M
