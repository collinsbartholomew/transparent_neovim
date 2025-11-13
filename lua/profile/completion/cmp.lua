-- lua/profile/cmp.lua
local M = {}
local cmp_enabled = true
local function safe_require(name)
    local ok, mod = pcall(require, name)
    return ok and mod or nil
end
-- Helper: has non-whitespace character before cursor
local function has_words_before()
    local col = vim.fn.col(".") - 1
    if col == 0 then
        return false
    end
    local line = vim.api.nvim_get_current_line()
    local char = line:sub(col, col)
    return not char:match("%s")
end
function M.setup()
    local cmp = safe_require("cmp")
    if not cmp then
        vim.notify("nvim-cmp not available", vim.log.levels.WARN)
        return
    end
    local luasnip = safe_require("luasnip")
    if not luasnip then
        vim.notify("luasnip not available; snippet support will be disabled", vim.log.levels.WARN)
    else
        local loader = safe_require("luasnip.loaders.from_vscode")
        if loader then
            loader.lazy_load()
        end
        -- sensible extension for react/tsx
        pcall(function()
            luasnip.filetype_extend("javascriptreact", { "javascript", "html" })
            luasnip.filetype_extend("typescriptreact", { "typescript", "javascript", "html" })
        end)
    end
    -- icons & source labels (keep short)
    local kind_icons = {
        Text = "",
        Method = "",
        Function = "",
        Constructor = "",
        Field = "",
        Variable = "",
        Class = "",
        Interface = "",
        Module = "",
        Property = "",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = "",
    }
    local source_names = {
        nvim_lsp = "LSP",
        luasnip = "Snp",
        buffer = "Buf",
        path = "Path",
        cmdline = "Cmd",
        crates = "Crate",
        git = "Git",
    }
    -- sensible default sources (we keep a file-size aware buffer filter)
    local function buffer_source_opts(max_size)
        return {
            name = "buffer",
            priority = 400,
            max_item_count = 10,
            option = {
                get_bufnrs = function()
                    local bufs = {}
                    local buflist = vim.api.nvim_list_bufs()
                    for _, b in ipairs(buflist) do
                        if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_option(b, "buftype") == "" then
                            local fname = vim.api.nvim_buf_get_name(b)
                            if fname == "" then
                                -- keep unnamed buffers
                                bufs[b] = true
                            else
                                local ok, stat = pcall(vim.loop.fs_stat, fname)
                                if ok and stat and stat.size and stat.size < max_size then
                                    bufs[b] = true
                                end
                            end
                        end
                    end
                    return vim.tbl_keys(bufs)
                end,
            },
        }
    end
    -- main cmp.setup
    cmp.setup({
        enabled = function()
            return cmp_enabled
        end,
        -- single canonical completion options
        completion = { completeopt = "menu,menuone,noinsert,noselect", keyword_length = 1 },
        snippet = {
            expand = function(args)
                if luasnip then
                    luasnip.lsp_expand(args.body)
                end
            end,
        },
        performance = {
            debounce = 30,
            throttle = 20,
            fetching_timeout = 100,
            max_view_entries = 25,
            async_budget = 2,
            max_chunk_size = 1000,
        },
        experimental = {
            ghost_text = { hl_group = "CmpGhostText" },
        },
        view = {
            entries = { name = "custom", selection_order = "near_cursor" },
        },
        window = {
            completion = cmp.config.window.bordered({
                winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpCursorLine",
                col_offset = -3,
                side_padding = 1,
            }),
            documentation = cmp.config.window.bordered({
                winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocBorder",
                max_width = 60,
                max_height = 15,
            }),
        },
        formatting = {
            fields = { "abbr", "kind", "menu" },
            format = function(entry, item)
                local kind = item.kind or "Text"
                item.kind = (kind_icons[kind] or "●") .. " " .. kind
                item.kind_hl_group = "CmpItemKind" .. kind
                local sname = entry.source and entry.source.name or ""
                item.menu = source_names[sname] or ("[" .. sname .. "]")
                if #item.abbr > 48 then
                    item.abbr = item.abbr:sub(1, 45) .. "…"
                end
                return item
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping(function(fallback)
                if cmp.visible() and cmp.get_selected_entry() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                elseif luasnip and luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                elseif has_words_before() then
                    cmp.complete()
                    vim.schedule(function()
                        if cmp.visible() and not cmp.get_selected_entry() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                        end
                    end)
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip and luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
        }),
        sorting = {
            priority_weight = 2,
            comparators = {
                cmp.config.compare.score,
                cmp.config.compare.exact,
                cmp.config.compare.locality,
                cmp.config.compare.recently_used,
                cmp.config.compare.offset,
                cmp.config.compare.kind,
                cmp.config.compare.sort_text,
                cmp.config.compare.length,
                cmp.config.compare.order,
            },
        },
        -- single canonical sources block (we'll override per-filetype below)
        sources = (function()
            local max_size = 1024 * 1024 -- 1MB
            local file_size = nil
            local ok, stat = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
            if ok and stat and stat.size then
                file_size = stat.size
            end
            if file_size and file_size > max_size then
                -- large file: prioritize LSP and path to avoid heavy buffer scanning
                return cmp.config.sources({
                    { name = "nvim_lsp", priority = 1000, max_item_count = 10, keyword_length = 4 },
                    { name = "path", priority = 800, max_item_count = 5 },
                })
            end
            return cmp.config.sources({
                { name = "nvim_lsp", priority = 1000, max_item_count = 20, keyword_length = 3 },
                { name = "luasnip", priority = 900, max_item_count = 10 },
                { name = "path", priority = 800, max_item_count = 10 },
                buffer_source_opts(1024 * 1024),
            })
        end)(),
    })
    -- cmdline setups
    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = "path" },
        }, {
            { name = "cmdline", keyword_length = 2 },
        }),
    })
    cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = "buffer" },
        },
    })
    -- filetype-specific tweaks
    if safe_require("crates") then
        cmp.setup.filetype({ "rust", "toml" }, {
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "crates" },
                { name = "luasnip" },
            }, {
                { name = "buffer" },
            }),
        })
    end
    cmp.setup.filetype("python", {
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
        }, {
            { name = "path" },
            { name = "buffer", keyword_length = 4 },
        }),
    })
    cmp.setup.filetype("motoko", {
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "path" },
        }, {
            { name = "buffer", keyword_length = 2 },
        }),
    })
    -- git commit
    if safe_require("cmp_git") then
        safe_require("cmp_git").setup()
        cmp.setup.filetype("gitcommit", {
            sources = cmp.config.sources({
                { name = "git" },
            }, {
                { name = "buffer" },
            }),
        })
    else
        cmp.setup.filetype("gitcommit", { sources = { { name = "buffer" } } })
    end
    -- crates on demand (also via autocmd to avoid forcing load)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "rust", "toml" },
        callback = function()
            if safe_require("crates") then
                -- reconfigure or ensure crates source is available; many configs just rely on the source existing
            end
        end,
    })
    -- auto-import edits on confirm (apply additionalTextEdits from LSP completions)
    cmp.event:on("confirm_done", function(event)
        local entry = event.entry
        if not entry then
            return
        end
        if entry.source and entry.source.name == "nvim_lsp" then
            local item = entry:get_completion_item()
            if item and item.additionalTextEdits then
                vim.lsp.util.apply_text_edits(item.additionalTextEdits, vim.api.nvim_get_current_buf(), "utf-16")
            end
        end
    end)
    -- Commands
    vim.api.nvim_create_user_command("CmpStatus", function()
        local status = {
            enabled = cmp_enabled,
            active_buf = vim.api.nvim_get_current_buf(),
            sources = vim.tbl_map(function(s)
                return s.name
            end, cmp.get_config().sources or {}),
        }
        print(vim.inspect(status))
    end, { desc = "Show basic cmp status" })
    vim.api.nvim_create_user_command("CmpToggle", function()
        cmp_enabled = not cmp_enabled
        vim.notify("cmp " .. (cmp_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle nvim-cmp" })
end
return M
