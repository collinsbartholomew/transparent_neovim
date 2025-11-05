-- Utility functions for the Neovim configuration
local M = {}

-- Function to check if we're in a git repository
function M.is_git_repo()
	local git_dir = vim.fn.finddir(".git", ".;")
	return git_dir ~= ""
end

-- Function to get the root directory of the current git repository
function M.get_git_root()
	if not M.is_git_repo() then
		return nil
	end
	return vim.fn.fnamemodify(vim.fn.finddir(".git", ".;"), ":h")
end

return M
