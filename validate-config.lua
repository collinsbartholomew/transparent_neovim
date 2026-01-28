-- Configuration validation script
local function validate_config()
	local issues = {}
	
	-- Check if required modules exist
	local modules = {
		"profile.core.options",
		"profile.core.keymaps", 
		"profile.core.autocmds",
		"profile.ui.theme",
		"profile.completion.init",
	}
	
	for _, module in ipairs(modules) do
		local ok, _ = pcall(require, module)
		if not ok then
			table.insert(issues, "Missing module: " .. module)
		end
	end
	
	-- Check theme configuration
	local theme_ok, theme = pcall(require, "profile.ui.theme")
	if theme_ok then
		if type(theme.toggle_theme) ~= "function" then
			table.insert(issues, "Theme toggle function not found")
		end
	end
	
	-- Check cursor configuration
	local cursor = vim.opt.guicursor:get()
	local cursor_str = table.concat(cursor, ",")
	if not cursor_str or not string.match(cursor_str, "block") then
		table.insert(issues, "Cursor not set to block mode")
	end
	
	-- Check mouse disabled
	if vim.opt.mouse:get() ~= "" then
		table.insert(issues, "Mouse not disabled")
	end
	
	-- Check indentation settings
	local listchars = vim.opt.listchars:get()
	if not listchars.leadmultispace then
		table.insert(issues, "Lead multispace not configured for blank line indentation")
	end
	
	-- Report results
	if #issues == 0 then
		print("✅ Configuration validation passed!")
		return true
	else
		print("❌ Configuration issues found:")
		for _, issue in ipairs(issues) do
			print("  - " .. issue)
		end
		return false
	end
end

return validate_config()