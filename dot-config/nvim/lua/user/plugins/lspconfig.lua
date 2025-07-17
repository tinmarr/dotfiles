local on_attach = function(_, bufnr)
    local map = function(mode, l, r, opts)
        opts = opts or {}
        opts.silent = true
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
    end

    map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "See symbol definition" })
    map("n", "<leader>li", vim.lsp.buf.implementation, { desc = "See symbol implementation" })
    map("n", "<leader>lf", vim.lsp.buf.references, { desc = "See symbol references" })
    map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Execute code actions" })
    map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename a symbol" })
    map("n", "<leader>lk", vim.diagnostic.open_float, { desc = "Open floating diagnostics" })
    map("n", "<leader>lx", vim.diagnostic.setloclist, { desc = "Open buffer diagnostics" })
    map("n", "<leader>lX", vim.diagnostic.setqflist, { desc = "Open all diagnostics" })

    map("n", "<leader>lR", "<cmd>LspRestart<cr>", { desc = "Restart lsp" })
end

local border = "rounded"

vim.diagnostic.onfig({
    virtual_text = true,
    float = {
        border = border,
    },
    loclist = {
        open = true,
        severity = { min = vim.diagnostic.severity.WARN },
    }
})

vim.lsp.config("*", {
    on_attach = on_attach,
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
                eslint = {},
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
