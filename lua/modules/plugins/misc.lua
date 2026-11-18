local misc = {}

misc["morhetz/gruvbox"] = { lazy = false, priority = 1000 }
misc["savq/melange-nvim"] = { lazy = false, priority = 1000 }
misc["ramojus/mellifluous.nvim"] = { lazy = false, priority = 1000, neutral = false }
misc["ptdewey/darkearth-nvim"] = { lazy = false, priority = 1000 }
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
misc["lervag/vimtex"] = {
	lazy = false,
	init = function()
		vim.g.vimtex_view_method = "general"
		vim.g.vimtex_view_general_viewer = "okular"
		vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
	end,
}
-- Only image (math in markdown/latex) and the dashboard are used
misc["folke/snacks.nvim"] = {
	lazy = false,
	priority = 1000,
	init = function()
		vim.api.nvim_create_autocmd("ModeChanged", {
			callback = function(ev)
				Snacks.image.config.math.enabled = vim.fn.mode():sub(1, 1) == "n"
				pcall(vim.api.nvim_exec_autocmds, "BufWritePost", {
					group = "snacks.image.inline." .. ev.buf,
					modeline = false,
				})
			end,
		})
	end,
	opts = {
		image = { enabled = true },
		dashboard = {
			enabled = true,
			sections = {
				require("misc.splash"),
				{ section = "keys", gap = 1, padding = 1 },
			},
		},
	},
}

return misc
