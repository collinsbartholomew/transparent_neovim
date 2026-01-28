local M = {}

function M.setup()
	local lint = require("lint")

	lint.linters_by_ft = {
		lua = { "luacheck" },
		python = { "ruff" },
		sh = { "shellcheck" },
		javascript = { "eslint_d" },
		typescript = { "eslint_d" },
		go = { "golangci-lint" },
		c = { "cppcheck" },
		cpp = { "cppcheck", "clang-tidy" },
	}

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
		callback = function()
			pcall(lint.try_lint)
		end,
	})
end

return M