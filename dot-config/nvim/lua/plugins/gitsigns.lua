return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
        { "<leader>gb", "<cmd>Gitsigns blame<cr>",               desc = "Show full file blame" },
        { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>",          desc = "Reset hunk" },
        { "<leader>gp", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "Preview hunk" },
    },
    opts = {
        current_line_blame = true,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
        },
    }
}
