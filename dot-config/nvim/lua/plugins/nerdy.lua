return {
    "2kabhishek/nerdy.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    cmd = "Nerdy",
    keys = {
        { "<leader>fi", "<cmd>Telescope nerdy<cr>", desc = "Open nerd font picker" }
    },
    config = function()
        require("telescope").load_extension("nerdy")
    end
}
