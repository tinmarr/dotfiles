local border = "rounded"

vim.diagnostic.config({
    virtual_text = true,
    float = {
        border = border,
    },
    loclist = {
        open = true,
        severity = { min = vim.diagnostic.severity.WARN },
    }
})

return {
    {
        "neovim/nvim-lspconfig",
        ft = { "go", "lua", "yaml", "vue", "typescript", "json", "c", "cpp", "python", "toml", "typst", "sh", "bash" },
        dependencies = {
            "mason-org/mason.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "mason-org/mason-lspconfig.nvim",
            "nvim-telescope/telescope.nvim",
        },
        opts = {
            servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            runtime = {
                                version = "LuaJIT",
                                path = vim.split(package.path, ";")
                            },
                            diagnostics = {
                                globals = { "vim", "Snacks", "MiniFiles" }
                            },
                            workspace = {
                                checkThirdParty = false,
                            }
                        }
                    }
                },
                gopls = {},
                yamlls = {},
                ts_ls = {
                    filetypes = {
                        "javascript",
                        "typescript",
                        "vue",
                    },
                },
                jsonls = {},
                clangd = {},
                pyright = {},
                taplo = {},  -- toml
                tinymist = { -- typst
                    settings = {
                        formatterMode = "typstyle",
                        exportPdf = "onSave",
                        semanticTokens = "enable",
                    }
                },
                eslint = {
                    settings = {
                        completion = {
                            enable = false,
                        },
                    },
                },
                golangci_lint_ls = {},
                bashls = {},
            },
        },
        config = function(_, opts)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            for name, conf in pairs(opts.servers) do
                vim.lsp.config(name,
                    {
                        capabilities = capabilities,
                        settings = conf.settings,
                        init_options = conf.init_options,
                        filetypes = conf.filetypes,
                    }
                )
                vim.lsp.enable(name)
            end
        end
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {}
    }
}
