if vim.loader then
    vim.loader.enable()
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable shadafile from the start
vim.opt.shadafile = ""

local home = os.getenv("HOME")
if home then
    local luarocks_base = home .. "/.luarocks"
    if vim.fn.isdirectory(luarocks_base) == 1 then
        local lua_version = _VERSION:match("Lua (%d+%.%d+)")
        package.path = string.format(
            "%s;%s/share/lua/%s/?.lua;%s/share/lua/%s/?/init.lua",
            package.path,
            luarocks_base,
            lua_version,
            luarocks_base,
            lua_version
        )
        package.cpath = string.format("%s;%s/lib/lua/%s/?.so", package.cpath, luarocks_base, lua_version)
    end
end

local function safe_require(name)
    local ok, mod = pcall(require, name)
    if not ok then
        vim.notify("Failed to require '" .. name .. "': " .. tostring(mod), vim.log.levels.WARN)
        return nil
    end
    return mod
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

safe_require("profile.core.options")
safe_require("profile.core.autocmds")
safe_require("profile.core.diagnostics")
safe_require("profile.core.fold")

-- Initialize lazy plugin manager immediately
require("lazy").setup("profile.lazy.plugins", {
    install = {
        colorscheme = { "tokyonight", "habamax" },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
-- Load UI configs immediately after plugins are initialized
safe_require("profile.ui")