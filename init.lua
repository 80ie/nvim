-- PLUGINS {{{1
local Plug = vim.fn['plug#']
vim.call('plug#begin')
Plug('lervag/vimtex')
Plug('folke/which-key.nvim')
Plug('savq/melange-nvim')
Plug('folke/snacks.nvim')
Plug('MeanderingProgrammer/render-markdown.nvim')
Plug('windwp/nvim-autopairs')
Plug('lewis6991/gitsigns.nvim')
Plug('gbprod/substitute.nvim')
Plug('y3owk1n/time-machine.nvim')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-lua/popup.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('doctorfree/cheatsheet.nvim')
Plug('TheLazyCat00/runner-nvim')
vim.call('plug#end')

-- OPTIONS {{{1
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

local o = vim.opt
o.smoothscroll = true
o.undofile = true
o.scrolloff = 3
o.sidescrolloff = 2
o.number = true
o.relativenumber = true
o.tabstop = 3
o.shiftwidth = 3
o.softtabstop = 3
o.foldlevelstart = 99

vim.g.markdown_folding = 1
vim.cmd.colorscheme('melange')

-- VIMTEX {{{1
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_view_general_viewer = 'okular'
vim.g.vimtex_view_general_options = '--unique file:@pdf\\#src:@line@tex'

-- KEYMAPS {{{1 (global ones; buffer-local ones stay in gitsigns.lua / lsp.lua)
-- Plugins are only require()d inside functions, so these are safe to define
-- before the plugins are set up.
local map = vim.keymap.set

-- windows {{{2
map('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Go to lower window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Go to upper window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })
map({ 'i', 'c' }, '<C-BS>', '<C-w>', { desc = 'Delete previous word' })

-- completion menu + autopairs <CR> {{{2
map('i', '<C-n>', function()
	return vim.fn.pumvisible() == 1 and '<Down>' or '<C-n>'
end, { expr = true })
map('i', '<C-p>', function()
	return vim.fn.pumvisible() == 1 and '<Up>' or '<C-p>'
end, { expr = true })
map('i', '<CR>', function()
	local autopairs = require('nvim-autopairs')
	if vim.fn.pumvisible() == 1 then
		if vim.fn.complete_info({ 'selected' }).selected >= 0 then
			return vim.api.nvim_replace_termcodes('<C-y>', true, false, true)
		end
		return vim.api.nvim_replace_termcodes('<C-e>', true, false, true) .. autopairs.autopairs_cr()
	end
	return autopairs.autopairs_cr()
end, { expr = true, replace_keycodes = false })

-- help {{{2
map('n', '<leader>/', '<Cmd>Cheatsheet<CR>', { desc = 'Cheatsheet' })
map('n', '<leader>?', '<Cmd>WhichKey<CR>', { desc = 'All keymaps' })
map('n', '<leader>fC', '<Cmd>CheatsheetEdit<CR>', { desc = 'Edit cheatsheet' })

-- snacks {{{2
map('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'LazyGit' })
map('n', '<leader>e', function() Snacks.explorer() end, { desc = 'Explorer' })
map('n', '<leader>E', function() Snacks.explorer({ cwd = vim.fn.expand('%:p:h') }) end, { desc = 'Explorer (file dir)' })
map('n', '<leader><space>', function() Snacks.picker.smart() end, { desc = 'Smart find' })
map('n', '<leader>ff', function() Snacks.picker.files() end, { desc = 'Files' })
map('n', '<leader>fg', function() Snacks.picker.grep() end, { desc = 'Grep' })
map('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = 'Buffers' })
map('n', '<leader>fn', function() Snacks.notifier.show_history() end, { desc = 'Notification history' })

-- substitute {{{2
map('n', 's', function() require('substitute').operator() end, { desc = 'Substitute with motion' })
map('n', 'ss', function() require('substitute').line() end, { desc = 'Substitute line' })
map('n', 'S', function() require('substitute').eol() end, { desc = 'Substitute to end of line' })
map('x', 's', function() require('substitute').visual() end, { desc = 'Substitute selection' })
map('n', 'sx', function() require('substitute.exchange').operator() end, { desc = 'Exchange with motion' })
map('n', 'sxx', function() require('substitute.exchange').line() end, { desc = 'Exchange line' })
map('x', 'X', function() require('substitute.exchange').visual() end, { desc = 'Exchange selection' })
map('n', 'sxc', function() require('substitute.exchange').cancel() end, { desc = 'Cancel exchange' })

-- time machine {{{2
map('n', '<leader>tt', '<Cmd>TimeMachineToggle<CR>', { desc = 'Toggle undo tree' })
map('n', '<leader>tx', '<Cmd>TimeMachinePurgeBuffer<CR>', { desc = 'Purge undo history (buffer)' })
map('n', '<leader>tX', '<Cmd>TimeMachinePurgeAll<CR>', { desc = 'Purge undo history (all)' })
map('n', '<leader>tl', '<Cmd>TimeMachineLogShow<CR>', { desc = 'Show log' })

-- runner {{{2
map('n', '<leader>r', function() require('runner-nvim').runLast() end, { desc = 'Run last cmd' })
map('n', '<leader>o', function() require('runner-nvim').run() end, { desc = 'Run cmd' })
map('n', '<leader>T', function() require('runner-nvim').toggle() end, { desc = 'Toggle runner terminal' })

-- vim: foldmethod=marker foldlevel=0
