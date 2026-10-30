vim.opt.wildmenu = true
vim.opt.wildmode = 'noselect:lastused,full'
vim.opt.wildoptions:append('pum')

if vim.fn.exists('*wildtrigger') == 1 then
	vim.api.nvim_create_autocmd('CmdlineChanged', {
		group = vim.api.nvim_create_augroup('CmdlineCompletion', { clear = true }),
		pattern = ':',
		callback = function() vim.fn.wildtrigger() end,
	})
end
