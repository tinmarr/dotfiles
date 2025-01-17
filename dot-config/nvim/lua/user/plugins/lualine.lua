return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    opts = {
        options = {
            theme = "catppuccin",
            component_separators = "",
            section_separators = { left = '', right = '' }
        }
    },
}
