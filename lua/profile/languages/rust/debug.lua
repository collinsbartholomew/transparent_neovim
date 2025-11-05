--added-by-agent: rust-setup 20251020
-- Mason: codelldb
local M = {}

local function get_codelldb_paths()
	local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
	if not mason_registry_ok then
		return nil
	end

	local pkg_ok, pkg = pcall(mason_registry.get_package, "codelldb")
	if not pkg_ok or not pkg then
		return nil
	end

	-- Check if get_install_path method exists
	if not pkg.get_install_path then
		-- Try alternative method to get the install path
		local install_path = pkg.install_path or (pkg.root_dir and pkg.root_dir .. "/packages/codelldb")
		if not install_path then
			return nil
		end
		
		local adapter
		local liblldb

		if vim.fn.has("mac") == 1 then
			adapter = install_path .. "/extension/adapter/codelldb"
			liblldb = install_path .. "/extension/lldb/lib/liblldb.dylib"
		elseif vim.fn.has("unix") == 1 then
			adapter = install_path .. "/extension/adapter/codelldb"
			liblldb = install_path .. "/extension/lldb/lib/liblldb.so"
		elseif vim.fn.has("win32") == 1 then
			adapter = install_path .. "/extension/adapter/codelldb.exe"
			liblldb = install_path .. "/extension/lldb/bin/liblldb.dll"
		end

		return adapter, liblldb
	end

	local install_path_ok, install_path = pcall(function()
		return pkg:get_install_path()
	end)
	if not install_path_ok or not install_path then
		return nil
	end

	local adapter
	local liblldb

	if vim.fn.has("mac") == 1 then
		adapter = install_path .. "/extension/adapter/codelldb"
		liblldb = install_path .. "/extension/lldb/lib/liblldb.dylib"
	elseif vim.fn.has("unix") == 1 then
		adapter = install_path .. "/extension/adapter/codelldb"
		liblldb = install_path .. "/extension/lldb/lib/liblldb.so"
	elseif vim.fn.has("win32") == 1 then
		adapter = install_path .. "/extension/adapter/codelldb.exe"
		liblldb = install_path .. "/extension/lldb/bin/liblldb.dll"
	end

	return adapter, liblldb
end

function M.get_codelldb_adapter()
	local adapter, liblldb = get_codelldb_paths()
	if not adapter then
		return nil
	end
	return {
		type = "server",
		port = "${port}",
		executable = {
			command = adapter,
			args = { "--port", "${port}" },
			detached = true,
		},
	}
end

function M.setup()
	local dap_status_ok, dap = pcall(require, "dap")
	if not dap_status_ok then
		vim.notify("nvim-dap not available", vim.log.levels.WARN)
		return
	end

	local adapter, liblldb = get_codelldb_paths()
	-- We don't need to warn here since mason-nvim-dap will handle this
	
	-- Setup enhanced debug configurations
	local rust_config = {
		{
			name = "Launch file",
			type = "codelldb",
			request = "launch",
			program = function()
				local cargo_toml = vim.fn.findfile("Cargo.toml", ".;")
				if cargo_toml ~= "" then
					local cargo_dir = vim.fn.fnamemodify(cargo_toml, ":p:h")
					local manifest = vim.fn.readfile(cargo_toml)
					local package_name = "debug"
					for _, line in ipairs(manifest) do
						local name = string.match(line, "^name%s*=%s*[\"'](.+)[\"']")
						if name then
							package_name = name
							break
						end
					end
					return vim.fn.input("Path to executable: ", cargo_dir .. "/target/debug/" .. package_name, "file")
				else
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			args = function()
				return vim.split(vim.fn.input("Arguments: ", ""), " ")
			end,
		},
	{
			name = "Debug executable",
			type = "codelldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
		},
		{
			name = "Debug unit tests",
			type = "codelldb",
			request = "launch",
			program = function()
				local cargo_cmd = string.format(
					"cargo test --no-run --message-format=json 2>/dev/null | jq -r 'select(.profile.test == true) | .filenames[]' | head -n1"
				)
				local handle = io.popen(cargo_cmd)
				if handle then
					local result = handle:read("*a")
					handle:close()
					if result and result ~= "" then
						return vim.trim(result)
					end
				end
				return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			args = function()
				return { "--nocapture" }
			end,
		},
		{
			name = "Attach to process",
			type = "codelldb",
			request = "attach",
			pid = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
		},
	}
	
	-- Apply the config
	dap.configurations.rust = rust_config

	local dapui_status_ok, dapui = pcall(require, "dapui")
	if dapui_status_ok then
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end

		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end

		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end
	end

	local virt_text_status_ok, virt_text = pcall(require, "nvim-dap-virtual-text")
	if virt_text_status_ok then
		virt_text.setup()
	end
end

return M