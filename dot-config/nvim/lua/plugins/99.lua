return {
	"ThePrimeagen/99",
	keys = {
		{ "<leader>av", function() require("99").visual() end,            desc = "99 visual", mode = "v" },
		{ "<leader>as", function() require("99").stop_all_requests() end, desc = "99 stop",   mode = { "n", "v" } },
	},
	config = function()
		local _99 = require("99")

		local cwd = vim.uv.cwd()
		local basename = vim.fs.basename(cwd)
		_99.setup({
			provider = _99.OpenCodeProvider, -- default: OpenCodeProvider
			model = "opencode/kimi-k2.5-free",
			logger = {
				level = _99.ERROR,
				path = "/tmp/" .. basename .. ".99.debug",
				print_on_error = true,
			},


			--- Completions: #rules and @files in the prompt buffer
			completion = {
				-- I am going to disable these until i understand the
				-- problem better.  Inside of cursor rules there is also
				-- application rules, which means i need to apply these
				-- differently
				-- cursor_rules = "<custom path to cursor rules>"

				--- A list of folders where you have your own SKILL.md
				--- Expected format:
				--- /path/to/dir/<skill_name>/SKILL.md
				---
				--- Example:
				--- Input Path:
				--- "scratch/custom_rules/"
				---
				--- Output Rules:
				--- {path = "scratch/custom_rules/vim/SKILL.md", name = "vim"},
				--- ... the other rules in that dir ...
				---
				custom_rules = {},

				--- Configure @file completion (all fields optional, sensible defaults)
				files = {
					-- enabled = true,
					-- max_file_size = 102400,     -- bytes, skip files larger than this
					-- max_files = 5000,            -- cap on total discovered files
					-- exclude = { ".env", ".env.*", "node_modules", ".git", ... },
				},

				--- What autocomplete do you use.  We currently only
				--- support cmp right now
				source = "cmp",
			},

			--- WARNING: if you change cwd then this is likely broken
			--- ill likely fix this in a later change
			---
			--- md_files is a list of files to look for and auto add based on the location
			--- of the originating request.  That means if you are at /foo/bar/baz.lua
			--- the system will automagically look for:
			--- /foo/bar/AGENT.md
			--- /foo/AGENT.md
			--- assuming that /foo is project root (based on cwd)
			md_files = {
				"AGENT.md",
			},
		})
	end,
}
