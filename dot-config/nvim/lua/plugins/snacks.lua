return {
    "folke/snacks.nvim",
    lazy = false,
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
        dashboard = {
            preset = {
                keys = {
                    { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                    { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                    { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
                    { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                    { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
            },
            sections = {
                { section = "header" },
                {
                    align = "center",
                    padding = 1,
                    height = 1,
                    text = {
                        vim.fn.getcwd()
                    }
                },
                { section = "keys", gap = 1, padding = 2 },
                { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 2 },
                { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
                { section = "startup" },
            },
        },
        indent = {
            indent = {
                char = "▏",
            },
            animate = { enabled = false },
            scope = {
                char = "▏",
            }
        },
        input = {},
        notifier = {},
        quickfile = {},
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
