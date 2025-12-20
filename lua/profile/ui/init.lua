local modules = {
	"theme",
	"whichkey",
	"statusline",
	"popups",
	"telescope",
	"neotree",
	"indent",
	"aerial",
	"enhancements",
}

for _, m in ipairs(modules) do
	pcall(require, "profile.ui." .. m)
end

return true
