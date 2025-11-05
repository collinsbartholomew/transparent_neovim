-- added-by-agent: flutter-setup 20251020-160000
-- mason: dart-debug-adapter
-- manual: flutter/dart/fvm install commands listed in README

local M = {}

function M.setup(config)
    -- Idempotency check
    if _G.flutter_setup_done then
        return
    end

    -- Load all Flutter modules
    require('profile.languages.flutter.debug').setup(config)
    require('profile.languages.flutter.tools').setup(config)

    -- Mark setup as done
    _G.flutter_setup_done = true
end

return M