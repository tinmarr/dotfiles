return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
        {
            "<leader>ls",
            "<cmd>Trouble symbols toggle focus=false<cr>",
            desc = "Symbols (Trouble)",
        },
        {
            "<leader>ll",
            "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
            desc = "LSP Definitions / references / ... (Trouble)",
        },
    },
    opts = {},
}
