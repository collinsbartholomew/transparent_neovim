local M = {}

function M.setup()
	local status_ok, autopairs = pcall(require, "nvim-autopairs")
	if not status_ok then
		return
	end

	autopairs.setup({
		check_ts = true,
		disable_filetype = { "TelescopePrompt", "spectre_panel", "toggleterm", "lazy", "mason" },
		fast_wrap = {
			map = "<M-e>",
			chars = { "{", "[", "(", '"', "'" },
			pattern = [=[[%'%"%)%]%}%,]]=],
			end_key = "$",
			keys = "qwertyuiopzxcvbnmasdfghjkl",
		},
	})

	-- Integrate with cmp if available
	local cmp_ok, cmp = pcall(require, "cmp")
	if cmp_ok then
		local cmp_autopairs_ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
		if cmp_autopairs_ok then
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end
	end
end

return M