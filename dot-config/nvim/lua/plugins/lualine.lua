return {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    priority = 999, -- load right after catppuccin
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
            lualine_x = { "encoding", "fileformat", "lsp_status" },
            lualine_y = { "filetype" },
            lualine_z = { "location" }
        },
    }
}
