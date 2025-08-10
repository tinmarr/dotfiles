---@diagnostic disable
-- local ls = require("luasnip")
-- local s = ls.snippet
-- local t = ls.text_node
-- local i = ls.insert_node

return {
    s("iferr", fmta([[
    if <> != nil {
   	\t<>
    }
    ]], {
        i(1, "err"), i(2)
    }, {
        indent_string = [[\t]]
    }))
}
