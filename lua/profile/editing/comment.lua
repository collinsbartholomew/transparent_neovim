local M = {}

function M.setup()
	local status_ok, comment = pcall(require, "Comment")
	if not status_ok then
		return
	end

	-- Setup with treesitter context string support
	local pre_hook
	local ts_ok, ts_comment = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
	if ts_ok then
		pre_hook = ts_comment.create_pre_hook()
	end

	comment.setup({
		padding = true,
		sticky = true,
		toggler = {
			line = "gcc",
			block = "gbc",
		},
		opleader = {
			line = "gc",
			block = "gb",
		},
		extra = {
			above = "gcO",
			below = "gco",
			eol = "gcA",
		},
		mappings = {
			basic = true,
			extra = true,
		},
		pre_hook = pre_hook,
	})
end

return M