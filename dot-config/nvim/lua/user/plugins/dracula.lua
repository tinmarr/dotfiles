return {
    "dracula/vim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.g.dracula_colorterm = 0
        vim.cmd([[colorscheme dracula]])
    end,
}
