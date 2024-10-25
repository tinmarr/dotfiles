return {
	"folke/which-key.nvim",
	dependencies = {
		"echasnovski/mini.icons",
		"nvim-tree/nvim-web-devicons"
	},
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		icons = {
			mappings = false
		}
	},
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)
		wk.add({
			{ "<leader>b", group = "buffer" },
			{ "<leader>f", group = "telescope" },
			{ "<leader>l", group = "lsp" },
			{ "<leader>c", group = "comment" },
			{ "<leader>a", group = "apps" },
		})
	end,
}
