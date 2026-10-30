require('gitsigns').setup({
	on_attach = function(bufnr)
		local gs = require('gitsigns')
		local function map(keys, action, desc)
			vim.keymap.set('n', keys, action, { buffer = bufnr, desc = desc })
		end
		map(']c', function()
			if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gs.nav_hunk('next') end
		end, 'Next Git change')
		map('[c', function()
			if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gs.nav_hunk('prev') end
		end, 'Previous Git change')
		map('<leader>hp', gs.preview_hunk, 'Preview Git change')
		map('<leader>hs', gs.stage_hunk, 'Stage Git change')
		map('<leader>hr', gs.reset_hunk, 'Reset Git change')
	end,
})
