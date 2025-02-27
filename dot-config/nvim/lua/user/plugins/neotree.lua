return {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    keys = {
        { "<leader>e", "<cmd>Neotree<cr>", desc = "Open Neotree" },
    },
    opts = {
        sources = { "filesystem" },
        close_if_last_window = true,
        enable_cursor_hijack = true,
        enable_diagnostics = false,
        window = {
            position = "right",
            mappings = {
                ["l"] = "open",
                ["h"] = "close_node",
                ["z"] = false,
            }
        },
        filesystem = {
            filtered_items = {
                visible = true
            },
            follow_current_file = {
                enabled = true
            },
        },
        default_component_configs = {
            git_status = {
                symbols = {
                    untracked = "",
                    ignored   = "",
                    unstaged  = "",
                    staged    = "",
                    conflict  = "",
                }
            }
        }
    },
}
