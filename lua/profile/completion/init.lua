local M = {}

function M.setup()
    local cmp = require("cmp")

    cmp.setup({
        snippet = {
            expand = function(args)
                vim.snippet.expand(args.body)
            end,
        },
        window = {
            completion = cmp.config.window.bordered({
                border = "rounded",
                winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None,FloatBorder:CmpBorder",
                scrollbar = false,
                col_offset = -3,
                side_padding = 1,
            }),
            documentation = cmp.config.window.bordered({
                border = "rounded",
                winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder",
                max_height = 15,
                max_width = 60,
            }),
        },
        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, vim_item)
                local kind_icons = {
                    Text = "",
                    Method = "",
                    Function = "",
                    Constructor = "略",
                    Field = "",
                    Variable = "",
                    Class = "",
                    Interface = "",
                    Module = "",
                    Property = "",
                    Unit = "",
                    Value = "",
                    Enum = "",
                    Keyword = "",
                    Snippet = "",
                    Color = "",
                    File = "",
                    Reference = "",
                    Folder = "",
                    EnumMember = "",
                    Constant = "",
                    Struct = "",
                    Event = "",
                    Operator = "洛",
                    TypeParameter = "",
                }
                vim_item.kind = string.format(' %s %s', kind_icons[vim_item.kind] or "", vim_item.kind)
                vim_item.menu = ({
                    nvim_lsp = "[LSP]",
                    buffer = "[Buf]",
                    path = "[Path]",
                    cmdline = "[CMD]",
                })[entry.source.name]
                return vim_item
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ 
                behavior = cmp.ConfirmBehavior.Replace,
                select = false 
            }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif vim.snippet.active({ direction = 1 }) then
                    vim.snippet.jump(1)
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif vim.snippet.active({ direction = -1 }) then
                    vim.snippet.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
            { name = "nvim_lsp", priority = 1000 },
            { name = "path", priority = 750 },
        }, {
            {
                name = "buffer",
                priority = 500,
                option = {
                    keyword_length = 3,
                    get_bufnrs = function()
                        local bufs = {}
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            bufs[vim.api.nvim_win_get_buf(win)] = true
                        end
                        return vim.tbl_keys(bufs)
                    end,
                },
            },
        }),
        experimental = {
            ghost_text = {
                hl_group = "CmpGhostText",
            },
        },
        performance = {
            debounce = 60,
            throttle = 30,
            fetching_timeout = 500,
            confirm_resolve_timeout = 80,
            async_budget = 1,
            max_view_entries = 200,
        },
    })

    -- Cmdline completion
    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } },
            { name = "path" },
        },
        window = {
            completion = cmp.config.window.bordered({
                border = "rounded",
                winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder",
            }),
        },
    })

    -- Search mode completion
    cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
        window = {
            completion = cmp.config.window.bordered({
                border = "rounded",
                winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder",
            }),
        },
    })
end

return M
