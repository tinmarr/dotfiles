local on_attach = function(_, bufnr)
	local opts = {buffer = bufnr, remap = false}

	vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<leader>lf", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "<leader>lk", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>l.", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)

    vim.keymap.set("n", "<leader>lR", "<cmd>LspRestart<cr>")
end


return {
	{
		"neovim/nvim-lspconfig",
		ft = { "go", "lua" },
		opts = {
			servers = {
				lua_ls = {},
				gopls = {},
			},
		},
		config = function(_, opts)
			local lspconfig = require("lspconfig");

			for name, conf in pairs(opts.servers) do
				lspconfig[name].setup {
					settings = conf.settings,
					on_attach = on_attach,
				}
			end
		end
	},
	{
		-- Plugin to configure lua lsp to be good for nvim config
		"folke/lazydev.nvim",
		ft = "lua",
		config = true,
	}
}

