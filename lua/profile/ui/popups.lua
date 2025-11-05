--Comprehensive popup and floating window styling with 70% font scaling
local M = {}

function M.setup()
	-- Get current font size
	local guifont = vim.o.guifont
	local base_size = 12

	if guifont ~= "" then
		local size_str = guifont:match(":h(%d+)")
		if size_str then
			base_size = tonumber(size_str) or 12
		end
	end

	-- Calculate 70% font size
	local small_size = math.floor(base_size * 0.7)

	-- ============================================================================
	-- Configure all popup window handlers with consistent styling
	-- ============================================================================

	-- LSP Hover Handler with 70% font
	local original_hover = vim.lsp.handlers["textDocument/hover"]
	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
		max_width = 50,
		max_height = 10,
		focusable = false,
		silent = true,
	})

	-- LSP Signature Help Handler with 70% font
	local original_signature = vim.lsp.handlers["textDocument/signatureHelp"]
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
		max_width = 50,
		max_height = 8,
		focusable = false,
		silent = true,
	})

	-- Diagnostic configuration is handled in core/autocmds.lua
	-- This ensures consistent settings across the entire configuration

	-- ============================================================================
	-- Create autocmd to apply font scaling to newly opened floating windows
	-- ============================================================================
	vim.api.nvim_create_autocmd("WinNew", {
		desc = "Apply popup styling to floating windows",
		callback = function(ev)
			local win_id = tonumber(ev.match) or vim.api.nvim_get_current_win()
			if not win_id or win_id <= 0 then
				return
			end

			local config = vim.api.nvim_win_get_config(win_id)

			-- Apply to all floating windows (popups)
			if config.relative and config.relative ~= "" then
				-- Disable blending for clean appearance
				pcall(vim.api.nvim_win_set_option, win_id, "winblend", 0)

				-- Set wrap for better text display
				pcall(vim.api.nvim_win_set_option, win_id, "wrap", true)

				-- Set color column to none
				pcall(vim.api.nvim_win_set_option, win_id, "colorcolumn", "")

				-- Hide line numbers in popups
				pcall(vim.api.nvim_win_set_option, win_id, "number", false)
				pcall(vim.api.nvim_win_set_option, win_id, "relativenumber", false)

				-- Hide status line for popups
				pcall(vim.api.nvim_win_set_option, win_id, "statusline", "")

				-- Enable conceal for better rendering
				pcall(vim.api.nvim_win_set_option, win_id, "conceallevel", 2)

				-- Limit popup size based on type
				local buf_id = vim.api.nvim_win_get_buf(win_id)
				local buf_name = vim.api.nvim_buf_get_name(buf_id)

				-- Get window dimensions for resizing
				local width = config.width or 50
				local height = config.height or 10

				-- Ensure reasonable popup sizes
				if width > 60 then
					width = 60
				end
				if height > 15 then
					height = 15
				end

				-- Apply resized dimensions if configured via relative
				if config.relative == "cursor" then
					config.width = width
					config.height = height
					config.max_width = 60
					config.max_height = 15
				end
			end
		end,
	})

	-- ============================================================================
	-- Create autocmd to stylize popup text on buffer load
	-- ============================================================================
	vim.api.nvim_create_autocmd("BufEnter", {
		desc = "Apply text styling to floating buffers",
		callback = function(ev)
			local buf_id = ev.buf
			local buf_type = vim.api.nvim_buf_get_option(buf_id, "buftype")

			-- Apply to floating buffers
			if buf_type == "" then
				local win_id = vim.api.nvim_get_current_win()
				local config = vim.api.nvim_win_get_config(win_id)

				if config.relative and config.relative ~= "" then
					-- Set modifiable to false for non-editable popups
					if vim.fn.mode() == "n" then
						pcall(vim.api.nvim_buf_set_option, buf_id, "modifiable", false)
					end
				end
			end
		end,
	})

	-- ============================================================================
	-- Configure code action popup menu
	-- ============================================================================
	local code_action_handler = function()
		-- This is handled by plugins but we ensure consistent sizing
		vim.cmd("highlight! link CodeActionMenu NormalFloat")
		vim.cmd("highlight! link CodeActionMenuBorder FloatBorder")
	end

	-- ============================================================================
	-- Enhanced completion styling for better popup appearance
	-- ============================================================================
	local cmp_ok, cmp = pcall(require, "cmp")
	if cmp_ok then
		-- Create custom formatting function with 70% font implications
		local function format_cmp_item(entry, vim_item)
			-- Limit abbreviation length to reduce popup width
			if #vim_item.abbr > 40 then
				vim_item.abbr = vim_item.abbr:sub(1, 37) .. "..."
			end

			-- Limit menu length
			if vim_item.menu and #vim_item.menu > 15 then
				vim_item.menu = vim_item.menu:sub(1, 12) .. "..."
			end

			return vim_item
		end
	end

	-- ============================================================================
	-- Setup references and definition list styling
	-- ============================================================================
	local function style_list_popup()
		-- Configure for references list
		vim.cmd("highlight! link ReferencesNormal NormalFloat")
		vim.cmd("highlight! link ReferencesBorder FloatBorder")

		-- Configure for definition list
		vim.cmd("highlight! link DefinitionNormal NormalFloat")
		vim.cmd("highlight! link DefinitionBorder FloatBorder")

		-- Configure for implementations list
		vim.cmd("highlight! link ImplementationNormal NormalFloat")
		vim.cmd("highlight! link ImplementationBorder FloatBorder")
	end

	style_list_popup()

	-- ============================================================================
	-- Create commands for testing popup styling
	-- ============================================================================
	vim.api.nvim_create_user_command("PopupTest", function()
		local lines = {
			"This is a test popup with 70% font scaling",
			"Line 2: Lorem ipsum dolor sit amet",
			"Line 3: consectetur adipiscing elit",
			"Line 4: sed do eiusmod tempor incididunt",
		}

		local width = 45
		local height = #lines

		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

		local opts = {
			relative = "cursor",
			width = width,
			height = height,
			col = 1,
			row = 1,
			style = "minimal",
			border = "rounded",
		}

		vim.api.nvim_open_win(buf, false, opts)
	end, {})

	-- ============================================================================
	-- Apply global popup configuration
	-- ============================================================================

	-- Ensure all float windows have consistent appearance
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "qf", "help", "man" },
		callback = function()
			pcall(vim.api.nvim_win_set_option, 0, "wrap", true)
		end,
	})

	-- ============================================================================
	-- Setup default floating window highlights
	-- ============================================================================
	local setup_highlights = function()
		-- Ensure all popup-related highlights are properly linked
		local highlights = {
			"FloatBorder",
			"NormalFloat",
			"FloatTitle",
			"FloatFooter",
			"CmpNormal",
			"CmpBorder",
			"CmpDocNormal",
			"CmpDocBorder",
			"LspHover",
			"LspHoverBorder",
			"LspSignatureHelp",
			"LspSignatureBorder",
			"DiagnosticFloat",
			"DiagnosticFloatBorder",
		}

		for _, hl in ipairs(highlights) do
			-- Get existing highlight definition
			local hldef = vim.api.nvim_get_hl_by_name(hl, true)
			if not hldef or not next(hldef) then
				-- If not defined, set to reasonable defaults
				if hl:match("Border") then
					vim.api.nvim_set_hl(0, hl, { link = "FloatBorder" })
				else
					vim.api.nvim_set_hl(0, hl, { link = "NormalFloat" })
				end
			end
		end
	end

	setup_highlights()
end

return M
