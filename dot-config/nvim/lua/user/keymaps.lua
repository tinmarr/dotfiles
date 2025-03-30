-- <leader>
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- vim.keymap.set(mode, keymap, action, options)
vim.keymap.set("n", "<leader>al", "<cmd>Lazy<cr>", { desc = "Open Lazy" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })

vim.keymap.set("n", "<leader>bk", "<cmd>b#<cr>", { desc = "Goto last accessed buffer" })
vim.keymap.set("n", "<leader>bh", vim.cmd.bprevious, { desc = "Goto previous buffer" })
vim.keymap.set("n", "<leader>bl", vim.cmd.bnext, { desc = "Goto previous buffer" })
vim.keymap.set("n", "<leader>bc", vim.cmd.bdelete, { desc = "Close buffer" })

vim.keymap.set("n", "<M-S-l>", "5<C-w>>")
vim.keymap.set("n", "<M-S-h>", "5<C-w><")
vim.keymap.set("n", "<M-S-k>", "2<C-w>+")
vim.keymap.set("n", "<M-S-j>", "2<C-w>-")
vim.keymap.set("n", "<M-v>", "<C-w>v")
vim.keymap.set("n", "<M-s>", "<C-w>s")
vim.keymap.set("n", "<M-c>", "<C-w>c")
vim.keymap.set("n", "<M-o>", "<C-w>o")
vim.keymap.set("n", "<M-=>", "<C-w>=")

vim.keymap.set("i", "<C-h>", "<C-w>")

vim.keymap.set("n", "<leader>/", function()
    vim.fn.setreg("/", vim.fn.rand())
end)
