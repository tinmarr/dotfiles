return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
        { "<leader>an", function() Snacks.notifier.show_history() end, desc = "Show notification history" }
    },
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
                { section = "keys", gap = 1, padding = 2 },
                { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 2 },
                { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
                { section = "startup" },
            },
        },
        image = {},
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
        statuscolumn = {},
    },
}
