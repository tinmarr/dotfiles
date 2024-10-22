return {
	{
		"nvim-telescope/telescope.nvim", 
		tag = "0.1.8",
		dependencies = {"nvim-lua/plenary.nvim"},
		opts = {
			defaults = {
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
						["<esc>"] = "close",
					}
				}
			}
		},
		keys = {
			{"<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find file"},
			{"<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Project-wide search"},
			{"<leader>bl", "<cmd>Telescope buffers<cr>", desc = "Project-wide search"},
		},
	},
	{"nvim-treesitter/nvim-treesitter"}
}
