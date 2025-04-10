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
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = { "filename" },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" }
        },
    }
}
