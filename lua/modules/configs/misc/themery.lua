return function()
	-- every user-installed colorscheme, so new ones show up without editing a list
	local themes = {}
	for _, glob in ipairs({ "colors/*.vim", "colors/*.lua" }) do
		for _, f in ipairs(vim.api.nvim_get_runtime_file(glob, true)) do
			if not vim.startswith(f, vim.env.VIMRUNTIME) then
				themes[#themes + 1] = vim.fn.fnamemodify(f, ":t:r")
			end
		end
	end
	-- the default goes first: themery falls back to the first entry when nothing is saved yet
	local default = require("core.settings").colorscheme
	table.sort(themes, function(a, b)
		if a == default or b == default then
			return a == default
		end
		return a < b
	end)
	require("themery").setup({ themes = themes, livePreview = true })
end
