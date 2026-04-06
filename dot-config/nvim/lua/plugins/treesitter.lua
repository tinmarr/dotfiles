local ensureInstalled = {
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
    "astro",
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        build = ":TSUpdate",
        opts = {},
        init = function()
            -- runs on every buffer
            vim.api.nvim_create_autocmd('FileType', {
                callback = function()
                    pcall(vim.treesitter.start)
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    vim.wo[0][0].foldmethod = 'expr'
                end,
            })

            local alreadyInstalled = require('nvim-treesitter.config').get_installed()
            local parsersToInstall = vim.iter(ensureInstalled)
                :filter(function(parser)
                    return not vim.tbl_contains(alreadyInstalled, parser)
                end)
                :totable()
            require('nvim-treesitter').install(parsersToInstall)


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
