require('which-key').setup({
	preset = 'helix',
})

require('which-key').add({
	{ '<leader>g', group = 'git' },
	{ '<leader>f', group = 'find' },
	{ '<leader>u', group = 'ui toggles' },
	{ '<leader>c', group = 'code' },
	{ '<leader>h', group = 'git hunks' },
	{ '<leader>t', group = 'time machine' },
	{ '<leader>b', group = 'buffers' },
})
