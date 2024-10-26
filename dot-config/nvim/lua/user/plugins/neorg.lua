return {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    dependencies = {
        "3rd/image.nvim",
    },
    opts = {
        load = {
            ["core.defaults"] = {},
            ["core.concealer"] = {},
            ["core.dirman"] = {
                config = {
                    workspaces = {
                        notes = "~/notes",
                    },
                    default_workspace = "notes",
                },
            },
            ["core.latex.renderer"] = {},
        },
    },
    config = function(_, opts)
        require("neorg").setup(opts)

        vim.wo.foldlevel = 99
        vim.wo.conceallevel = 2
    end
}
