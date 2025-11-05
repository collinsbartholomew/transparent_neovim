-- added-by-agent: zig-setup 20251020
-- mason: zls, codelldb
-- manual: build zls from source if using Zig nightly

local M = {}

function M.setup()
    -- Load sub-modules
    require('profile.languages.zig.debug').setup()
    require('profile.languages.zig.tools').setup()
end

return M