return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>ls",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = "",
            desc = "Format buffer",
        },
    },
    dependencies = {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
        -- Set up format-on-save
        format_after_save = { async = true, timeout_ms = 500 },
        formatters_by_ft = {
            go = { lsp_format = "first" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            vue = { "prettier" },
            json = { "jq" },
            c = { lsp_format = "never" },
            python = { "black", "isort", stop_after_first = false },
        },
        default_format_opts = {
            lsp_format = "fallback",
        }
    },
    init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
