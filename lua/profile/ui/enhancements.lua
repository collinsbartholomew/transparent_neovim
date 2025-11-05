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

    -- Build safe config: prefer dashboard.config, then dashboard.opts (only if tables)
    local config = nil
    if type(dashboard.config) == 'table' then
        config = vim.deepcopy(dashboard.config)
    elseif type(dashboard.opts) == 'table' then
        config = vim.deepcopy(dashboard.opts)
    end

    -- Try to setup alpha safely; if it errors, fall back to minimal config
    local ok_setup, err = pcall(function()
        alpha.setup(config)
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
            local should_skip = false
            local is_dir = false
            
            if vim.fn.argc() > 0 then
                local arg = vim.fn.argv(0)
                should_skip = vim.fn.filereadable(arg) == 1
                is_dir = vim.fn.isdirectory(arg) == 1
            end
            
            if not should_skip then
                vim.schedule(function()
                    if is_dir then
                        vim.cmd('cd ' .. vim.fn.fnameescape(vim.fn.argv(0)))
                        vim.cmd('Neotree show left')
                        vim.defer_fn(function()
                            vim.cmd('wincmd l')
                            vim.cmd('Alpha')
                        end, 50)
                    else
                        require('alpha').start(true, require('alpha').default_config)
                    end
                    vim.cmd('set showtabline=0 | set laststatus=3')
                end)
            end
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

    -- Prevent scrolling in alpha buffer: map to <Nop>
    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'alpha',
        callback = function(event)
            local b = event.buf
            pcall(function()
                vim.api.nvim_buf_set_keymap(b, 'n', '<ScrollWheelUp>', '<Nop>', { noremap = true, silent = true })
                vim.api.nvim_buf_set_keymap(b, 'n', '<ScrollWheelDown>', '<Nop>', { noremap = true, silent = true })
                vim.keymap.set('n', 'j', '<Nop>', { buffer = b, noremap = true, silent = true })
                vim.keymap.set('n', 'k', '<Nop>', { buffer = b, noremap = true, silent = true })
                vim.keymap.set('n', '<C-u>', '<Nop>', { buffer = b, noremap = true, silent = true })
                vim.keymap.set('n', '<C-d>', '<Nop>', { buffer = b, noremap = true, silent = true })
                vim.opt_local.scrolloff = 0
            end)
        end,
    })
end

return M