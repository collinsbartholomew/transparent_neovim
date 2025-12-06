--Custom functions
local M = {}

-- Toggle diagnostics
function M.toggle_diagnostics()
	vim.g.diagnostics_enabled = not (vim.g.diagnostics_enabled or true)
	if vim.g.diagnostics_enabled then
		vim.diagnostic.enable()
		vim.notify("Diagnostics enabled", vim.log.levels.INFO)
	else
		vim.diagnostic.enable(false)
		vim.notify("Diagnostics disabled", vim.log.levels.INFO)
	end
end

-- Generic tool checker function
local function check_tools(category, tools)
	local missing_tools = {}
	local installed_tools = {}

	for _, tool in ipairs(tools) do
		local found = vim.fn.executable(tool.cmd) == 1
		if found then
			table.insert(installed_tools, tool.name)
		else
			table.insert(missing_tools, tool.name)
		end
	end

	print("=== " .. category .. " Development Tools ===")
	print("Installed tools:")
	for _, tool in ipairs(installed_tools) do
		print("  ✓ " .. tool)
	end

	if #missing_tools > 0 then
		print("\nMissing tools:")
		for _, tool in ipairs(missing_tools) do
			print("  ✗ " .. tool)
		end
		print("\nInstall missing tools for full " .. category:lower() .. " support")
	else
		print("\nAll tools installed! You're ready for " .. category:lower() .. " development.")
	end
end

-- Check if required tools for assembly development are installed
function M.check_asm_tools()
	local tools = {
		{ name = "nasm",     cmd = "nasm" },
		{ name = "as (GAS)", cmd = "as" },
		{ name = "ld",       cmd = "ld" },
		{ name = "gdb",      cmd = "gdb" },
		{ name = "objdump",  cmd = "objdump" },
	}
	check_tools("Assembly", tools)
end

-- Quick compile and run for assembly
function M.asm_run()
	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname == "" or vim.fn.filereadable(bufname) ~= 1 then
		vim.notify("No valid file to compile", vim.log.levels.ERROR)
		return
	end
	local basename = vim.fn.fnamemodify(bufname, ":r")
	local extension = vim.fn.fnamemodify(bufname, ":e")

	if extension == "asm" then
		-- NASM compilation
		local cmd = string.format(
			"nasm -f elf64 %s.asm -o %s.o && ld %s.o -o %s && ./%s",
			basename,
			basename,
			basename,
			basename,
			basename
		)
		-- Run the pipeline asynchronously to avoid blocking Neovim
		local job = vim.fn.jobstart({"sh", "-c", cmd}, {
			stdout_buffered = true,
			stderr_buffered = true,
			on_stdout = function(_, data)
				if data and #data > 0 then
					for _, line in ipairs(data) do
						if line ~= "" then
							print(line)
						end
					end
				end
			end,
			on_stderr = function(_, data)
				if data and #data > 0 then
					for _, line in ipairs(data) do
						if line ~= "" then
							print(line)
						end
					end
				end
			end,
			on_exit = function(_, code)
				if code == 0 then
					vim.schedule(function()
						vim.notify("Assembly build/run finished successfully", vim.log.levels.INFO)
					end)
				else
					vim.schedule(function()
						vim.notify("Assembly build/run failed (exit code " .. tostring(code) .. ")", vim.log.levels.ERROR)
					end)
				end
			end,
		})
		if job <= 0 then
			vim.notify("Failed to start assembly job", vim.log.levels.ERROR)
		end
	elseif extension == "s" or extension == "S" then
		-- GAS compilation
		local cmd = string.format(
			"as %s.%s -o %s.o && ld %s.o -o %s && ./%s",
			basename,
			extension,
			basename,
			basename,
			basename,
			basename
		)
		local job = vim.fn.jobstart({"sh", "-c", cmd}, {
			stdout_buffered = true,
			stderr_buffered = true,
			on_stdout = function(_, data)
				if data and #data > 0 then
					for _, line in ipairs(data) do
						if line ~= "" then
							print(line)
						end
					end
				end
			end,
			on_stderr = function(_, data)
				if data and #data > 0 then
					for _, line in ipairs(data) do
						if line ~= "" then
							print(line)
						end
					end
				end
			end,
			on_exit = function(_, code)
				if code == 0 then
					vim.schedule(function()
						vim.notify("Assembly build/run finished successfully", vim.log.levels.INFO)
					end)
				else
					vim.schedule(function()
						vim.notify("Assembly build/run failed (exit code " .. tostring(code) .. ")", vim.log.levels.ERROR)
					end)
				end
			end,
		})
		if job <= 0 then
			vim.notify("Failed to start assembly job", vim.log.levels.ERROR)
		end
	else
		vim.notify("Not an assembly file", vim.log.levels.WARN)
	end
end

-- Check if required tools for C/C++ development are installed
function M.check_cpp_tools()
	local tools = {
		{ name = "clang",   cmd = "clang" },
		{ name = "clang++", cmd = "clang++" },
		{ name = "gcc",     cmd = "gcc" },
		{ name = "g++",     cmd = "g++" },
		{ name = "gdb",     cmd = "gdb" },
		{ name = "cmake",   cmd = "cmake" },
		{ name = "make",    cmd = "make" },
	}
	check_tools("C/C++", tools)
end

-- Check if required tools for Rust development are installed
function M.check_rust_tools()
	local tools = {
		{ name = "rustc",  cmd = "rustc" },
		{ name = "cargo",  cmd = "cargo" },
		{ name = "rustfmt", cmd = "rustfmt" },
		{ name = "clippy", cmd = "cargo-clippy" },
	}
	check_tools("Rust", tools)
end

-- Check if required tools for Zig development are installed
function M.check_zig_tools()
	local tools = {
		{ name = "zig",    cmd = "zig" },
		{ name = "zls",    cmd = "zls" },
	}
	check_tools("Zig", tools)
end

-- Reload a Lua module by clearing it from package.loaded
function M.reload_lua_module()
	local module_name = vim.fn.input("Module name to reload: ", "", "file")
	if module_name == "" then
		vim.notify("No module specified", vim.log.levels.WARN)
		return
	end
	package.loaded[module_name] = nil
	local ok, _ = pcall(require, module_name)
	if ok then
		vim.notify("Reloaded: " .. module_name, vim.log.levels.INFO)
	else
		vim.notify("Failed to reload: " .. module_name, vim.log.levels.ERROR)
	end
end

return M
