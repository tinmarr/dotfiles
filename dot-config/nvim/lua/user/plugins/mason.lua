return {
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        keys = {
            { "<leader>am", "<cmd>execute 'MasonToolsInstall' | Mason<cr>", desc = "Open Mason" }
        },
        opts = {},
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        opts = {}
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
        },
        cmd = {
            "MasonToolsInstall",
            "MasonToolsClean",
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
                "js-debug-adapter",
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
