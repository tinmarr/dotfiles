---@diagnostic disable
-- local ls = require("luasnip")
-- local s = ls.snippet
-- local t = ls.text_node
-- local i = ls.insert_node

return {
    s("iferr", {
        t({ "if err != nil {", "\t" }),
        i(1),
        t({ "", "}" })
    })
}
