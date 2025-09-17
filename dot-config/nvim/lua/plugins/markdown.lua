vim.api.nvim_set_hl(0, "RenderMarkdownCheckboxChecked", {
    fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg,
    strikethrough = true,
})

vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", {
    fg = vim.api.nvim_get_hl(0, { name = "CatppucinPeach" }).fg,
    bg = vim.api.nvim_get_hl(0, { name = "CatppucinCrust" }).bg,
})

return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
        ft = "markdown",
        ---@module "render-markdown"
        ---@type render.md.UserConfig
        opts = {
            render_modes = true,
            sign = {
                enabled = false,
            },
            heading = {
                position = "inline",
                sign = false,
                backgrounds = {},
                icons = { "󰲠 ", "󰲢 ", "󰲤 ", "󰲦 ", "󰲨 ", "󰲪 " },
            },
            checkbox = {
                checked = {
                    scope_highlight = "RenderMarkdownCheckboxChecked"
                },
                custom = {
                    todo = { raw = "[ ]", rendered = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
                    in_progress = { raw = "[/]", rendered = "󰡖 ", highlight = "RenderMarkdownTodo" },
                    cancelled = { raw = "[-]", rendered = "󰅗 ", highlight = "RenderMarkdownError" },
                    rescheduled = { raw = "[>]", rendered = "󱄵 ", highlight = "RenderMarkdownInfo" },
                    scheduled = { raw = "[<]", rendered = "󰃮 ", highlight = "RenderMarkdownHint" },
                    important = { raw = "[!]", rendered = "󰀧 ", highlight = "RenderMarkdownWarn" },
                    question = { raw = "[?]", rendered = "󰋗 ", highlight = "RenderMarkdownH2" },
                    star = { raw = "[*]", rendered = "󰓎 ", highlight = "RenderMarkdownWarn" },
                },
            },
            pipe_table = {
                preset = "round"
            },
            code = {
                border = "thick",
                left_pad = 1,
            },
            custom_handlers = {
                markdown = {
                    extends = true,
                    parse = require("md_date_handler").parse,
                }
            }
        },
    },
    {
        "fmorroni/peek.nvim",
        branch = "callouts",
        -- original repo
        -- "toppair/peek.nvim",
        build = vim.fn.stdpath("data") .. "/mason/bin/deno task --quiet build:fast",
        ft = { "markdown" },
        opts = {
            auto_load = false,
            app = "zen-browser",
        },
        config = function(_, opts)
            require("peek").setup(opts)
            vim.api.nvim_create_user_command("PeekToggle", function()
                local p = require("peek")
                if p.is_open() then
                    p.close()
                else
                    p.open()
                end
            end, {})
        end,
    },
}
