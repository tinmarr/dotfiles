local on_attach = function(_, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { unpack(opts), desc = "See symbol definition" })
    vim.keymap.set("n", "<leader>lf", vim.lsp.buf.references, { unpack(opts), desc = "See symbol references" })
    vim.keymap.set("n", "<leader>lk", vim.lsp.buf.hover, { unpack(opts), desc = "See symbol hover dialog" })
    vim.keymap.set("n", "<leader>l.", vim.lsp.buf.code_action, { unpack(opts), desc = "Execute code actions" })
    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { unpack(opts), desc = "Rename a symbol" })

    vim.keymap.set("n", "<leader>lR", "<cmd>LspRestart<cr>")
end


return {
    {
        "neovim/nvim-lspconfig",
        ft = { "go", "lua", "yaml" },
        dependencies = {
            "williamboman/mason.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "williamboman/mason-lspconfig.nvim",
        },
        opts = {
            servers = {
                lua_ls = {},
                gopls = {},
                yamlls = {},
            },
        },
        config = function(_, opts)
            local lspconfig = require("lspconfig");
            local capabilities = require("cmp_nvim_lsp").default_capabilities()


            for name, conf in pairs(opts.servers) do
                lspconfig[name].setup {
                    capabilities = capabilities,
                    settings = conf.settings,
                    on_attach = on_attach,
                }
            end
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
        },
        lazy = true,
        opts = {
            ensure_installed = { "lua_ls", "gopls", "yamlls" }
        }
    },
    {
        -- Plugin to configure lua lsp to be good for nvim config
        "folke/lazydev.nvim",
        ft = "lua",
        config = true,
    },
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        config = true
    },
}
