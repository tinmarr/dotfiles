return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = {
            { "<leader>am", "<cmd>Mason<cr>", desc = "Open Mason" }
        },
        opts = {}
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
        },
        opts = {
            ensure_installed = { "lua_ls", "gopls", "yamlls", "volar", "ts_ls", "jsonls", "pyright", "taplo" }
        }
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        opts = {
            ensure_installed = {
                "isort",
                "black"
            },
            auto_update = true
        },
        config = function(_, opts)
            require("mason-tool-installer").setup(opts)
            vim.cmd("MasonToolsUpdate")
        end
    }
}
