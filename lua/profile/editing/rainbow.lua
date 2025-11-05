local M = {}

function M.setup()
	local status_ok, rainbow_delimiters = pcall(require, "rainbow-delimiters")
	if not status_ok then
		return
	end

	-- Configure rainbow delimiters for all languages
	vim.g.rainbow_delimiters = {
		strategy = {
			[''] = rainbow_delimiters.strategy['global'],
			vim = rainbow_delimiters.strategy['local'],
			lua = rainbow_delimiters.strategy['local'],
		},
		query = {
			[''] = 'rainbow-delimiters',
			lua = 'rainbow-blocks',
			javascript = 'rainbow-delimiters',
			typescript = 'rainbow-delimiters',
			tsx = 'rainbow-delimiters',
			python = 'rainbow-delimiters',
			go = 'rainbow-delimiters',
			rust = 'rainbow-delimiters',
			java = 'rainbow-delimiters',
			c = 'rainbow-delimiters',
			cpp = 'rainbow-delimiters',
			php = 'rainbow-delimiters',
			zig = 'rainbow-delimiters',
		},
		priority = {
			[''] = 110,
			lua = 210,
		},
		highlight = {
			'RainbowDelimiterRed',
			'RainbowDelimiterYellow',
			'RainbowDelimiterBlue',
			'RainbowDelimiterOrange',
			'RainbowDelimiterGreen',
			'RainbowDelimiterViolet',
			'RainbowDelimiterCyan',
		},
	}
end

return M