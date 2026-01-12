return {
    "folke/snacks.nvim",
    event = "VeryLazy",
    dependencies = {
        "echasnovski/mini.icons",
    },
    keys = {
        { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Show notification history" },
        { "<leader>nc", function() Snacks.notifier.hide() end,         desc = "Clear notifications" },
    },
    ---@class snacks.Config
    opts = {
        bigfile = {},
        indent = {
            indent = {
                char = "▏",
            },
            animate = { enabled = false },
            scope = {
                char = "▏",
            }
        },
        notifier = {},
        scope = {},
        statuscolumn = {
            left = { "sign" },         -- priority of signs on the left (high to low)
            right = { "fold", "git" }, -- priority of signs on the right (high to low)
            folds = {
                open = true,
                git_hl = true,
            },
        },
    },
}
