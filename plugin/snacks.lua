require('snacks').setup({
	picker = { enabled = true },
	notifier = { enabled = true },
	dashboard = {
		enabled = true,
		sections = {
			{ section = 'header' },
			{ section = 'keys', gap = 1, padding = 1 },
		},
	},
	explorer = { enabled = true },
	indent = { enabled = true },
	lazygit = { enabled = true },
	quickfile = { enabled = true },
	image = { enabled = true },
	scroll = { enabled = true },
	input = {enabled = true},
	statuscolumn = { enabled = true },
	animate = { enabled = true },
})

Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
Snacks.toggle.option('relativenumber', { name = 'Relative number' }):map('<leader>ur')
Snacks.toggle.diagnostics():map('<leader>ud')
Snacks.toggle.indent():map('<leader>ug')
