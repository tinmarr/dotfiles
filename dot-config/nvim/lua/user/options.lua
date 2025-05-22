-- Vim options documented here: https://neovim.io/doc/user/quickref.html#option-list
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.linebreak = false
vim.opt.wrap = false

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

vim.opt.termguicolors = true
vim.opt.conceallevel = 2

vim.opt.colorcolumn = "80,120"

vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
vim.lsp.set_log_level("OFF")

vim.api.nvim_create_user_command("W", "write", { nargs = "*", range = true, bang = true, complete = "file" })

vim.api.nvim_create_augroup("onstart", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
    group = "onstart",
    callback = function()
        if require("lazy.status").has_updates then
            require("lazy").update({ show = false, })
        end
    end
})


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
    callback = function()
        vim.cmd("exe 'normal ms'")
        vim.cmd("%s/\\s\\+$//ge")
        vim.cmd("exe 'normal `s'")
    end
})

-- correctly highlight .envrc files
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*.envrc",
    callback = function()
        vim.cmd("set filetype=bash")
    end
})
