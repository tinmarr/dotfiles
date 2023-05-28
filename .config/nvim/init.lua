-- Packer setup
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'Mofiqul/dracula.nvim'
    use 'xiyaowong/transparent.nvim'
    use 'lambdalisue/suda.vim'
    use {
      'nvim-telescope/telescope.nvim', tag = '0.1.x',
      requires = { {'nvim-lua/plenary.nvim'} }
    }
    use {
        'romgrk/barbar.nvim',
        requires = { {'nvim-tree/nvim-web-devicons', 'lewis6991/gitsigns.nvim'} }
    }
end)

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.updatetime = 300
vim.opt.signcolumn = 'yes'

vim.opt.smartindent = true

vim.opt.wrap = true

vim.g.suda_smart_edit = 1

vim.cmd('colorscheme dracula')

---- Custom Keymaps ----
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map('n', '<C-d>', '<C-d>zz', opts)
map('n', '<C-u>', '<C-u>zz', opts)
map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)
map('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)
map('n', '<C-e>', '<Cmd>Ex<CR>', opts)

local telescope = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', telescope.find_files, opts)

