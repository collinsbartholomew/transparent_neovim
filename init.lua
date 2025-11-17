-- Initialization optimizations (guard for older Neovim versions)
pcall(function() vim.loader.enable() end)  -- Enable faster module loading when available

-- Early performance settings
vim.g.mapleader = " "      -- Space as leader key
vim.g.maplocalleader = " " -- Space as local leader key

-- Early UI optimizations
vim.opt.shadafile = "NONE"  -- Don't read shada file on start

-- Set up LuaRocks paths for finding Lua libraries
local function setup_luarocks_paths()
    local home = os.getenv("HOME")
    if not home then return end
    
    local luarocks_base = home .. "/.luarocks"
    if vim.fn.isdirectory(luarocks_base) == 0 then return end
    
    local lua_version = _VERSION:match("Lua (%d+%.%d+)")
    package.path = string.format("%s;%s/share/lua/%s/?.lua;%s/share/lua/%s/?/init.lua",
        package.path, luarocks_base, lua_version, luarocks_base, lua_version)
    package.cpath = string.format("%s;%s/lib/lua/%s/?.so",
        package.cpath, luarocks_base, lua_version)
end

setup_luarocks_paths()

-- Safe require helper
-- Use centralized safe_require from profile core utilities when available
local _utils_ok, _utils = pcall(require, "profile.core.utils")
local safe_require
if _utils_ok and _utils and type(_utils.safe_require) == "function" then
    safe_require = _utils.safe_require
else
    safe_require = function(name)
        local ok, mod_or_err = pcall(require, name)
        if not ok then
            vim.notify("Failed to require('" .. name .. "'): " .. tostring(mod_or_err), vim.log.levels.WARN)
            return nil
        end
        return mod_or_err
    end
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
-- Add lazy.nvim to the runtime path
vim.opt.rtp:prepend(lazypath)

-- Load and initialize lazy with the profile plugins
-- This loads all plugins defined in lua/profile/lazy/plugins.lua
local ok_lazy, lazy = pcall(require, "lazy")
if ok_lazy and lazy and type(lazy.setup) == "function" then
    lazy.setup("profile.lazy.plugins", {
        install = { colorscheme = { "tokyonight" } },
        checker = { enabled = true, notify = false },
        change_detection = {
            enabled = true,
            notify = false,
        },
        performance = {
            cache = {
                enabled = true,
                path = vim.fn.stdpath("cache") .. "/lazy/cache",
                ttl = 3600 * 24 * 5, -- 5 days
            },
            reset_packpath = true,
            rtp = {
                reset = true,
                paths = {},
                disabled_plugins = {
                    "gzip", "matchit", "netrwPlugin", "tarPlugin",
                    "tohtml", "tutor", "zipPlugin", "2to3",
                    "getscript", "getscriptPlugin", "logiPat",
                    "rrhelper", "spellfile", "vimball", "vimballPlugin",
                },
            },
        },
        ui = {
            wrap = true,
            border = "rounded",
            icons = {
                cmd = " ",
                config = "",
                event = "",
                ft = " ",
                init = " ",
                import = " ",
                keys = " ",
                lazy = "󰒲 ",
                loaded = "●",
                not_loaded = "○",
                plugin = " ",
                runtime = " ",
                require = "󰢱 ",
                source = " ",
                start = "",
                task = "✔ ",
                list = {
                    "●",
                    "➜",
                    "★",
                    "‒",
                },
            },
        },
    })
else
    vim.notify("lazy.nvim not available; skipping plugin setup.", vim.log.levels.WARN)
end

-- Neovim bootstrap: load modular profile config
-- This loads the main profile configuration module
-- Load core modules
local function load_module(name)
    local ok, err = pcall(require, name)
    if not ok then
        vim.notify("Failed to load " .. name .. ": " .. tostring(err), vim.log.levels.WARN)
        return false
    end
    return true
end

-- Load core configuration
if load_module("profile") then
    -- Load additional modern features
    load_module("profile.core.diagnostics")
    load_module("profile.core.fold")
    load_module("profile.completion.snippets")
    
    -- Restore shada file after initialization
    vim.opt.shadafile = ""
    pcall(vim.cmd.rshada)
end
