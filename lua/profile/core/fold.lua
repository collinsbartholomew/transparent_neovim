local M = {}

function M.setup()
    -- Code folding using Treesitter
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldtext = [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').' ... '.trim(getline(v:foldend))]]
    
    -- Smart folding - don't fold by default
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    vim.opt.foldenable = true

    -- Modern fold appearance
    vim.opt.fillchars:append {
        fold = " ",
        foldsep = " ",
    }

    -- Custom fold text
    local function fold_text()
        local line = vim.fn.getline(vim.v.foldstart)
        local sub = vim.fn.substitute(line, "/\\*\\|\\*/\\|{{\\d\\=", "", "g")
        local fold_size = vim.v.foldend - vim.v.foldstart + 1
        local fold_char = "⋯ " -- custom fold character
        return string.format("%s %s [%d lines]", sub, fold_char, fold_size)
    end

    -- Apply custom fold text
    vim.opt.foldtext = fold_text

    -- Fold preservation for better UX
    local save_fold = vim.api.nvim_create_augroup("Save_fold", { clear = true })
    vim.api.nvim_create_autocmd({"BufWinLeave"}, {
        pattern = "*.*",
        group = save_fold,
        command = "mkview"
    })
    vim.api.nvim_create_autocmd({"BufWinEnter"}, {
        pattern = "*.*",
        group = save_fold,
        command = "silent! loadview"
    })

    -- Custom fold keymaps
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
    vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith)
    vim.keymap.set('n', 'K', function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()
        if not winid then
            vim.lsp.buf.hover()
        end
    end)
end

return M