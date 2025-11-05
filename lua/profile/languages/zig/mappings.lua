--added-by-agent: zig-setup 20251020
-- mason: none
-- dependencies: which-key.nvim

local M = {}

function M.setup()
	local ok_whichkey, whichkey = pcall(require, "which-key")
	if not ok_whichkey then
		vim.notify("which-key not available for Zig mappings", vim.log.levels.WARN)
		return
	end

	-- Register Zig-specific mappings
	whichkey.register({
		["<leader>z"] = {
			name = "Zig",
			b = { "<cmd>ZigBuild<cr>", "BuildProject" },
			r = { "<cmd>ZigRun<cr>", "Run Current File" },
			t = { "<cmd>ZigTest<cr>", "Run Tests" },
			f = { "<cmd>ZigFmt<cr>", "Format Buffer" },
			c = { "<cmd>ZigCheck<cr>", "Check Code" },
			h = { "<cmd>ZigDoc<cr>", "Generate Docs" },
			B = { "<cmd>ZigBench<cr>", "Run Benchmarks" },
			v = { "<cmd>ZigCoverage<cr>", "Coverage Report" },
			s = { "<cmd>ZigSanitize<cr>", "Sanitize Build" },
	},
		["<leader>s"] = {
			name = "Software Eng.",
			e = {
				name = "Zig",
				c = { "<cmd>ZigCoverage<cr>", "Coverage" },
				r = { "<cmd>ZigFmt<cr>", "Reformat" },
				t ={ "<cmd>ZigTest<cr>", "Test" },
				d = { "<cmd>ZigDoc<cr>", "Documentation" },
			},
		},
	})
end

return M
