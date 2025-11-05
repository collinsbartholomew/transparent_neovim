---
-- Databases Language Module
-- Plugins: vim-dadbod, vim-dadbod-ui
-- Features: DB UI, SQL execution, Mongo shell
local M = {}
function M.setup()
    require('profile.languages.dbs.tools').setup()
    require('profile.languages.dbs.mappings').setup()
end
return M