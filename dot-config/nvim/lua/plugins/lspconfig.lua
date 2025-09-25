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

-- On attach
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        local bufnr = args.buf


        local function map(mode, lhs, rhs, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, lhs, rhs, opts)
        end


        map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "See symbol definition" })
        map("n", "<leader>li", vim.lsp.buf.implementation, { desc = "See symbol implementation" })
        map("n", "<leader>lf", vim.lsp.buf.references, { desc = "See symbol references" })
        map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename a symbol" })
        map("n", "<leader>lk", vim.diagnostic.open_float, { desc = "Open floating diagnostics" })
        map("n", "<leader>lx", vim.diagnostic.setloclist, { desc = "Open buffer diagnostics" })
        map("n", "<leader>lX", vim.diagnostic.setqflist, { desc = "Open all diagnostics" })
        map("n", "<leader>lR", "<cmd>LspRestart<cr>", { desc = "Restart lsp" })
        map("n", "<leader>la", function()
            vim.lsp.buf.code_action({
                ---@diagnostic disable-next-line: missing-fields
                context = {
                    only = client.server_capabilities.codeActionProvider.codeActionKinds,
                },
            })
        end, { desc = "Execute code actions" })
    end
})

return {
    {
        "neovim/nvim-lspconfig",
        ft = { "go", "lua", "yaml", "vue", "typescript", "json", "c", "cpp", "python", "toml", "typst", "sh", "bash", "markdown", "arduino" },
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
                        formatterPrintWidth = 80,
                        formatterProseWrap = true,
                        semanticTokens = "enable",
                        lint = {
                            enabled = true,
                        }
                    }
                },
                golangci_lint_ls = {},
                bashls = {},
                marksman = {},
                arduino_language_server = {},
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
                        on_attach = conf.on_attach,
                        cmd = conf.cmd,
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
