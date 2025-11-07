-- added-by-agent: web-setup 20251020-173000
-- mason: prettier, eslint
-- manual: node.js, pnpm installation required

local M = {}

function M.setup()
    if vim.fn.executable("npm") == 0 and vim.fn.executable("yarn") == 0 and vim.fn.executable("pnpm") == 0 then
        vim.notify("No package manager found. Install npm, yarn, or pnpm.", vim.log.levels.WARN)
        return
    end
    
	-- NpmInstall command
	vim.api.nvim_create_user_command("NpmInstall", function()
		vim.cmd("belowright new | terminal npm install")
	end, {})

	-- YarnInstall command
	vim.api.nvim_create_user_command("YarnInstall", function()
		vim.cmd("belowright new | terminal yarn install")
	end, {})

	-- PnpmInstall command
	vim.api.nvim_create_user_command("PnpmInstall", function()
		vim.cmd("belowright new | terminal pnpm install")
	end, {})

	-- StartDev command
	vim.api.nvim_create_user_command("StartDev", function()
		vim.cmd("belowright new | terminal npm run dev")
	end, {})

	-- StartDevYarn command
	vim.api.nvim_create_user_command("StartDevYarn", function()
		vim.cmd("belowright new | terminal yarn dev")
	end, {})

	-- StartDevPnpm command
	vim.api.nvim_create_user_command("StartDevPnpm", function()
		vim.cmd("belowright new | terminal pnpm run dev")
	end, {})

	-- Build command
	vim.api.nvim_create_user_command("WebBuild", function()
		vim.cmd("belowright new | terminal npm run build")
	end, {})

	-- Test command
	vim.api.nvim_create_user_command("WebTest", function()
		vim.cmd("belowright new | terminal npm test")
	end, {})

	-- Format command
	vim.api.nvim_create_user_command("WebFormat", function()
		vim.lsp.buf.format()
	end, {})

	-- We're removing null-ls configuration as it's deprecated
	-- Formatting is now handled by conform.nvim which is already configured
	-- Diagnostics are handled by LSP servers and nvim-lint

	-- Emmet setup (only if emmet-vim is installed)
	vim.g.user_emmet_mode = "n"
	vim.g.user_emmet_install_global = 0
	vim.api.nvim_create_autocmd("FileType", {
		pattern = {"html", "css", "scss", "sass", "less", "vue", "svelte", "astro", "mdx"},
		callback = function()
			pcall(vim.cmd, "call emmet#install()")
		end
	})

	-- Add custom functions for web development
	_G.web_utils = {
		-- Run npm script
		run_npm_script = function()
			local script = vim.fn.input("npm run: ")
			if script ~= "" then
				vim.cmd("belowright new | terminal npm run " .. script)
			end
		end,

		-- Run yarn script
		run_yarn_script = function()
			local script = vim.fn.input("yarn: ")
			if script ~= "" then
				vim.cmd("belowright new | terminal yarn " .. script)
			end
		end,

		-- Run pnpm script
		run_pnpm_script = function()
			local script = vim.fn.input("pnpm: ")
			if script ~= "" then
				vim.cmd("belowright new | terminal pnpm " .. script)
			end
		end,

		-- Create React component
		create_react_component = function()
			local name = vim.fn.input("Component name: ")
			if name == "" then
				return
			end

			local content = {
				"import React from 'react';",
				"",
				"interface " .. name .. "Props {",
				"  // Define your props here",
				"}",
				"",
				"const " .. name .. ": React.FC<" .. name .. "Props> = ({}) => {",
				"  return (",
				"    <div>",
				"      " .. name .. " component",
				"    </div>",
				"  );",
				"};",
				"",
				"export default " .. name .. ";",
			}

			-- Create new buffer with component content
			local buf = vim.api.nvim_create_buf(true, false)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
			vim.api.nvim_buf_set_name(buf, name .. ".tsx")
			vim.api.nvim_set_current_buf(buf)
		end,

		-- Create Express route
		create_express_route = function()
			local name = vim.fn.input("Route name: ")
			if name == "" then
				return
			end

			local content = {
				"import { Router } from 'express';",
				"const router = Router();",
				"",
				"// GET " .. name .. " route",
				"router.get('/" .. name .. "', (req, res) => {",
				"  res.json({ message: 'GET " .. name .. " route' });",
				"});",
				"",
				"// POST " .. name .. " route",
				"router.post('/" .. name .. "', (req, res) => {",
				"  res.json({ message: 'POST " .. name .. " route' });",
				"});",
				"",
				"export default router;",
			}

			-- Create new buffer with route content
			local buf = vim.api.nvim_create_buf(true, false)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
			vim.api.nvim_buf_set_name(buf, name .. "Route.ts")
			vim.api.nvim_set_current_buf(buf)
		end,
	}
end

return M
