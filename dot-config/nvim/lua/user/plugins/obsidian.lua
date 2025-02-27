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
        dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
        ft = "markdown",
        ---@module "render-markdown"
        ---@type render.md.UserConfig
        opts = {
            render_modes = true,
        },
    }
}
