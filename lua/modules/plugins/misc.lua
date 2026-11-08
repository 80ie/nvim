local misc = {}

misc["savq/melange-nvim"] = { lazy = false, priority = 1000 }
misc["zaldih/themery.nvim"] = {
	lazy = false,
	cmd = "Themery",
	config = require("misc.themery"),
}
misc["gbprod/substitute.nvim"] = {
	lazy = true,
	config = function()
		require("substitute").setup()
	end,
}
misc["y3owk1n/time-machine.nvim"] = {
	lazy = false,
	config = function()
		require("time-machine").setup({})
	end,
}
misc["TheLazyCat00/runner-nvim"] = {
	lazy = true,
	config = function()
		require("runner-nvim").setup({})
	end,
}
misc["doctorfree/cheatsheet.nvim"] = {
	lazy = true,
	cmd = { "Cheatsheet", "CheatsheetEdit" },
	dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/popup.nvim", "nvim-lua/plenary.nvim" },
	config = function()
		require("cheatsheet").setup({ bundled_cheatsheets = { disabled = { "nerd-fonts" } } })
	end,
}
misc["lervag/vimtex"] = {
	lazy = false,
	init = function()
		vim.g.vimtex_view_method = "zathura"
		vim.g.vimtex_view_general_viewer = "okular"
		vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
	end,
}
-- Only the image module is used (renders math in markdown/latex)
misc["folke/snacks.nvim"] = {
	lazy = false,
	priority = 900,
	opts = { image = { enabled = true } },
}

return misc
