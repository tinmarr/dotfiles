return {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    ---@module "catppuccin"
    ---@type CatppuccinOptions
    opts = {
        flavour = "mocha",
        integrations = {
            which_key = true
        }
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme "catppuccin"
    end
}
