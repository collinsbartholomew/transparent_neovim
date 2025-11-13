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

-- Optional bridge to shared LSP helpers
local _lsp_helpers_ok, _lsp_helpers = pcall(require, "profile.lsp.helpers")
if _lsp_helpers_ok and _lsp_helpers then
    M.lsp_helpers = _lsp_helpers
end

-- Accessor for LSP helpers (safe to call even if helpers are missing)
function M.get_lsp_helpers()
    return M.lsp_helpers
end

-- Safe require wrapper used across the config to avoid startup crashes
function M.safe_require(name)
	local ok, mod_or_err = pcall(require, name)
	if not ok then
		vim.notify("Failed to require('" .. name .. "'): " .. tostring(mod_or_err), vim.log.levels.WARN)
		return nil
	end
	return mod_or_err
end
return M

