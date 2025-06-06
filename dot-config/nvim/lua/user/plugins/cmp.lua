return {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
    },
    opts = function()
        local luasnip = require("luasnip")
        local cmp = require("cmp")

        local backwards = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.abort()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" })
        local advance = cmp.mapping(function(fallback)
            if cmp.visible() then
                if luasnip.expandable() then
                    luasnip.expand({})
                else
                    cmp.confirm({
                        select = true,
                    })
                end
            elseif luasnip.locally_jumpable(1) then
                luasnip.jump(1)
            else
                fallback()
            end
        end, { "i", "s" })

        return {
            mapping = {
                ["<C-j>"] = cmp.mapping.select_next_item(),
                ["<C-k>"] = cmp.mapping.select_prev_item(),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-l>"] = advance,
                ["<C-h>"] = backwards,
                ["<Tab>"] = advance,
                ["<S-Tab>"] = backwards,
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            sources = cmp.config.sources({
                    { name = "luasnip" },
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = "lazydev" },
                },
                {
                    { name = "render-markdown" },
                    { name = "buffer" },
                }),
            window = {
                completion = {
                    border = "rounded",
                    scrollbar = false,
                    winhighlight = "",
                },
                documentation = {
                    border = "rounded",
                    winhighlight = "",
                },
            },
            preselect = cmp.PreselectMode.None,
        }
    end,
    config = function(_, opts)
        local cmp = require("cmp")
        cmp.setup(opts)
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            }),
        })
    end
}
