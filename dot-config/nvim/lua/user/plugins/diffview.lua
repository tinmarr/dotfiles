return {
    "sindrets/diffview.nvim",
    dependencies = { "echasnovski/mini.icons" },
    keys = {
        { "<leader>vh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview file history" },
        { "<leader>vm", "<cmd>DiffviewOpen<cr>",        desc = "Diffview current index" }
    }
}
