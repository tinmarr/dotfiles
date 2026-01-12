local function attempt_telescope()
    local ok, _ = pcall(
    ---@diagnostic disable-next-line: param-type-mismatch
        vim.cmd,
        "Telescope git_files show_untracked=true"
    )
    if not ok then
        vim.cmd("Telescope find_files")
    end
end

return {
    {
        "nvim-telescope/telescope.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
            "BurntSushi/ripgrep",
            "sharkdp/fd",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make"
            },
            "nvim-telescope/telescope-ui-select.nvim",
        },
        cmd = "Telescope",
        keys = {
            { "<C-k>",      attempt_telescope,                                                                desc = "Find file (best strat)" },
            { "<leader>ff", attempt_telescope,                                                                desc = "Find file (best strat)" },
            { "<leader>fF", "<cmd>Telescope find_files<cr>",                                                  desc = "Find file" },
            { "<leader>fh", "<cmd>Telescope find_files hidden=true no_ignore=true no_ignore_parent=true<cr>", desc = "Find hidden file" },
            { "<leader>fo", "<cmd>Telescope oldfiles only_cwd=true<cr>",                                      desc = "Find oldfiles in cwd" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",                                                   desc = "Grep through working dir" },
            { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>",                                   desc = "Fuzzy find buffer" },
            { "<leader>fs", "<cmd>Telescope treesitter<cr>",                                                  desc = "Find symbol" },
            { "<leader>bi", "<cmd>Telescope buffers<cr>",                                                     desc = "List buffers" },
        },
        opts = {
            defaults = {
                mappings = {
                    i = {
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",
                        ["<esc>"] = "close",
                    }
                },
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        height = 0.75,
                    }
                },
                sorting_strategy = "ascending",
            },
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_cursor()
                }
            }
        },
        config = function(_, opts)
            require("telescope").setup(opts)
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("ui-select")
        end,
    },
}
