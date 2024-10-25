return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
		},
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
			{ "<C-p>",      "<cmd>Telescope git_files show_untracked=true<cr>",                               desc = "Find git file" },
			{ "<leader>ff", "<cmd>Telescope git_files show_untracked=true<cr>",                               desc = "Find git file" },
			{ "<leader>fF", "<cmd>Telescope find_files<cr>",                                                  desc = "Find file" },
			{ "<leader>fh", "<cmd>Telescope find_files hidden=true no_ignore=true no_ignore_parent=true<cr>", desc = "Find hidden file" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>",                                                   desc = "Grep through working dir" },
			{ "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>",                                   desc = "Fuzzy find buffer" },
			{ "<leader>bi", "<cmd>Telescope buffers<cr>",                                                     desc = "List buffers" },
		},
	}
}
