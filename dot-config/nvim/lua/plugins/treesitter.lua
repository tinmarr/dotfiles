return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "hyprlang",
                "go",
                "lua",
                "yaml",
                "vue",
                "javascript",
                "typescript",
                "json",
                "c",
                "cpp",
                "python",
                "toml",
                "typst",
                "bash",
                "markdown",
                "arduino",
                "astro",
            },
            auto_install = true,
            sync_install = false,
            ignore_install = {},
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
                disable = { "latex" },
            },
            indent = {
                enable = true
            },
            modules = {} -- doesn't do anything... for lsp
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)

            vim.filetype.add({
                pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
            })

            vim.api.nvim_set_hl(0, "@markup.italic", { italic = true, fg = "#a6e3a1" })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            multiwindow = true,
            max_lines = 4,
        }
    }
}
