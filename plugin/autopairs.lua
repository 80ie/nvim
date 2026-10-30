local autopairs = require('nvim-autopairs')
autopairs.setup({ map_cr = false })

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.keymap.set('i', '<C-n>', function()
	return vim.fn.pumvisible() == 1 and '<Down>' or '<C-n>'
end, { expr = true })
vim.keymap.set('i', '<C-p>', function()
	return vim.fn.pumvisible() == 1 and '<Up>' or '<C-p>'
end, { expr = true })
vim.keymap.set('i', '<CR>', function()
	if vim.fn.pumvisible() == 1 then
		if vim.fn.complete_info({ 'selected' }).selected >= 0 then
			return vim.api.nvim_replace_termcodes('<C-y>', true, false, true)
		end
		return vim.api.nvim_replace_termcodes('<C-e>', true, false, true) .. autopairs.autopairs_cr()
	end
	return autopairs.autopairs_cr()
end, { expr = true, replace_keycodes = false })
