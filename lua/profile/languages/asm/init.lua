local M = {}

function M.setup()
	require("profile.languages.asm.debug").setup()
	require("profile.languages.asm.tools").setup()
end

return M
