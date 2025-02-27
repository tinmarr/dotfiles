return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "catppuccin/nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        options = {
            theme = "catppuccin",
            component_separators = "",
            section_separators = { left = '', right = '' },
            disabled_filetypes = {
                statusline = {
                    "snacks_dashboard"
                }
            }
        }
    }
}
