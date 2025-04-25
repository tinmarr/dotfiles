return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = {
            { "<leader>am", "<cmd>Mason<cr>", desc = "Open Mason" }
        },
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        opts = {}
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        opts = {
            ensure_installed = {
                -- lsps
                "lua_ls",
                "gopls",
                "yamlls",
                "volar",
                "ts_ls",
                "jsonls",
                "pyright",
                "taplo",
                "tinymist",
                -- debuggers
                "delve",
                -- linters
                -- formatters
                "isort",
                "black",
                "prettier",
            },
            auto_update = true
        },
        config = function(_, opts)
            require("mason-tool-installer").setup(opts)
            vim.cmd("MasonToolsUpdate")
            vim.cmd("MasonToolsClean")
        end
    },
}
