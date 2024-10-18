-- <leader>
vim.g.mapleader = " "

-- vim.keymap.set(mode, keymap, action, options)

vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })

vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
