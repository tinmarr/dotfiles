-- Packer setup
vim.cmd [[packadd packer.nvim]]

require("packer").startup(function(use)
    use "wbthomason/packer.nvim"
    use "dracula/vim"
    use "xiyaowong/nvim-transparent"
    use "lambdalisue/suda.vim"
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
vim.opt.signcolumn = "yes"

vim.opt.smartindent = true

vim.opt.wrap = false

vim.g.transparent_enabled = true

vim.g.suda_smart_edit = 1

vim.cmd("colorscheme dracula")
