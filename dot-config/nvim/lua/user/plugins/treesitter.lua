return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	ft = { "lua", "go" },
	config = function()
		require("nvim-treesitter.configs").setup {
			ensure_installed = { "lua", "go" },
			auto_install = true,
			sync_install = false,
			ignore_install = { "org" },
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false
			},
			indent = {
				enable = true
			},
			modules = {} -- doesn't do anything... for lsp
		}
	end,
}
