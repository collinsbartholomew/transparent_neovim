-- Aerial configuration for code structure overview
local M = {}

function M.setup()
    local status_ok, aerial = pcall(require, 'aerial')
    if not status_ok then
        vim.notify('Aerial not available', vim.log.levels.WARN)
        return
    end

    aerial.setup({
        -- Priority list of preferred backends for aerial.
        -- This can be a filetype map (see :help aerial-filetype-map)
        backends = {
            ['_'] = { 'lsp', 'treesitter', 'markdown', 'man' },
            javascript = { 'lsp', 'treesitter' },
            typescript = { 'lsp', 'treesitter' },
            javascriptreact = { 'lsp', 'treesitter' },
            typescriptreact = { 'lsp', 'treesitter' },
        },

        layout = {
            -- These control the width of the aerial window.
            -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- min_width and max_width can be a list of column widths and percentages.
            -- e.g. {40, 0.3} means "select the greater of 40 columns or 30% of total"
            max_width = { 40, 0.3 },
            width = nil,
            min_width = 20,
            -- key-value pairs of window-local options for aerial window (e.g. winhl)
            win_opts = {},
        },

        -- Determines line highlighting mode used by aerial:
        -- "cursor" highlights the line your cursor is on
        -- "split" highlights the top line of the current window
        -- "auto" uses "cursor" in non-nofocus mode and "split" in focus mode
        highlight_mode = 'cursor',

        -- Highlight the closest symbol if the cursor is not exactly on one
        highlight_closest = true,

        -- Highlight the symbol in the tree when cursor is over it
        highlight_on_hover = true,

        -- When jumping to a symbol, highlight the line for this many ms
        -- Set to false to disable
        highlight_on_jump = 300,

        -- Jump to symbol in source window when the cursor moves
        autojump = false,

        -- Define symbol icons
        icons = {
            Array = { icon = '', hl = 'AerialArrayIcon' },
            Boolean = { icon = '', hl = 'AerialBooleanIcon' },
            Class = { icon = '', hl = 'AerialClassIcon' },
            Constant = { icon = '', hl = 'AerialConstantIcon' },
            Constructor = { icon = '', hl = 'AerialConstructorIcon' },
            Enum = { icon = '', hl = 'AerialEnumIcon' },
            EnumMember = { icon = '', hl = 'AerialEnumMemberIcon' },
            Event = { icon = '', hl = 'AerialEventIcon' },
            Field = { icon = '', hl = 'AerialFieldIcon' },
            File = { icon = '', hl = 'AerialFileIcon' },
            Function = { icon = '', hl = 'AerialFunctionIcon' },
            Interface = { icon = '', hl = 'AerialInterfaceIcon' },
            Key = { icon = '', hl = 'AerialKeyIcon' },
            Method = { icon = '', hl = 'AerialMethodIcon' },
            Module = { icon = '', hl = 'AerialModuleIcon' },
            Namespace = { icon = '', hl = 'AerialNamespaceIcon' },
            Null = { icon = '', hl = 'AerialNullIcon' },
            Number = { icon = '', hl = 'AerialNumberIcon' },
            Object = { icon = '', hl = 'AerialObjectIcon' },
            Operator = { icon = '', hl = 'AerialOperatorIcon' },
            Package = { icon = '', hl = 'AerialPackageIcon' },
            Property = { icon = '', hl = 'AerialPropertyIcon' },
            String = { icon = '', hl = 'AerialStringIcon' },
            Struct = { icon = '', hl = 'AerialStructIcon' },
            TypeParameter = { icon = '', hl = 'AerialTypeParameterIcon' },
            Variable = { icon = '', hl = 'AerialVariableIcon' },
            -- More symbol kinds can be added here
        },

        -- Customize the characters used when show_guides = true
        guides = {
            -- When the child item has a sibling below it
            mid_item = '├─',
            -- When the child item is the last in the list
            last_item = '└─',
            -- When there are nested child guides to the right
            nested_top = '│ ',
            -- Raw indentation
            whitespace = '  ',
        },

        -- Set to false to disable all of the above keymaps
        keymaps = {
            ['?'] = 'actions.show_help',
            ['g?'] = 'actions.show_help',
            ['<CR>'] = 'actions.jump',
            ['<2-LeftMouse>'] = 'actions.jump',
            ['<C-v>'] = 'actions.jump_vsplit',
            ['<C-s>'] = 'actions.jump_split',
            ['h'] = 'actions.left',
            ['l'] = 'actions.right',
            ['<C-c>'] = 'actions.close',
        },
    })
end

return M
