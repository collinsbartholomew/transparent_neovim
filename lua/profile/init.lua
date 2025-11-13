-- Load core configuration first
-- Load treesitter early (needed for many plugins)
-- Load tools configuration
-- Load UI components
-- Load keymaps after which-key
-- Load LSP and completion
-- Load language-specific configurations
-- Safe require helper to avoid hard startup failures
-- Use centralized safe_require helper from utilities (fallback to local pcall)
local _utils_ok, _utils = pcall(require, "profile.core.utils")
local safe_require = _utils_ok and _utils.safe_require or function(name)
    local ok, mod_or_err = pcall(require, name)
    if not ok then
        vim.notify("Failed to require('" .. name .. "'): " .. tostring(mod_or_err), vim.log.levels.WARN)
        return nil
    end
    return mod_or_err
end

-- Load core configuration first
safe_require("profile.core.options")
safe_require("profile.core.autocmds")

-- Load treesitter early (needed for many plugins)
local treesitter = safe_require("profile.treesitter")
if treesitter and type(treesitter.setup) == "function" then
	treesitter.setup()
end

-- Load tools configuration
local conform = safe_require("profile.tools.conform")
if conform and type(conform.setup) == "function" then
	conform.setup()
end
local lint = safe_require("profile.tools.lint")
if lint and type(lint.setup) == "function" then
	lint.setup()
end

-- Load UI components
local theme = safe_require("profile.ui.theme")
if theme and type(theme.setup) == "function" then
	theme.setup()
end
local statusline = safe_require("profile.ui.statusline")
if statusline and type(statusline.setup) == "function" then
	statusline.setup()
end
local whichkey = safe_require("profile.ui.whichkey")
if whichkey and type(whichkey.setup) == "function" then
	whichkey.setup()
end
local popups = safe_require("profile.ui.popups")
if popups and type(popups.setup) == "function" then
	popups.setup()
end

-- Load keymaps after which-key
local keymaps = safe_require("profile.core.keymaps")
if keymaps and type(keymaps.setup) == "function" then
	keymaps.setup()
end

-- Load LSP and completion
local lsp = safe_require("profile.lsp")
if lsp and type(lsp.setup) == "function" then
	lsp.setup()
end
local completion = safe_require("profile.completion")
if completion and type(completion.setup) == "function" then
	completion.setup()
end

-- Load language-specific configurations
local languages_path = package.searchpath("profile.languages", package.path)
if languages_path then
	local languages = safe_require("profile.languages")
	if languages and type(languages.setup) == "function" then
		languages.setup()
	end
end