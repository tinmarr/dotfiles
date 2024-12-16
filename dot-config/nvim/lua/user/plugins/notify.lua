return {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    init = function()
        vim.notify = require("notify")
    end
}
