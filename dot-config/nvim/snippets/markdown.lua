---@diagnostic disable
-- local ls = require("luasnip")
-- local s = ls.snippet
-- local t = ls.text_node
-- local i = ls.insert_node

return {
    s("- new task", fmt("- [ ] _{tag}:_ ({date}) ", { tag = i(1, "tag"), date = i(2, "yyyy-mm-dd") }))
}
