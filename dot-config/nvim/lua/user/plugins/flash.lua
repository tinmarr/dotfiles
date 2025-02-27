return {
    "folke/flash.nvim",
    keys = {
        { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    },
    opts = {
        search = {
            mode = "fuzzy",
        },
        jump = {
            autojump = true,
        },
    },
}
