return {
    "stevearc/oil.nvim",
    lazy = false,
    ---@module "oil"
    ---@type oil.SetupOpts
    opts = {
        default_file_explorer = true,
        keymaps = {
            ["g?"] = "actions.show_help",
            ["<CR>"] = "actions.select",
            ["gp"] = "actions.preview",
            ["gr"] = "actions.refresh",
            ["<BS>"] = "actions.parent",
            ["~"] = "actions.open_cwd",
            ["g."] = "actions.toggle_hidden",
        },
        use_default_keymaps = false,
        view_options = {
            show_hidden = true,
        },
    },
    keys = {
        { "<leader>r", "<cmd>Oil<cr>", desc = "Open oil" },
    },
}
