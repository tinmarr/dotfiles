-- <leader>
vim.g.mapleader = " "

-- vim.keymap.set(mode, keymap, action, options)

vim.keymap.set("n", "<leader>r", vim.cmd.Ex, { desc = "Open netrw" })

vim.keymap.set("n", "<leader>al", "<cmd>Lazy<cr>", { desc = "Open Lazy" })
vim.keymap.set("n", "<leader>am", "<cmd>Mason<cr>", { desc = "Open Mason" })

vim.keymap.set("n", "<leader>bk", "<cmd>b#<cr>", { desc = "Goto last accessed buffer" })
vim.keymap.set("n", "<leader>bh", vim.cmd.bprevious, { desc = "Goto previous buffer" })
vim.keymap.set("n", "<leader>bl", vim.cmd.bnext, { desc = "Goto previous buffer" })
vim.keymap.set("n", "<leader>bc", vim.cmd.bdelete, { desc = "Close buffer" })
