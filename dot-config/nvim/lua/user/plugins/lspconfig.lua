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

    map("n", "<leader>lR", "<cmd>LspRestart<cr>", { desc = "Restart lsp" })
end


return {
    {
        "neovim/nvim-lspconfig",
        ft = { "go", "lua", "yaml", "vue", "ts", "json", "c", "cpp", "python", "toml", "typst" },
        dependencies = {
            "williamboman/mason.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "williamboman/mason-lspconfig.nvim",
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
                volar = {},            -- vue
                ts_ls = {
                    init_options = {}, -- defined at runtime
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
            },
        },
        config = function(_, opts)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local border = "rounded"

            vim.diagnostic.config({
                float = {
                    border = border,
                }
            })

            for name, conf in pairs(opts.servers) do
                if name == "ts_ls" then
                    local mason_registry = require('mason-registry')
                    local vue_language_server_path = mason_registry.get_package('vue-language-server'):get_install_path() ..
                        '/node_modules/@vue/language-server'

                    conf.init_options = {
                        plugins = {
                            {
                                name = "@vue/typescript-plugin",
                                location = vue_language_server_path,
                                languages = { "vue" },
                            }
                        }
                    }
                end

                vim.lsp.enable(name)
                vim.lsp.config(name,
                    {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = conf.settings,
                        init_options = conf.init_options,
                        filetypes = conf.filetypes,
                    }
                )
            end
        end
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {}
    }
}
