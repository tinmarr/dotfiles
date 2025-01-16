return {
    "folke/which-key.nvim",
    dependencies = {
        "echasnovski/mini.icons",
        "nvim-tree/nvim-web-devicons"
    },
    event = "VeryLazy",
    ---@class wk.Opts
    opts = {
        preset = "helix",
        icons = {
            mappings = false
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
            { "<leader>t", group = "table mode" },
            { "<leader>o", group = "obsidian" },
        })
    end,
}
