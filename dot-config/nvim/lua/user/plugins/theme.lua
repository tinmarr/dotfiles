return {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    ---@module "catppuccin"
    ---@type CatppuccinOptions
    opts = {
        flavour = "mocha",
        transparent_background = true,
        float = {
            transparent = true,
            solid = true,
        },
        integrations = {
            which_key = true,
            render_markdown = true,
        }
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme "catppuccin"
    end
}
