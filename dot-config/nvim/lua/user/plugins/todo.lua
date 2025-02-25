return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    keys = {
        { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "List todos in telescope" }
    },
    opts = {}
}
