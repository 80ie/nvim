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
})

local map = vim.keymap.set
map('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'LazyGit' })
map('n', '<leader>e', function() Snacks.explorer() end, { desc = 'Explorer' })
map('n', '<leader>E', function() Snacks.explorer({ cwd = vim.fn.expand('%:p:h') }) end, { desc = 'Explorer (file dir)' })
map('n', '<leader><space>', function() Snacks.picker.smart() end, { desc = 'Smart find' })
map('n', '<leader>ff', function() Snacks.picker.files() end, { desc = 'Files' })
map('n', '<leader>fg', function() Snacks.picker.grep() end, { desc = 'Grep' })
map('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = 'Buffers' })
map('n', '<leader>fn', function() Snacks.notifier.show_history() end, { desc = 'Notification history' })

Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
Snacks.toggle.option('relativenumber', { name = 'Relative number' }):map('<leader>ur')
Snacks.toggle.diagnostics():map('<leader>ud')
Snacks.toggle.indent():map('<leader>ug')
