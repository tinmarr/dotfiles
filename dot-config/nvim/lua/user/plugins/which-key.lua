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
            { "<leader>b", group = "buffer" },
            { "<leader>f", group = "telescope" },
            { "<leader>l", group = "lsp" },
            { "<leader>d", group = "debugger" },
            { "<leader>c", group = "comment" },
            { "<leader>a", group = "apps" },
            { "<leader>n", group = "notifications" },
            { "<leader>t", group = "trouble" },
            { "<leader>o", group = "obsidian" },
            { "<leader>s", group = "surround" },
            { "<leader>h", group = "harpoon" },
        })
    end,
}
