return {
    "dhruvasagar/vim-table-mode",
    config = function()
        vim.g.table_mode_corner = "|"
        vim.g.table_mode_disable_mappings = 1
    end,
    keys = {
        { "<leader>at", "<cmd>TableModeToggle<cr>", desc = "Toggle table mode" },
    },
}
