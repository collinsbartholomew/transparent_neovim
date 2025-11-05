--nvim-cmp setup
--This file configures the completion engine for Neovim

local M = {}

function M.setup()
    local cmp_ok, cmp = pcall(require, "cmp")
    if not cmp_ok then
        vim.notify("nvim-cmp not available", vim.log.levels.WARN)
        return
    end
    
    local luasnip_ok, luasnip = pcall(require, "luasnip")
    if not luasnip_ok then
        vim.notify("luasnip not available", vim.log.levels.WARN)
        return
    end

    -- Extend filetypes so that react snippets are available in jsx/tsx files
    luasnip.filetype_extend("javascriptreact", { "javascript" })
    luasnip.filetype_extend("typescriptreact", { "typescript" })

    -- CustomizedCMP appearance
    -- Define icons for different completion kinds for better visual recognition
    local kind_icons = {
        Text = "", -- Text completion
        Method = "󰆧", -- Method completion
        Function = "󰊕", -- Function completion
        Constructor = "", -- Constructor completion
        Field = "󰇽", -- Field completion
        Variable = "󰂡", -- Variable completion
        Class = "󰠱", -- Class completion
        Interface = "", -- Interface completion
        Module = "", --Module completion
        Property = "󰜢", -- Property completion
        Unit = "", -- Unit completion
        Value = "󰎠", -- Value completion
        Enum = "", -- Enum completion
        Keyword = "󰌋", -- Keyword completion
        Snippet = "", -- Snippet completion
        Color = "󰏘", -- Color completion
        File = "󰈙", -- File completion
        Reference = "", -- Reference completion
        Folder = "󰉋", -- Folder completion
        EnumMember = "", -- Enum member completion
        Constant = "󰏿", -- Constant completion
        Struct = "", -- Struct completion
        Event = "", -- Event completion
        Operator = "󰆕", -- Operator completion
        TypeParameter = "󰅲", -- Type parameter completion
    }

    local function has_words_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    -- Main CMP setup for insert mode
    cmp.setup({
        -- Configure snippet expansion
        snippet = {
            expand = function(args)
                -- Use luasnip to expand snippets
                luasnip.lsp_expand(args.body)
            end,
        },

        -- Configure completion window appearance with proper styling
        window = {
            -- Completion popup window with border
            completion = cmp.config.window.bordered({
                winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpCursorLine,Search:None",
                col_offset = -3,
                side_padding = 0,
                max_width = 45,
                max_height = 8,
                border = "rounded",
                zindex = 1000,
            }),
            -- Documentation popup window with border
            documentation = cmp.config.window.bordered({
                winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocBorder,CursorLine:CmpDocCursor,Search:None",
                max_width = 35,
                max_height = 5,
                zindex = 1001,
                border = "rounded",
            }),
        },

        -- Configure how completions are formatted and displayed with smaller font
        formatting = {
            fields = { "kind", "abbr", "menu" }, -- Display fields in this order
            format = function(entry, vim_item)
                -- Add icons to completion kinds only (no kind text)
                vim_item.kind = kind_icons[vim_item.kind] or vim_item.kind

                -- Set source labels for different completion sources
                vim_item.menu = ({
                    nvim_lsp = "[LSP]",    -- Language Server Protocol
                    luasnip = "[Snippet]", -- Snippet engine
                    buffer = "[Buffer]",   -- Current buffer
                    path = "[Path]",       -- File path
                    cmdline = "[Cmd]",     -- Command line
                })[entry.source.name]

                return vim_item
            end,
        },

        -- Configure key mappings for completion
        mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4), -- Scroll documentation up
            ["<C-f>"] = cmp.mapping.scroll_docs(4),  -- Scroll documentation down
            ["<C-Space>"] = cmp.mapping.complete(),  -- Trigger completion manually
            ["<C-e>"] = cmp.mapping.abort(),         -- Close completion menu
            ["<CR>"] = cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
            }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    local entry = cmp.get_selected_entry()
                    if not entry then
                        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                    else
                        cmp.confirm({
                            behavior = cmp.ConfirmBehavior.Replace,
                            select = true,
                        })
                    end
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, {
                "i",
                "s",
            }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                -- Shift+Tab navigation through completions and snippets
                if cmp.visible() then
                    -- If completion menu is visible, select previous item
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    -- If in a snippet, jumpto previous field
                    luasnip.jump(-1)
                else
                    -- Otherwise, use fallback behavior
                    fallback()
                end
            end, { "i", "s" }),
        }),

        -- Configure completion sources and their priority
        sources = cmp.config.sources({
            { name = "nvim_lsp" },                   -- Language Server Protocol completions (highest priority)
            { name = "luasnip" },                    -- Snippet completions
        }, {
            { name = "buffer", keyword_length = 3 }, -- Buffer completions (3 chars minimum)
            { name = "path" },                       -- File path completions
        }),

        -- Configure completion behavior settings
        completion = {
            completeopt = "menu,menuone,noinsert", -- Completion options
            keyword_length = 1,                    -- Minimum keyword length to trigger completion
        },


        preselect = cmp.PreselectMode.None,
        confirmation = {
            default_behavior = cmp.ConfirmBehavior.Replace,
            get_commit_characters = function(commit_characters)
                return commit_characters
            end,
        },
        -- Make text completions have the lowest priority
        sorting = {
            priority_weight = 2,
            comparators = {
                -- Deprioritize Text completions (kind 1)
                function(entry1, entry2)
                    local kind1 = entry1:get_kind()
                    local kind2 = entry2:get_kind()
                    local is_text1 = kind1 == 1 -- Text kind
                    local is_text2 = kind2 == 1 -- Text kind
                    if is_text1 and not is_text2 then
                        return false
                    elseif is_text2 and not is_text1 then
                        return true
                    end
                    return nil -- Continue with other comparators
                end,
                -- Prioritize LSP completions
                cmp.config.compare.locality,
                cmp.config.compare.recently_used,
                cmp.config.compare.score,
                cmp.config.compare.offset,
                cmp.config.compare.order,
            },
        },
    })

    -- Command mode completion
    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {{ name = "cmdline" }},
    })

    -- Search mode completion
    cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {{ name = "buffer" }},
    })

    -- Filetype-specific configurations (only where different from default)
    cmp.setup.filetype("rust", {
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "crates" },
            { name = "luasnip" },
        }, {
            { name = "buffer", keyword_length = 3 },
            { name = "path" },
        }),
    })
    
    cmp.setup.filetype("toml", {
        sources = cmp.config.sources({
            { name = "crates" },
            { name = "buffer", keyword_length = 3 },
            { name = "path" },
        }),
    })
end

return M