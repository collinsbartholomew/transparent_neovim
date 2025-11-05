-- Set leader key BEFORE loading any plugins
-- This ensures that all plugins use the same leader key
vim.g.mapleader = " "      -- Space as leader key
vim.g.maplocalleader = " " -- Space as local leader key

-- Add LuaRocks paths
-- This allows Neovim to find Lua libraries installed via LuaRocks
local home = os.getenv("HOME")
if home then
    local luarocks_paths = {
        package.path .. ";" .. home .. "/.luarocks/share/lua/*/?.lua;" .. home .. "/.luarocks/share/lua/5.4/?/init.lua",
        package.cpath .. ";" .. home .. "/.luarocks/lib/lua/*/?.so",
    }
    package.path = luarocks_paths[1]
    package.cpath = luarocks_paths[2]
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
require("lazy").setup("profile.lazy.plugins", {
    install = {
        colorscheme = { "rose-pine" },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true,
        rtp = {
            reset = true,
            disabled_plugins = {
                "gzip",
                "matchit",
    
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
                "2to3",
                "getscript",
                "getscriptPlugin",
                "logiPat",
                "rrhelper",
                "spellfile",
                "vimball",
                "vimballPlugin",
            },
        },
    },
    ui = {
        wrap = true,
        border = "rounded",
    },
})

-- Neovim bootstrap: load modular profile config
-- This loads the main profile configuration module
require("profile")
