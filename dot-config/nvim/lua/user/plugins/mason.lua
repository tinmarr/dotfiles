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
                "ts_ls",
                "jsonls",
                "pyright",
                "taplo",
                "tinymist",
                "eslint",
                "golangci_lint_ls",
                -- debuggers
                "delve",
                -- linters
                "golangci-lint",
                -- formatters
                "isort",
                "black",
                "prettier",
                "gofumpt",
            },
            auto_update = true
        },
        config = function(_, opts)
            require("mason-tool-installer").setup(opts)
            vim.cmd("MasonToolsInstall")
            vim.cmd("MasonToolsClean")
        end
    },
}
