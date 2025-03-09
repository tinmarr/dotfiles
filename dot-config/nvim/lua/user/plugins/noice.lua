return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
    opts = {
        -- add any options here
        messages = {
            enabled = false
        },
        notify = {
            enabled = false
        },
        lsp = {
            progress = {
                enabled = false,
            }
        }
    },
}
