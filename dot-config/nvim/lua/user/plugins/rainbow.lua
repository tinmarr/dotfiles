return {
	"HiPhish/rainbow-delimiters.nvim",
	config = function(_, _)
		require("rainbow-delimiters.setup").setup {
			highlight = {
				"RainbowDelimiterRed",
				"RainbowDelimiterCyan",
				"RainbowDelimiterViolet",
				"RainbowDelimiterBlue",
				"RainbowDelimiterOrange",
				"RainbowDelimiterGreen",
				"RainbowDelimiterYellow",
			}
		}

		vim.cmd("highlight! link RainbowDelimiterRed DraculaFg")
		vim.cmd("highlight! link RainbowDelimiterYellow DraculaYellow")
		vim.cmd("highlight! link RainbowDelimiterBlue DraculaPink")
		vim.cmd("highlight! link RainbowDelimiterOrange DraculaOrange")
		vim.cmd("highlight! link RainbowDelimiterGreen DraculaGreen")
		vim.cmd("highlight! link RainbowDelimiterViolet DraculaPurple")
		vim.cmd("highlight! link RainbowDelimiterCyan DraculaCyan")
	end,
}
