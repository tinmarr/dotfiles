return {
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        lazy = true,
        ft = "markdown",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
            "nvim-telescope/telescope.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        keys = {
            { "<leader>of", "<cmd>ObsidianQuickSwitch<cr>", desc = "ObsidianQuickSwitch" },
            { "<leader>og", "<cmd>ObsidianSearch<cr>",      desc = "ObsidianSearch" },
            { "<leader>oo", "<cmd>ObsidianOpen<cr>",        desc = "Open obsidian" },
            { "<leader>op", "<cmd>ObsidianPasteImg<cr>",    desc = "Paste image" },
            { "<leader>ox", "<cmd>ObsidianFollowLink<cr>",  desc = "Follow link" },
        },
        opts = {
            workspaces = {
                {
                    name = "notes",
                    path = "~/notes"
                }
            },
            completion = {
                min_chars = 1
            },
            mappings = {},
            disable_frontmatter = true,
            ui = {
                enable = false,
            },
        }
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },       -- if you use the mini.nvim suite
        -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you use standalone mini plugins
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
        ft = "markdown",
        ---@module "render-markdown"
        ---@type render.md.UserConfig
        opts = {
            render_modes = true,
        },
    }
}
