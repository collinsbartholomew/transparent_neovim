local M = {}

function M.setup()
	local status_ok, comment = pcall(require, "Comment")
	if not status_ok then
		vim.notify("Comment.nvim not available", vim.log.levels.WARN)
		return
	end

	comment.setup({
		padding = true,
		sticky = true,
		ignore = nil,
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
		pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
	})


end

return M