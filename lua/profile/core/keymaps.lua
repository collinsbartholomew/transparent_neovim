--Keymaps and which-key setup
-- This file configures all the custom keymaps and keymap groups for the editor
local M = {}

function M.setup()
    local wk = require('which-key')

    --Define keymap groups for better organization
    wk.add({
        { '<leader>b', group = 'Buffer' }, -- Buffer management operations
        { '<leader>d', group = 'Debug' }, -- Debugging operations
        { '<leader>f', group = 'Find' }, -- File and content finding operations
        { '<leader>g', group = 'Git' }, -- Git operations
        { '<leader>l', group = 'LSP' }, -- Language Server Protocol operations
        { '<leader>o', group = 'Overseer/Task' }, -- Task and build operations
        { '<leader>p', group = 'Project/Session' }, -- Project and session management
        { '<leader>q', group = 'Quickfix' }, -- Quickfix list operations
        { '<leader>r', group = 'Refactor' }, -- Code refactoring operations
        { '<leader>sr', group = 'Search/Replace' }, -- Search and replace operations
        { '<leader>t', group = 'Test/Terminal/Toggle' }, -- Testing, terminal, and toggle operations
        { '<leader>u', group = 'UI' }, -- User interface operations
        { '<leader>x', group = 'Trouble/Diagnostics' }, -- Diagnostic and trouble operations
        { '<leader>y', group = 'UI/Theme' }, -- UI theme operations
    })

    -- Buffer management keymaps
    -- These keymaps handle operations related to managing buffers (open files)
    wk.add({
        { '<leader>bb', '<cmd>Telescope buffers<cr>', desc = 'Pick buffer' }, -- Pick a buffer from the buffer list
        { '<leader>bc', '<cmd>Telescope buffers<cr>', desc = 'Pick close buffer' }, -- Pick and close a buffer
        { '<leader>bd', '<cmd>bdelete<cr>', desc = 'Delete buffer' }, -- Delete current buffer
        { '<leader>bn', '<cmd>bnext<cr>', desc = 'Next buffer' }, -- Switch to next buffer
        { '<leader>bp', '<cmd>bprevious<cr>', desc = 'Prev buffer' }, -- Switch to previous buffer
    })

    -- Find operations using Telescope
    -- These keymaps use Telescope to find various items in the project
    wk.add({
        { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' }, -- Find and switch between open buffers
        { '<leader>fc', '<cmd>Telescope commands<cr>', desc = 'Commands' }, -- Find and execute Neovim commands
        { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' }, -- Find files in the project
        { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Grep' }, -- Search for text in files
        { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help tags' }, -- Find help documentation
        { '<leader>fk', '<cmd>Telescope keymaps<cr>', desc = 'Keymaps' }, -- Find and view keymaps
        { '<leader>fo', '<cmd>Telescope oldfiles<cr>', desc = 'Old files' }, -- Find recently opened files
        { '<leader>fr', '<cmd>Telescope lsp_references<cr>', desc = 'References' }, -- Find references to the symbol under cursor
        { '<leader>fs', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', desc = 'Symbols' }, -- Find symbols in the workspace
    })

    -- Git operations
    -- These keymaps handle Git version control operations
    wk.add({
        { '<leader>gc', '<cmd>Git commit<cr>', desc = 'Commit' }, -- Commit changes
        { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' }, -- Open LazyGit interface
        { '<leader>gl', '<cmd>Git log<cr>', desc = 'Log' }, -- Show Git log
        { '<leader>go', '<cmd>Octo<cr>', desc = 'Octo (GH)' }, -- Open Octo GitHub interface
        { '<leader>gp', '<cmd>Git pull<cr>', desc = 'Pull' }, -- Pull changes from remote
        { '<leader>gP', '<cmd>Git push<cr>', desc = 'Push' }, -- Push changes to remote
        { '<leader>gv', '<cmd>DiffviewOpen<cr>', desc = 'Open DiffView' }, -- Open diff view
        { '<leader>gV', '<cmd>DiffviewClose<cr>', desc = 'Close DiffView' }, -- Close diff view
    })

    -- LSP (Language Server Protocol) operations
    -- These keymaps handle LSP features like code navigation and refactoring
    wk.add({
        { '<leader>la', vim.lsp.buf.code_action, desc = 'Code action' },
        { '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, desc = 'Format' },
        { '<leader>ll', '<cmd>LspInfo<cr>', desc = 'LSPInfo' },
        { '<leader>lR', vim.lsp.buf.rename, desc = 'Rename' },
        { '<leader>ls', vim.lsp.buf.signature_help, desc = 'Signature help' },
        { '<leader>lw', '<cmd>Telescope lsp_workspace_symbols<cr>', desc = 'Workspace symbols' },
        { '<leader>lc', vim.lsp.codelens.run, desc = 'Run codelens' },
        { '<leader>lh', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, desc = 'Toggle inlay hints' },
    })

    -- Overseer/Task operations
    -- These keymaps handle task management and execution
    wk.add({
        { '<leader>ob', '<cmd>OverseerBuild<cr>', desc = 'Build' }, -- Build project
        { '<leader>oi', '<cmd>OverseerInfo<cr>', desc = 'Info' }, -- Show task information
        { '<leader>or', '<cmd>OverseerRun<cr>', desc = 'Run' }, -- Run task
        { '<leader>ot', '<cmd>OverseerToggle<cr>', desc = 'Toggle' }, -- Toggle task
    })

    -- Project/Session operations
    -- These keymaps handle project and session management
    wk.add({
        {
            '<leader>pl',
            function()
                local status_ok, persistence = pcall(require, 'persistence')
                if status_ok and persistence then
                    persistence.load()
                else
                    vim.notify('Persistence module not available', vim.log.levels.WARN)
                end
            end,
            desc = 'Load session',
        },
        {
            '<leader>ps',
            function()
                local status_ok, persistence = pcall(require, 'persistence')
                if status_ok and persistence then
                    persistence.select()
                else
                    vim.notify('Persistence module not available', vim.log.levels.WARN)
                end
            end,
            desc = 'Select session',
        },
        { '<leader>pt', '<cmd>TodoTelescope<cr>', desc = 'Todo' }, -- Find TODO comments
    })

    -- Quickfix list operations
    -- These keymaps handle operations on the quickfix list
    wk.add({
        { '<leader>qn', '<cmd>cnext<cr>', desc = 'Next' }, -- Go to next item in quickfix list
        { '<leader>qp', '<cmd>cprev<cr>', desc = 'Prev' }, -- Go to previous item in quickfix list
        { '<leader>qo', '<cmd>copen<cr>', desc = 'Open' }, -- Open quickfix list
        { '<leader>qc', '<cmd>cclose<cr>', desc = 'Close' }, -- Close quickfix list
    })

    -- Refactoring operations
    -- These keymaps handle code refactoring operations
    wk.add({
        {
            '<leader>re',
            "<cmd>lua require('refactoring').refactor('ExtractFunction')<cr>",
            desc = 'Extract function',
            mode = 'v',
        },
        {
            '<leader>rf',
            "<cmd>lua require('refactoring').refactor('Extract Function To File')<cr>",
            desc = 'Extract function to file',
            mode = 'v',
        },
        {
            '<leader>rv',
            "<cmd>lua require('refactoring').refactor('Extract Variable')<cr>",
            desc = 'Extract variable',
            mode = 'v',
        },
        {
            '<leader>ri',
            "<cmd>lua require('refactoring').refactor('Inline Variable')<cr>",
            desc = 'Inline variable',
            mode = 'v',
        },
        {
            '<leader>rb',
            "<cmd>lua require('refactoring').refactor('Extract Block')<cr>",
            desc = 'Extract block',
            mode = 'v',
        },
        {
            '<leader>rp',
            "<cmd>lua require('refactoring').debug.printf({below = false})<cr>",
            desc = 'Debug print',
        },
        {
            '<leader>rc',
            "<cmd>lua require('refactoring').debug.cleanup({})<cr>",
            desc = 'Debug cleanup',
        },
    })

    -- Search and replace operations
    -- These keymaps handle search and replace operations
    wk.add({
        { '<leader>srp', '<cmd>Spectre<cr>', desc = 'Project replace' }, -- Replace text in project
        { '<leader>srw', require('spectre').open_visual, desc = 'Replace word', mode = 'v' }, -- Replace selected word
    })

    -- Structure, Test, and Terminal operations
    wk.add({
        { '<leader>so', group = 'Structure/Outline' },
        { '<leader>sot', '<cmd>AerialToggle<cr>', desc = 'Toggle outline' },
        { '<leader>sof', '<cmd>AerialNavToggle<cr>', desc = 'Navigate symbols' },
        { '<leader>tf', '<cmd>Neotest summary<cr>', desc = 'Test summary' },
        { '<leader>tn', '<cmd>Neotest run<cr>', desc = 'Run nearest test' },
        { '<leader>tt', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },
    })

    -- File explorer and UI operations
    wk.add({
        { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Toggle file tree' },
        { '<leader>E', '<cmd>Neotree focus<cr>', desc = 'Focus file tree' },
        { '<leader>uu', group = 'Undo/UI' },
        { '<leader>uut', '<cmd>UndotreeToggle<cr>', desc = 'Undotree' },
        { '<leader>uun', '<cmd>Noice<cr>', desc = 'Noice history' },
        { '<leader>uuh', '<cmd>Telescope undo<cr>', desc = 'Undo history' },
    })

    -- Theme, Trouble, LSP, and tool keymaps
    wk.add({
        { '<leader>yt', "<cmd>lua require('profile.ui.theme').toggle()<cr>", desc = 'Toggle theme' },
        { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Toggle Trouble' },
        { '<leader>xb', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics' },
        { '<leader>xd', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics' },
        { '<leader>xq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix' },
        { '<leader>xl', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List' },
        { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols' },
        { 'gd', vim.lsp.buf.definition, desc = 'Goto Definition' },
        { 'grr', vim.lsp.buf.references, desc = 'Goto References' },
        { 'gri', vim.lsp.buf.implementation, desc = 'Goto Implementation' },
        { 'K', vim.lsp.buf.hover, desc = 'Hover' },
        { '<leader>nb', "<cmd>lua require('nvim-navbuddy').open()<cr>", desc = 'Navbuddy' },
        { '<leader>cc', '<Plug>(comment_toggle_linewise)', desc = 'Comment toggle', mode = 'n' },
        { '<leader>cc', '<Plug>(comment_toggle_linewise_visual)', desc = 'Comment toggle', mode = 'v' },
        { '<leader>h', group = 'Harpoon' },
        { '<leader>hm', "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", desc = 'Menu' },
        { '<leader>ha', "<cmd>lua require('harpoon.mark').add_file()<cr>", desc = 'Add file' },
        { '<leader>fj', "<cmd>lua require('flash').jump()<cr>", desc = 'Flash jump' },
        { '<leader>ft', "<cmd>lua require('flash').treesitter()<cr>", desc = 'Flash treesitter' },
    })

    -- Window navigation, text movement, and utilities
    wk.add({
        { '<A-Up>', ':resize -2<CR>', desc = 'Resize up' },
        { '<A-Down>', ':resize +2<CR>', desc = 'Resize down' },
        { '<A-Left>', ':vertical resize -2<CR>', desc = 'Resize left' },
        { '<A-Right>', ':vertical resize +2<CR>', desc = 'Resize right' },
        { '<S-l>', ':bnext<CR>', desc = 'Next buffer' },
        { '<S-h>', ':bprevious<CR>', desc = 'Previous buffer' },
        { '<A-j>', '<Esc>:m .+1<CR>==gi', desc = 'Move line down' },
        { '<A-k>', '<Esc>:m .-2<CR>==gi', desc = 'Move line up' },
        { 'J', ":move '>+1<CR>gv-gv", desc = 'Move selection down', mode = 'x' },
        { 'K', ":move '<-2<CR>gv-gv", desc = 'Move selection up', mode = 'x' },
        { '<A-j>', ":move '>+1<CR>gv-gv", desc = 'Move selection down', mode = 'x' },
        { '<A-k>', ":move '<-2<CR>gv-gv", desc = 'Move selection up', mode = 'x' },
        { '<', '<gv', desc = 'Indent left', mode = 'v' },
        { '>', '>gv', desc = 'Indent right', mode = 'v' },
        { '<leader>nh', ':nohlsearch<CR>', desc = 'Clear search highlights' },
        { '<leader>td', ":lua require('profile.core.functions').toggle_diagnostics()<CR>", desc = 'Toggle diagnostics' },
        { '<leader>tv', function() vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text }) end, desc = 'Toggle virtual text' },
        { '<leader>cf', function() require('conform').format({ async = true, lsp_fallback = true }) end, desc = 'Format code' },
        { '<leader>a', group = 'ASM' },
        { '<leader>atc', ":lua require('profile.core.functions').check_asm_tools()<CR>", desc = 'Check tools' },
        { '<leader>arr', ":lua require('profile.core.functions').asm_run()<CR>", desc = 'Run' },
        { '<leader>c', group = 'C/C++' },
        { '<leader>ctc', ":lua require('profile.core.functions').check_cpp_tools()<CR>", desc = 'Check tools' },
        { '<leader>rtc', ":lua require('profile.core.functions').check_rust_tools()<CR>", desc = 'Check Rust tools' },
        { '<leader>ztc', ":lua require('profile.core.functions').check_zig_tools()<CR>", desc = 'Check Zig tools' },
    })
end

return M
