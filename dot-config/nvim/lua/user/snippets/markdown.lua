---@diagnostic disable
-- local ls = require("luasnip")
-- local s = ls.snippet
-- local t = ls.text_node
-- local i = ls.insert_node

return {
    s("- new task", {
        t({ "- [ ] _" }),
        i(1),
        t({ ":_ " }),
    })
}
