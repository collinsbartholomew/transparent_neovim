local M = {}

function M.setup()
    -- Use expression-based folding for better performance
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    
    -- Smart folding - don't fold by default
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    vim.opt.foldenable = true

    -- Modern fold appearance
    vim.opt.fillchars:append {
        fold = " ",
        foldsep = " ",
    }

    -- Custom fold text with line count
    local function fold_text()
        local line = vim.fn.getline(vim.v.foldstart)
        local sub = vim.fn.substitute(line, "/\\*\\|\\*/\\|{{\\d\\=", "", "g")
        local fold_size = vim.v.foldend - vim.v.foldstart + 1
        return string.format("%s [%d lines]", sub, fold_size)
    end

    -- Apply custom fold text
    vim.opt.foldtext = fold_text
end

return M
