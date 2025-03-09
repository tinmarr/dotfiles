return {
    "dhruvasagar/vim-table-mode",
    config = function()
        vim.g.table_mode_corner = "|"
    end,
    keys = {
        { "<leader>at", "<cmd>TableModeToggle<cr>", desc = "Toggle table mode" },
    },
}
