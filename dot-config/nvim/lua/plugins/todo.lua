return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    keys = {
        { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "List todos in telescope" }
    },
    cmd = "TodoTelescope",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        search = {
            args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--glob=!node_modules/*",
                "--glob=!*vendor*",
                "--glob=!.venv/*",
                "--glob=!.git/*",
                "--glob=!build/*",
                "--glob=!dist/*",
                "--glob=!target/*",
                "--glob=!ThirdParty/*",
                "--glob=!Generated/*",
                "--glob=!*/generated/*",
                "--glob=!*.pb.*",
            },
        },
    }
}
