return {
    "sindrets/diffview.nvim",
    dependencies = { "echasnovski/mini.icons" },
    keys = {
        { "<leader>ah", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview file history" },
        { "<leader>ad", "<cmd>DiffviewOpen<cr>",        desc = "Diffview conflicts" }
    }
}
