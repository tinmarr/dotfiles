vim.api.nvim_create_user_command("ConformFormat", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, {})

return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    dependencies = {
        "mason-org/mason.nvim",
    },
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
        -- Set up format-on-save
        format_after_save = { async = true, timeout_ms = 500 },
        formatters_by_ft = {
            html = { "prettier" },
            go = { "gofumpt", lsp_format = "first" },
            yaml = { "prettier" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            vue = { "prettier" },
            json = { "prettier" },
            c = { lsp_format = "never" },
            python = { "black", "isort", stop_after_first = false },
            markdown = { "prettier" },
            arduino = { "clang-format" },
            typst = { "typstyle" },
        },
        default_format_opts = {
            lsp_format = "fallback",
        }
    },
}
