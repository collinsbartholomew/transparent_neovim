--Floating window styling with consistent appearance
local M = {}

function M.setup()
	-- ============================================================================
	-- Apply practical floating window styling
	-- ============================================================================
	vim.api.nvim_create_autocmd("WinNew", {
		desc = "Configure floating window options",
		callback = function(ev)
			local win_id = tonumber(ev.match) or vim.api.nvim_get_current_win()
			if not win_id or win_id <= 0 then
				return
			end

			local config = vim.api.nvim_win_get_config(win_id)
			if not config.relative or config.relative == "" then
				return
			end

			-- Apply consistent floating window options
			pcall(vim.api.nvim_win_set_option, win_id, "winblend", 0)
			pcall(vim.api.nvim_win_set_option, win_id, "wrap", true)
			pcall(vim.api.nvim_win_set_option, win_id, "colorcolumn", "")
			pcall(vim.api.nvim_win_set_option, win_id, "number", false)
			pcall(vim.api.nvim_win_set_option, win_id, "relativenumber", false)
			pcall(vim.api.nvim_win_set_option, win_id, "statusline", "")
			pcall(vim.api.nvim_win_set_option, win_id, "conceallevel", 2)
		end,
	})

	-- Apply consistent sizing to help windows
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "qf", "help", "man" },
		callback = function()
			pcall(vim.api.nvim_win_set_option, 0, "wrap", true)
		end,
	})

	-- Setup highlight links for popup UI elements
	local highlights = {
		"FloatBorder", "NormalFloat", "FloatTitle", "FloatFooter",
		"CmpNormal", "CmpBorder", "CmpDocNormal", "CmpDocBorder",
		"LspHover", "LspHoverBorder", "LspSignatureHelp", "LspSignatureBorder",
		"DiagnosticFloat", "DiagnosticFloatBorder",
	}

	for _, hl in ipairs(highlights) do
		local hldef = vim.api.nvim_get_hl_by_name(hl, true)
		if not hldef or not next(hldef) then
			if hl:match("Border") then
				vim.api.nvim_set_hl(0, hl, { link = "FloatBorder" })
			else
				vim.api.nvim_set_hl(0, hl, { link = "NormalFloat" })
			end
		end
	end
end

return M
