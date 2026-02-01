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
        "nvim-mini/mini.surround",
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
        "nvim-mini/mini.comment",
        event = { "BufReadPost", "BufNewFile" },
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
        "nvim-mini/mini.pairs",
        event = "InsertEnter",
        opts = {
            mappings = {
                ['«'] = { action = 'open', pair = '«»', neigh_pattern = '[^\\].' },
                ['»'] = { action = 'close', pair = '«»', neigh_pattern = '[^\\].' },
            }
        },
        config = function(_, opts)
            require("mini.pairs").setup(opts)
            -- Add $ pairing only for typst files
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "typst",
                callback = function()
                    MiniPairs.map_buf(0, "i", "$", { action = "closeopen", pair = "$$", neigh_pattern = "[^%a\\]." })
                end,
            })
        end,
    },
    {
        "nvim-mini/mini.splitjoin",
        keys = { "gs", desc = "Toggle split join", mode = { "n", "v" } },
        opts = {
            mappings = {
                toggle = "gs"
            }
        }
    },
    {
        "nvim-mini/mini.icons",
        config = function(_, opts)
            require("mini.icons").setup(opts)
            MiniIcons.mock_nvim_web_devicons()
        end
    },
    {
        "nvim-mini/mini.files",
        dependencies = { "nvim-mini/mini.icons" },
        keys = {
            { "<leader>r", function() MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end, desc = "Open mini files" }
        },
        opts = {
            mappings = {
                synchronize = "gs"
            },
            windows = {
                preview = true,
                max_number = 3,
            },
        },
    },
}
