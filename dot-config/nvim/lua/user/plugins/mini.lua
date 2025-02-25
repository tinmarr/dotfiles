-- MiniSurround.config
local surroundOpts = {
    mappings = {
        add = "<leader>sa",
        delete = "<leader>sd",         -- Delete surrounding
        find = "<leader>sf",           -- Find surrounding (to the right)
        find_left = "<leader>sF",      -- Find surrounding (to the left)
        highlight = "<leader>sh",      -- Highlight surrounding
        replace = "<leader>sr",        -- Replace surrounding
        update_n_lines = "<leader>sn", -- Update `n_lines`
    },

    search_method = "cover_or_next",
}

return {
    {
        "echasnovski/mini.surround",
        keys = function(_, keys)
            -- Populate the keys based on the user's options
            local mappings = {
                { surroundOpts.mappings.add,            desc = "Add Surrounding",                     mode = { "n", "v" } },
                { surroundOpts.mappings.delete,         desc = "Delete Surrounding" },
                { surroundOpts.mappings.find,           desc = "Find Right Surrounding" },
                { surroundOpts.mappings.find_left,      desc = "Find Left Surrounding" },
                { surroundOpts.mappings.highlight,      desc = "Highlight Surrounding" },
                { surroundOpts.mappings.replace,        desc = "Replace Surrounding" },
                { surroundOpts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
            }
            mappings = vim.tbl_filter(function(m)
                return m[1] and #m[1] > 0
            end, mappings)
            return vim.list_extend(mappings, keys)
        end,
        opts = surroundOpts,
    },
    {
        "echasnovski/mini.comment",
        event = "VeryLazy",
        opts = {
            mappings = {
                comment = "<leader>c",
                comment_line = "<leader>cc",
                comment_visual = "<leader>c",
                textobject = "<leader>c",
            },
        },
    },
    {
        "echasnovski/mini.pairs",
        event = "InsertEnter",
        config = true,
    },
    {
        "echasnovski/mini.splitjoin",
        keys = { "gs", desc = "Toggle split join", mode = { "n", "v" } },
        opts = {
            mappings = {
                toggle = "gs"
            }
        }
    }
}
