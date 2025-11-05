-- added-by-agent: flutter-setup 20251020-160000
-- mason: dart-debug-adapter
-- manual: flutter/dart/fvm install commands listed in README

local M = {}

local function get_flutter_cmd(config)
	config = config or {}
	if config.use_fvm and vim.fn.executable("fvm") == 1 then
		return "fvm flutter"
	else
		return "flutter"
	end
end

local function get_dart_cmd(config)
	config = config or {}
	if config.use_fvm and vim.fn.executable("fvm") == 1 then
		return "fvm dart"
	else
		return "dart"
	end
end

function M.setup(config)
	config = config or {}

	-- Check if flutter is available
	if vim.fn.executable("flutter") == 0 then
		vim.notify("Flutter not found in PATH. Some commands may not work.", vim.log.levels.WARN)
	end

	-- FvmUse command
	vim.api.nvim_create_user_command("FvmUse", function(opts)
		if vim.fn.executable("fvm") == 0 then
			vim.notify("FVM not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local fvm_cmd = string.format("%s use %s", get_flutter_cmd(config), opts.args)
		vim.cmd("belowright new | terminal " .. fvm_cmd)
	end, { nargs = 1 })

	-- FlutterRun command
	vim.api.nvim_create_user_command("FlutterRun", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		vim.cmd("write")
		local flutter_cmd = string.format("%s run", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterRunDev command
	vim.api.nvim_create_user_command("FlutterRunDev", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		vim.cmd("write")
		local flutter_cmd = string.format("%s run --flavor development", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterRunProd command
	vim.api.nvim_create_user_command("FlutterRunProd", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		vim.cmd("write")
		local flutter_cmd = string.format("%s run --release", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterTest command
	vim.api.nvim_create_user_command("FlutterTest", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local flutter_cmd = string.format("%s test", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterTestWatch command
	vim.api.nvim_create_user_command("FlutterTestWatch", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local flutter_cmd = string.format("%s test --watch", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterTestCoverage command
	vim.api.nvim_create_user_command("FlutterTestCoverage", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local flutter_cmd = string.format("%s test --coverage", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterBuild command
	vim.api.nvim_create_user_command("FlutterBuild", function(opts)
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local target = opts.args ~= "" and opts.args or "apk"
		local flutter_cmd = string.format("%s build %s", get_flutter_cmd(config), target)
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, { nargs = "*" })

	-- FlutterClean command
	vim.api.nvim_create_user_command("FlutterClean", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local flutter_cmd = string.format("%s clean", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterPubGet command
	vim.api.nvim_create_user_command("FlutterPubGet", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		localflutter_cmd = string.format("%s pubget", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterPubUpgradecommand
	vim.api.nvim_create_user_command("FlutterPubUpgrade", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local flutter_cmd = string.format("%s pub upgrade", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterPackages command
	vim.api.nvim_create_user_command("FlutterPackages", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter notfound in PATH.", vim.log.levels.ERROR)
			return
		end
		localflutter_cmd = string.format("%s publist", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterReloadcommand (alias to flutter-tools reload)
	vim.api.nvim_create_user_command("FlutterReload", function()
		local flutter_tools_status, flutter_tools = pcall(require, "flutter-tools")
		if flutter_tools_status then
			flutter_tools.reload()
		else
			vim.notify("Flutter tools not available for reload", vim.log.levels.WARN)
		end
	end, {})

	-- FlutterRestart command
	vim.api.nvim_create_user_command("FlutterRestart", function()
		local flutter_tools_status, flutter_tools = pcall(require, "flutter-tools")
		if flutter_tools_status then
			flutter_tools.restart()
		else
			vim.notify("Flutter tools not available for restart", vim.log.levels.WARN)
		end
	end, {})

	-- DartFormat command
	vim.api.nvim_create_user_command("DartFormat", function()
		if vim.fn.executable("dart") == 0 then
			vim.notify("Dart not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local dart_cmd = string.format("%s format .", get_dart_cmd(config))
		vim.cmd("belowright new | terminal " .. dart_cmd)
	end, {})

	-- DartAnalyze command
	vim.api.nvim_create_user_command("DartAnalyze", function()
		if vim.fn.executable("dart") == 0 then
			vim.notify("Dart not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local dart_cmd = string.format("%s analyze", get_dart_cmd(config))
		vim.cmd("belowright new | terminal " .. dart_cmd)
	end, {})

	-- DartFix command
	vim.api.nvim_create_user_command("DartFix", function()
		if vim.fn.executable("dart") == 0 then
			vim.notify("Dart not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local dart_cmd = string.format("%s fix --apply", get_dart_cmd(config))
		vim.cmd("belowright new | terminal " .. dart_cmd)
	end, {})

	-- DevTools command
	vim.api.nvim_create_user_command("DevTools", function()
		if vim.fn.executable("dart") == 0 then
			vim.notify("Dart not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local dart_cmd = string.format("%s pub global run devtools", get_dart_cmd(config))
		vim.cmd("belowright new | terminal " .. dart_cmd)
	end, {})

	-- MemoryProfile command
	vim.api.nvim_create_user_command("MemoryProfile", function()
		if vim.fn.executable("dart") == 0 then
			vim.notify("Dart not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local dart_cmd = string.format("%s pub run devtools --memory", get_dart_cmd(config))
		vim.cmd("belowright new | terminal " .. dart_cmd)
	end, {})

	-- SecurityAudit command
	vim.api.nvim_create_user_command("SecurityAudit", function()
		if vim.fn.executable("dart") == 0 then
			vim.notify("Dart not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local dart_cmd = string.format("%s pub global run pana", get_dart_cmd(config))
		vim.cmd("belowright new | terminal " .. dart_cmd)
	end, {})

	-- SecurityScan command
	vim.api.nvim_create_user_command("SecurityScan", function()
		if vim.fn.executable("dart") == 0 then
			vim.notify("Dart not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local dart_cmd = string.format("%s pub global activate pub_scanner && pub_scanner", get_dart_cmd(config))
		vim.cmd("belowright new | terminal " .. dart_cmd)
	end, {})

	-- FlutterDoctor command
	-- FlutterDoctor command
	vim.api.nvim_create_user_command("FlutterDoctor", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local flutter_cmd = string.format("%s doctor", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterDevices command
	vim.api.nvim_create_user_command("FlutterDevices", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local flutter_cmd = string.format("%s devices", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterEmulators command
	vim.api.nvim_create_user_command("FlutterEmulators", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local flutter_cmd = string.format("%s emulators", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterUpgrade command
	vim.api.nvim_create_user_command("FlutterUpgrade", function()
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		local flutter_cmd = string.format("%s upgrade", get_flutter_cmd(config))
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, {})

	-- FlutterCreate command
	vim.api.nvim_create_user_command("FlutterCreate", function(opts)
		if vim.fn.executable("flutter") == 0 then
			vim.notify("Flutter not found in PATH.", vim.log.levels.ERROR)
			return
		end
		if opts.args == "" then
			vim.notify("Please provide a project name", vim.log.levels.WARN)
			return
		end
		local flutter_cmd = string.format("%s create %s", get_flutter_cmd(config), opts.args)
		vim.cmd("belowright new | terminal " .. flutter_cmd)
	end, { nargs = 1 })

	-- Integrate with conform.nvim for formatting
	local conform_status, conform = pcall(require, "conform")
	if conform_status then
		-- We don't add to formatters_by_ft here because we want to keep it optional
		-- User can add this to their conform setup:
		-- formatters_by_ft = {
		--   dart = { "dart_format" },
		-- }
	end

	-- Integrate with lint.nvim for linting
	local lint_status, lint = pcall(require, "lint")
	if lint_status then
		-- We don't add to linters_by_ft here because we want to keep it optional
		-- User can add this to their lint setup:
		-- linters_by_ft = {
		--   dart = { "dart_analyze"},
		-- }
	end
end

return M

