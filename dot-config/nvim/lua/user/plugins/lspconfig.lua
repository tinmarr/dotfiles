local on_attach = function(_, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { unpack(opts), desc = "See symbol definition" })
    vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, { unpack(opts), desc = "See symbol implementation" })
    vim.keymap.set("n", "<leader>lf", vim.lsp.buf.references, { unpack(opts), desc = "See symbol references" })
    vim.keymap.set("n", "<leader>lk", vim.lsp.buf.hover, { unpack(opts), desc = "See symbol hover dialog" })
    vim.keymap.set("n", "<leader>l.", vim.lsp.buf.code_action, { unpack(opts), desc = "Execute code actions" })
    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { unpack(opts), desc = "Rename a symbol" })

    vim.keymap.set("n", "<leader>lR", "<cmd>LspRestart<cr>")
end


return {
    {
        "neovim/nvim-lspconfig",
        ft = { "go", "lua", "yaml", "vue", "ts", "json", "c", "cpp", "python", "toml" },
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
                volar = {},
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
                taplo = {},
            },
        },
        config = function(_, opts)
            local lspconfig = require("lspconfig");
            local capabilities = require("cmp_nvim_lsp").default_capabilities()


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

                lspconfig[name].setup {
                    capabilities = capabilities,
                    on_attach = on_attach,
                    settings = conf.settings,
                    init_options = conf.init_options,
                    filetypes = conf.filetypes,
                }
            end
        end
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {}
    }
}
