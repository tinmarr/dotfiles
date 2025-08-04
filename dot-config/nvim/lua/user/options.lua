-- Neovim options documented here: https://neovim.io/doc/user/quickref.html#option-list

-- tabbing
vim.opt.expandtab = true
vim.opt.shiftwidth = 0
vim.opt.tabstop = 4
vim.opt.smartindent = true

-- sidebar
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- behavior
vim.opt.linebreak = false
vim.opt.mouse = "a"
vim.opt.scrolloff = 5
vim.opt.autoread = true
vim.opt.smartcase = true
vim.opt.ignorecase = true

-- look
vim.opt.termguicolors = true
vim.opt.conceallevel = 2
vim.opt.wrap = false
vim.opt.colorcolumn = "80,120"
vim.opt.cursorline = true

-- folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99
vim.opt.foldlevel = 99

-- language
vim.g.is_posix = 1

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
