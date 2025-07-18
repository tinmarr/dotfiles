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

-- lsp
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "See symbol definition" })
vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, { desc = "See symbol implementation" })
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.references, { desc = "See symbol references" })
vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Execute code actions" })
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename a symbol" })
vim.keymap.set("n", "<leader>lk", vim.diagnostic.open_float, { desc = "Open floating diagnostics" })
vim.keymap.set("n", "<leader>lx", vim.diagnostic.setloclist, { desc = "Open buffer diagnostics" })
vim.keymap.set("n", "<leader>lX", vim.diagnostic.setqflist, { desc = "Open all diagnostics" })
vim.keymap.set("n", "<leader>lR", "<cmd>LspRestart<cr>", { desc = "Restart lsp" })


vim.keymap.set("i", "<C-h>", "<C-w>")

vim.keymap.set("n", "<leader>/", function()
    ---@diagnostic disable-next-line: undefined-field
    if vim.opt.hlsearch._value then
        vim.opt.hlsearch = false
    else
        vim.opt.hlsearch = true
    end
end, { desc = "Toggle search highlight" })
