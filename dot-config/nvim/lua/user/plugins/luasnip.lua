return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    config = function()
        require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/lua/user/snippets" } })
    end,
}
