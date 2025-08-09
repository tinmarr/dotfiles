return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
    opts = {
        popupmenu = {
            enabled = false,
        },
        messages = {
            enabled = false,
        },
        notify = {
            enabled = false
        },
        lsp = {
            progress = {
                enabled = false,
            },
            documentation = {
                enabled = true,
                opts = {
                    border = {
                        style = "rounded",
                        padding = { 0, 1 },
                    },
                    position = {
                        row = 2,
                        col = 0,
                    },
                    win_options = {
                        winhighlight = {
                            Normal = "",
                        }
                    },
                    scrollbar = false,
                },
            },
        }
    },
}
