-- added-by-agent: csharp-setup 20251020-153000
-- mason: omnisharp
-- manual: dotnet-sdk installation required

local M = {}

function M.setup(config)
    -- Idempotency check
    if _G.csharp_setup_done then
        return
    end

    -- Load all C# modules
    require('profile.languages.csharp.debug').setup()
    require('profile.languages.csharp.tools').setup()

    -- Mark setup as done
    _G.csharp_setup_done = true
end

return M