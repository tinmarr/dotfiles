-- Vim options documented here: https://neovim.io/doc/user/quickref.html#option-list
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 0
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

vim.api.nvim_create_augroup('bufcheck', { clear = true })

-- highlight yanks
vim.api.nvim_create_autocmd('TextYankPost', {
    group    = 'bufcheck',
    pattern  = '*',
    callback = function() vim.highlight.on_yank { timeout = 500 } end
})

-- remove trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
    group = "bufcheck",
    pattern = "*",
    callback = function() vim.cmd("%s/\\s\\+$//e") end
})
