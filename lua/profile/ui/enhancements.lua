-- lua/profile/ui/enhancements.lua
-- Hardened alpha (dashboard) setup exported as setup()

local M = {}

function M.setup()
    local ok_alpha, alpha = pcall(require, 'alpha')
    if not ok_alpha or not alpha then
        vim.notify('alpha.nvim not available', vim.log.levels.WARN)
        return
    end

    local ok_dashboard, dashboard = pcall(require, 'alpha.themes.dashboard')
    if not ok_dashboard or not dashboard then
        vim.notify('alpha.themes.dashboard not available', vim.log.levels.WARN)
        return
    end

    -- ensure sections exist
    dashboard.section = dashboard.section or {}
    dashboard.section.header = dashboard.section.header or { val = {} }
    dashboard.section.buttons = dashboard.section.buttons or { val = {} }
    dashboard.section.footer = dashboard.section.footer or { val = {} }

    -- ASCII header (OMEGA)
    dashboard.section.header.val = {
        ' ██████╗   ███╗   ███╗  ███████╗   ██████╗    █████╗ ',
        '██╔═══██╗  ████╗ ████║  ██╔════╝  ██╔════╝   ██╔══██╗',
        '██║   ██║  ██╔████╔██║  █████╗    ██║  ███╗  ███████║',
        '██║   ██║  ██║╚██╔╝██║  ██╔══╝    ██║   ██║  ██╔══██║',
        '╚██████╔╝  ██║ ╚═╝ ██║  ███████╗  ╚██████╔╝  ██║  ██║',
        ' ╚═════╝   ╚═╝     ╚═╝  ╚══════╝   ╚═════╝   ╚═╝  ╚═╝',
    }

    local buttons = {
        dashboard.button('f', '🔍   Find file', ':Telescope find_files <CR>'),
        dashboard.button('n', '📄   New file', ':ene <BAR> startinsert <CR>'),
        dashboard.button('o', '🕐   Open recent', ':Telescope oldfiles <CR>'),
        dashboard.button('g', '🔎   Find text', ':Telescope live_grep <CR>'),
        dashboard.button('c', '⚙️   Configuration', ':e ~/.config/nvim/init.lua <CR>'),
        dashboard.button('l', '📦   Lazy plugins', ':Lazy <CR>'),
        dashboard.button('q', '❌   Quit', ':qa<CR>'),
    }

    for _, btn in ipairs(buttons) do
        btn.opts.hl = 'AlphaButtonLabel'
        btn.opts.hl_shortcut = 'AlphaShortcut'
    end

    dashboard.section.buttons.val = buttons

    dashboard.section.footer.val = {
        '',
        '═════════════════════════════════════════════════════════════════',
        '            ⚡ OMEGA ⚡ · Advanced Neovim Configuration',
        '═════════════════════════════════════════════════════════════════',
    }

    -- Setup alpha with dashboard config
    pcall(function()
        alpha.setup(dashboard.config)
    end)

    vim.api.nvim_create_autocmd('User', {
        pattern = 'AlphaReady',
        desc = 'style alpha and disable statusline',
        callback = function()
            local hi_link = function(group, link)
                vim.cmd(string.format('highlight! link %s %s', group, link))
            end
            hi_link('AlphaButtonLabel', 'String')
            hi_link('AlphaShortcut', 'Keyword')

            vim.o.number = false
            vim.o.relativenumber = false
            vim.o.cursorline = false
        end,
    })

    -- Re-enable when alpha buffer is left
    vim.api.nvim_create_autocmd('BufWinLeave', {
        desc = 're-enable statusline and tabline after alpha',
        callback = function(ev)
            local ok, ft = pcall(function()
                return vim.api.nvim_buf_get_option(ev.buf, 'filetype')
            end)
            if ok and ft == 'alpha' then
                vim.o.number = true
                vim.o.relativenumber = true
                vim.o.cursorline = true
            end
        end,
    })

    vim.api.nvim_create_autocmd('VimEnter', {
        desc = 'Show alpha dashboard on startup',
        callback = function()
            if vim.fn.argc() > 0 then
                return
            end
            
            vim.schedule(function()
                require('alpha').start(true, require('alpha').default_config)
                vim.cmd('set showtabline=0 | set laststatus=3')
            end)
        end,
        nested = true,
    })

    vim.api.nvim_create_autocmd('User', {
        pattern = 'AlphaClosed',
        callback = function()
            vim.cmd('set laststatus=3')
        end,
    })

    -- Keymap to reopen alpha
    vim.keymap.set('n', '<leader>A', function()
        require('alpha').start()
    end, { noremap = true, silent = true, desc = 'Show alpha screen' })
end

return M