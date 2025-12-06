-- Profile initialization - provides utilities and module loading
-- Core configuration is loaded from init.lua, this file just provides setup utilities

-- Safe require helper to avoid hard startup failures
local _utils_ok, _utils = pcall(require, "profile.core.utils")
local safe_require = _utils_ok and _utils.safe_require or function(name)
    local ok, mod_or_err = pcall(require, name)
    if not ok then
        vim.notify("Failed to require('" .. name .. "'): " .. tostring(mod_or_err), vim.log.levels.WARN)
        return nil
    end
    return mod_or_err
end

-- Export for use by other modules
return {
    safe_require = safe_require,
}