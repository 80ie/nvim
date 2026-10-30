call plug#begin()

" List your plugins here
Plug 'lervag/vimtex'
Plug 'folke/which-key.nvim'
Plug 'savq/melange-nvim'
Plug 'folke/snacks.nvim'
Plug 'MeanderingProgrammer/render-markdown.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'lewis6991/gitsigns.nvim'
call plug#end()

set scrolloff=3 sidescrolloff=2
set number relativenumber
set tabstop=3 shiftwidth=3 softtabstop=3

let g:markdown_folding = 1
set foldlevelstart=99

let mapleader = " "
let maplocalleader = ","

call v:lua.vim.keymap.set('n', '<leader>?', '<Cmd>WhichKey<CR>', {'desc': 'All keymaps'})

colorscheme melange

" VIMTEX
let g:vimtex_view_method = 'zathura'
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
