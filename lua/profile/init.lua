local M = {}

function M.setup()
	-- Load core modules
	require("profile.core.options").setup()
	require("profile.core.keymaps").setup()
	require("profile.core.autocmds").setup()
	require("profile.core.diagnostics").setup()

	-- Initialize lazy plugin manager
	require("lazy").setup("profile.lazy.plugins", {
		defaults = { lazy = true },
		install = { colorscheme = { "rose-pine" } },
		checker = { enabled = false },
		performance = {
			rtp = {
				disabled_plugins = {
					"gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin",
					"matchit", "matchparen", "logiPat", "rrhelper", "spellfile_plugin",
					"getscript", "getscriptPlugin", "vimball", "vimballPlugin",
				},
			},
			cache = {
				enabled = true,
			},
		},
		ui = { border = "rounded" },
		change_detection = { notify = false },
	})
end

return M