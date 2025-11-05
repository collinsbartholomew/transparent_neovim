-- Linting configuration
local M = {}

function M.setup()
	local lint_ok, lint = pcall(require, "lint")
	if not lint_ok then
		vim.notify("nvim-lint not available", vim.log.levels.WARN)
		return
	end

	lint.linters_by_ft = {
		lua = { "luacheck" },
		python = { "ruff" },
		java = { "checkstyle" },
		javascript = { "eslint_d" },
		typescript = { "eslint_d" },
		html = { "htmlhint" },
		css = { "stylelint" },
		scss = { "stylelint" },
		asm = { "nasm" },
		nasm = { "nasm" },
		gas = { "gas" },
		cpp = { "clang-tidy", "cppcheck" },
		c = { "clang-tidy", "cppcheck" },
		qml = { "qmllint" },
		rust = { "clippy" },
		go = { "golangcilint" },
		cs = { "dotnet_build" },
		php = { "phpstan" },
		zig = {}, -- Zig uses zls for diagnostics and zig fmt for formatting, no separate linter
	}

	lint.linters.nasm = {
		cmd = "nasm",
		args = { "-X", "gnu", "-f", "elf64", "-o", "/dev/null", "-" },
		stdin = true,
		stream = "stderr",
		parser = function(output, bufnr)
			local diagnostics = {}
			for _, line in ipairs(vim.split(output, "\n")) do
				local parts = vim.split(line, ":")
				if #parts >= 3 then
					local ln = tonumber(parts[2])
					if ln then
						table.insert(diagnostics, {
							bufnr = bufnr,
							lnum = ln - 1,
							col = 0,
							severity = vim.diagnostic.severity.ERROR,
							message = table.concat({ unpack(parts, 3) }, ":"),
							source = "nasm",
						})
					end
				end
			end
			return diagnostics
		end,
	}

	lint.linters.gas = {
		cmd = "as",
		args = { "--fatal-warnings", "-o", "/dev/null", "-" },
		stdin = true,
		stream = "stderr",
		parser = function(output, bufnr)
			local diagnostics = {}
			for _, line in ipairs(vim.split(output, "\n")) do
				local pattern = "stdin:(%d+):(.*)"
				local ln, msg = string.match(line, pattern)
				if ln and msg then
					table.insert(diagnostics, {
						bufnr = bufnr,
						lnum = tonumber(ln) - 1,
						col = 0,
						severity = vim.diagnostic.severity.ERROR,
						message = msg,
						source = "gas",
					})
				end
			end
			return diagnostics
		end,
	}

	lint.linters["clang-tidy"] = {
		cmd = "clang-tidy",
		args = { "--quiet", "-" },
		stdin = true,
		stream = "stderr",
		parser = function(output, bufnr)
			local diagnostics = {}
			for _, line in ipairs(vim.split(output, "\n")) do
				local pattern = "stdin:(%d+):(%d+): (%a+): (.+)"
				local ln, col, severity, msg = string.match(line, pattern)
				if ln and col and severity and msg then
					local severity_level = vim.diagnostic.severity.WARN
					if severity == "error" then
						severity_level = vim.diagnostic.severity.ERROR
					end

					table.insert(diagnostics, {
						bufnr = bufnr,
						lnum = tonumber(ln) - 1,
						col = tonumber(col) - 1,
						severity = severity_level,
						message = msg,
						source = "clang-tidy",
					})
				end
			end
			return diagnostics
		end,
	}

	lint.linters.cppcheck = {
		cmd = "cppcheck",
		args = { "--enable=all", "--inconclusive", "--xml", "--xml-version=2", "--suppress=unmatchedSuppression:*", "-" },
		stdin = true,
		stream = "stderr",
		parser = function(output, bufnr)
			local diagnostics = {}
			for _, line in ipairs(vim.split(output, "\n")) do
				local pattern = '<%a+ filename="stdin" line="(%d+)" id="[^"]+" severity="(%a+)" msg="([^"]+)"'
				local ln, severity, msg = string.match(line, pattern)
				if ln and severity and msg then
					local severity_level = vim.diagnostic.severity.WARN
					if severity == "error" then
						severity_level = vim.diagnostic.severity.ERROR
					end

					table.insert(diagnostics, {
						bufnr = bufnr,
						lnum = tonumber(ln) - 1,
						col = 0,
						severity = severity_level,
						message = msg,
						source = "cppcheck",
					})
				end
			end
			return diagnostics
		end,
	}

	lint.linters.qmllint = {
		cmd = "qmllint",
		args = { "-" },
		stdin = true,
		stream = "stderr",
		parser = function(output, bufnr)
			local diagnostics = {}
			for _, line in ipairs(vim.split(output, "\n")) do
				local pattern = "stdin:(%d+):(%d+): (.+)"
				local ln, col, msg = string.match(line, pattern)
				if ln and col and msg then
					table.insert(diagnostics, {
						bufnr = bufnr,
						lnum = tonumber(ln) - 1,
						col = tonumber(col) - 1,
						severity = vim.diagnostic.severity.ERROR,
						message = msg,
						source = "qmllint",
					})
				end
			end
			return diagnostics
		end,
	}

	lint.linters.clippy = {
		cmd = "cargo",
		args = { "clippy", "--message-format=json" },
		stdin = false,
		stream = "stdout",
		parser = function(output, bufnr)
			local diagnostics = {}
			for _, line in ipairs(vim.split(output, "\n")) do
				if line ~= "" then
					local ok, parsed = pcall(vim.json.decode, line)
					if ok and parsed.reason == "compiler-message" then
						local message = parsed.message
						local spans = message.spans
						if spans and #spans > 0 then
							local span = spans[1]
							local severity = vim.diagnostic.severity.HINT
							if message.level == "warning" then
								severity = vim.diagnostic.severity.WARN
							elseif message.level == "error" or message.level == "hard_error" then
								severity = vim.diagnostic.severity.ERROR
							end

							table.insert(diagnostics, {
								bufnr = bufnr,
								lnum = span.line_start - 1,
								col = span.column_start - 1,
								end_lnum = span.line_end - 1,
								end_col = span.column_end - 1,
								severity = severity,
								message = message.message,
								source = "clippy",
							})
						end
					end
				end
			end
			return diagnostics
		end,
	}



	lint.linters.golangcilint = {
		cmd = "golangci-lint",
		args = { "run", "--out-format", "checkstyle" },
		stdin = false,
		stream = "stdout",
		parser = function(output, bufnr)
			local diagnostics = {}
			for line in vim.gsplit(output, "\n") do
				local file, ln, col, severity, msg =
					string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
				if ln and col and severity and msg then
					local severity_level = vim.diagnostic.severity.WARN
					if severity == "error" then
						severity_level = vim.diagnostic.severity.ERROR
					end

					table.insert(diagnostics, {
						bufnr = bufnr,
						lnum = tonumber(ln) - 1,
						col = tonumber(col) - 1,
						severity = severity_level,
						message = msg,
						source = "golangci-lint",
					})
				end
			end
			return diagnostics
		end,
	}

	lint.linters.dotnet_build = {
		cmd = "dotnet",
		args = { "build", "--no-restore", "--no-dependencies" },
		stdin = false,
		stream = "stderr",
		parser = function(output, bufnr)
			local diagnostics = {}
			for _, line in ipairs(vim.split(output, "\n")) do
				local pattern = "([^:]+):(%a+)%s+([^:]+):%s+(.+)%s+%[(.+)%]"
				local file, severity, code, msg, project = string.match(line, pattern)

				if file and severity and code and msg then
					local line_col_pattern = "(.+)%((%d+),(%d+)%)"
					local path, ln, col = string.match(file, line_col_pattern)

					if path and ln and col then
						local severity_level = vim.diagnostic.severity.WARN
						if severity:lower() == "error" then
							severity_level = vim.diagnostic.severity.ERROR
						end

						table.insert(diagnostics, {
							bufnr = bufnr,
							lnum = tonumber(ln) - 1,
							col = tonumber(col) - 1,
							severity = severity_level,
							message = "[" .. code .. "] " .. msg,
							source = "dotnet-build",
						})
					end
				end
			end
			return diagnostics
		end,
	}

	lint.linters.checkstyle = {
		cmd = "checkstyle",
		args = { "-f", "checkstyle", "-" },
		stdin = true,
		stream = "stdout",
		parser = function(output, bufnr)
			local diagnostics = {}
			for line in vim.gsplit(output, "\n") do
				local file, ln, col, severity, msg =
					string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
				if ln and col and severity and msg then
					local severity_level = vim.diagnostic.severity.WARN
					if severity == "error" then
						severity_level = vim.diagnostic.severity.ERROR
					end

					table.insert(diagnostics, {
						bufnr = bufnr,
						lnum = tonumber(ln) - 1,
						col = tonumber(col) - 1,
						severity = severity_level,
						message = msg,
						source = "checkstyle",
					})
				end
			end
			return diagnostics
		end,
	}

	lint.linters.ruff = {
		cmd = "ruff",
		args = { "check", "--output-format", "checkstyle", "-" },
		stdin = true,
		stream = "stdout",
		parser = function(output, bufnr)
			local diagnostics = {}
			for line in vim.gsplit(output, "\n") do
				local file, ln, col, severity, msg =
					string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
				if ln and col and severity and msg then
					local severity_level = vim.diagnostic.severity.WARN
					if severity == "error" then
						severity_level = vim.diagnostic.severity.ERROR
					end

					table.insert(diagnostics, {
						bufnr = bufnr,
						lnum = tonumber(ln) - 1,
						col = tonumber(col) - 1,
						severity = severity_level,
						message = msg,
						source = "ruff",
					})
				end
			end
			return diagnostics
		end,
	}

	lint.linters.luacheck = {
		cmd = "luacheck",
		args = function()
			return { "--formatter", "checkstyle", "--codes", "--ranges", "--filename", vim.api.nvim_buf_get_name(0), "-" }
		end,
		stdin = true,
		stream = "stdout",
		parser = function(output, bufnr)
			local diagnostics = {}
			for line in vim.gsplit(output, "\n") do
				local file, ln, col, severity, msg =
					string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
				if ln and col and severity and msg then
					local severity_level = vim.diagnostic.severity.WARN
					if severity == "error" then
						severity_level = vim.diagnostic.severity.ERROR
					end

					table.insert(diagnostics, {
						bufnr = bufnr,
						lnum = tonumber(ln) - 1,
						col = tonumber(col) - 1,
						severity = severity_level,
						message = msg,
						source = "luacheck",
					})
				end
			end
			return diagnostics
		end,
	}

	lint.linters.eslint_d = {
		cmd = "eslint_d",
		args = function()
			return { "--format", "checkstyle", "--stdin", "--stdin-filename", vim.api.nvim_buf_get_name(0) }
		end,
		stdin = true,
		stream = "stdout",
		parser = function(output, bufnr)
			local diagnostics = {}
			for line in vim.gsplit(output, "\n") do
				local file, ln, col, severity, msg =
					string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
				if ln and col and severity and msg then
					local severity_level = vim.diagnostic.severity.WARN
					if severity == "error" then
						severity_level = vim.diagnostic.severity.ERROR
					end

					table.insert(diagnostics, {
						bufnr = bufnr,
						lnum = tonumber(ln) - 1,
						col = tonumber(col) - 1,
						severity = severity_level,
						message = msg,
						source = "eslint_d",
					})
				end
			end
			return diagnostics
		end,
	}

	lint.linters.phpstan = {
		cmd = "phpstan",
		args = { "analyze", "--error-format=checkstyle", "--no-progress", "-" },
		stdin = true,
		stream = "stdout",
		parser = function(output, bufnr)
			local diagnostics = {}
			for line in vim.gsplit(output, "\n") do
				local file, ln, col, severity, msg =
					string.match(line, '<error line="(%d+)" column="(%d+)" severity="(%a+)" message="([^"]+)"')
				if ln and col and severity and msg then
					local severity_level = vim.diagnostic.severity.WARN
					if severity == "error" then
						severity_level = vim.diagnostic.severity.ERROR
					end

					table.insert(diagnostics, {
						bufnr = bufnr,
						lnum = tonumber(ln) - 1,
						col = tonumber(col) - 1,
						severity = severity_level,
						message = msg,
						source = "phpstan",
					})
				end
			end
			return diagnostics
		end,
	}

	-- Only lint on save, not on every buffer enter
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		callback = function()
			pcall(lint.try_lint)
		end,
	})
end

return M