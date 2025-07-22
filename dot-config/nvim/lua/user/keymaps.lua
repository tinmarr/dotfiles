-- <leader>
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<leader>al", "<cmd>Lazy<cr>", { desc = "Open Lazy" })

-- auto center
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })
vim.keymap.set("n", "n", "nzz", { noremap = true })
vim.keymap.set("n", "N", "Nzz", { noremap = true })

-- clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", "\"+y", { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", "\"+p", { desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", "\"+d", { desc = "Delete to system clipboard" })

-- buffer stuff
vim.keymap.set("n", "<leader>bk", "<cmd>b#<cr>", { desc = "Goto last accessed buffer" })
vim.keymap.set("n", "<leader>bh", vim.cmd.bprevious, { desc = "Goto previous buffer" })
vim.keymap.set("n", "<leader>bl", vim.cmd.bnext, { desc = "Goto previous buffer" })
vim.keymap.set("n", "<leader>bd", vim.cmd.bdelete, { desc = "Delete buffer" })

-- window management
vim.keymap.set("n", "<M-S-l>", "5<C-w>>")
vim.keymap.set("n", "<M-S-h>", "5<C-w><")
vim.keymap.set("n", "<M-S-k>", "2<C-w>+")
vim.keymap.set("n", "<M-S-j>", "2<C-w>-")
vim.keymap.set("n", "<M-v>", "<C-w>v")
vim.keymap.set("n", "<M-s>", "<C-w>s")
vim.keymap.set("n", "<M-c>", "<C-w>c")
vim.keymap.set("n", "<M-o>", "<C-w>o")
vim.keymap.set("n", "<M-=>", "<C-w>=")

-- tabs
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close tab" })
vim.keymap.set("n", "<leader>tl", "<cmd>tabnext<cr>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>th", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader>tt", "<cmd>tabnew<cr>", { desc = "Add tab" })

vim.keymap.set("i", "<C-h>", "<C-w>")

vim.keymap.set("n", "<leader>/", function()
    ---@diagnostic disable-next-line: undefined-field
    if vim.opt.hlsearch._value then
        vim.opt.hlsearch = false
    else
        vim.opt.hlsearch = true
    end
end, { desc = "Toggle search highlight" })
