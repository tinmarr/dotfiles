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
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
        -- Set up format-on-save
        format_on_save = { timeout_ms = 500 },
        formatters_by_ft = {
            go = { lsp_format = "first" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            vue = { "prettier" },
            json = { "jq" },
            c = { lsp_format = "never" },
        },
        default_format_opts = {
            lsp_format = "fallback",
        }
    },
    init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
