-- Language-specific configuration loader
local M = {}

function M.setup()
  local languages = {
    "asm", "ccpp", "csharp", "dbs", "flutter", "go",
    "java", "lua", "mojo", "php", "python", "rust",
    "web", "zig", "motoko"
  }

  for _, lang in ipairs(languages) do
    local ok, module = pcall(require, "profile.languages." .. lang .. ".init")
    if ok and module.setup then
      module.setup()
    end
  end
end

return M