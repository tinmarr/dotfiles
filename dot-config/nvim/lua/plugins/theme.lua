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
        },
        custom_highlights = function(colors)
            return {
                CatppucinRosewater = { fg = colors.rosewater },
                CatppucinFlamingo = { fg = colors.flamingo },
                CatppucinPink = { fg = colors.pink },
                CatppucinMauve = { fg = colors.mauve },
                CatppucinRed = { fg = colors.red },
                CatppucinMaroon = { fg = colors.maroon },
                CatppucinPeach = { fg = colors.peach },
                CatppucinYellow = { fg = colors.yellow },
                CatppucinGreen = { fg = colors.green },
                CatppucinTeal = { fg = colors.teal },
                CatppucinSky = { fg = colors.sky },
                CatppucinSapphire = { fg = colors.sapphire },
                CatppucinBlue = { fg = colors.blue },
                CatppucinLavender = { fg = colors.lavender },
                CatppucinMantle = { bg = colors.mantle },
                CatppucinCrust = { bg = colors.crust },
            }
        end,
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme "catppuccin"
    end
}
