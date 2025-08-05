vim.api.nvim_set_hl(0, "RenderMarkdownCheckboxChecked", {
    fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg,
    strikethrough = true,
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
            code = {
                border = "thick",
                left_pad = 1,
            }
        },
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function()
            require("lazy").load({ plugins = { "markdown-preview.nvim" } })
            vim.fn["mkdp#util#install"]()
        end,
        keys = {
            { "<localleader>pm", "<cmd>MarkdownPreviewToggle<cr>", desc = "MarkdownPreviewToggle" }
        },
    }
}
