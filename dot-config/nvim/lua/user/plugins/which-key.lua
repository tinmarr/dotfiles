return {
    "folke/which-key.nvim",
    dependencies = {
        "echasnovski/mini.icons",
    },
    event = "VeryLazy",
    ---@class wk.Opts
    opts = {
        preset = "helix",
        icons = {
            -- mappings = false
        },
        plugins = {
            operators = false,
            motions = false,
            text_objects = false,
        },
        delay = 500,
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)
        wk.add({
            { "<leader>a",      group = "apps" },
            { "<leader>b",      group = "buffer" },
            { "<leader>c",      group = "comment" },
            { "<leader>d",      group = "debugger" },
            { "<leader>f",      group = "telescope" },
            { "<leader>g",      group = "git" },
            { "<leader>h",      group = "harpoon" },
            { "<leader>l",      group = "lsp" },
            { "<leader>n",      group = "notifications" },
            { "<leader>o",      group = "obsidian" },
            { "<leader>s",      group = "surround" },
            { "<leader>t",      group = "trouble" },
            { "<leader>v",      group = "diffview" },

            { "<localleader>p", group = "preview" },
        })
    end,
}
