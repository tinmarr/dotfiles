return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    keys = {
        { "<leader>e", "<cmd>Neotree<cr>", desc = "Open Neotree" },
    },
    opts = {
        close_if_last_window = true,
        window = {
            position = "right",
        },
        filesystem = {
            filtered_items = {
                visible = true
            },
            follow_current_file = {
                enabled = true
            },
        },
    },
}
