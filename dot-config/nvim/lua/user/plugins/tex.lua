return {
    {
        "lervag/vimtex",
        ft = { "tex" },
        init = function()
            -- VimTeX configuration goes here, e.g.
            vim.g.tex_flavor = 'latex'
            vim.g.vimtex_view_method = 'zathura'
            vim.g.vimtex_quickfix_mode = 0
            vim.g.tex_conceal = 'abdmg'
            vim.opt.conceallevel = 1
        end
    }
}
