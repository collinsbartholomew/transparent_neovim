-- Load core configuration first
require("profile.core.options")
require("profile.core.autocmds")

-- Load treesitter early (needed for many plugins)
require("profile.treesitter").setup()

-- Load tools configuration
require("profile.tools.conform").setup()
require("profile.tools.lint").setup()

-- Load UI components
require("profile.ui.theme").setup()
require("profile.ui.statusline").setup()
require("profile.ui.whichkey").setup()
require("profile.ui.popups").setup()

-- Load keymaps after which-key
require("profile.core.keymaps").setup()

-- Load LSP and completion
require("profile.lsp").setup()
require("profile.completion").setup()

-- Load language-specific configurations
require("profile.languages").setup()