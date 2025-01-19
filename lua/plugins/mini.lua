return {
	{ -- Collection of various small independent plugins/modules
		"echasnovski/mini.nvim",
		config = function()
			-- Basic configuration
			require("mini.basics").setup()
			require("mini.bracketed").setup()
			require("mini.sessions").setup()

			-- Text editing
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.align").setup()
			require("mini.move").setup()
			require("mini.pairs").setup()
			require("mini.completion").setup()
			require("mini.operators").setup()
			
			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			-- UI
			require("mini.statusline").setup()
			require("mini.tabline").setup()
			require("mini.icons").setup()
			require("mini.cursorword").setup()
			require("mini.animate").setup()
			require("mini.pick").setup()
			require("mini.fuzzy").setup()
			local miniclue = require('mini.clue')
			miniclue.setup({
					  triggers = {
					    -- Leader triggers
					    { mode = 'n', keys = '<Leader>' },
					    { mode = 'x', keys = '<Leader>' },

					    -- Built-in completion
					    { mode = 'i', keys = '<C-x>' },

					    -- `g` key
					    { mode = 'n', keys = 'g' },
					    { mode = 'x', keys = 'g' },

					    -- Marks
					    { mode = 'n', keys = "'" },
					    { mode = 'n', keys = '`' },
					    { mode = 'x', keys = "'" },
					    { mode = 'x', keys = '`' },

					    -- Registers
					    { mode = 'n', keys = '"' },
					    { mode = 'x', keys = '"' },
					    { mode = 'i', keys = '<C-r>' },
					    { mode = 'c', keys = '<C-r>' },

					    -- Window commands
					    { mode = 'n', keys = '<C-w>' },

					    -- `z` key
					    { mode = 'n', keys = 'z' },
					    { mode = 'x', keys = 'z' },
					  },

					  clues = {
					    -- Enhance this by adding descriptions for <Leader> mapping groups
					    miniclue.gen_clues.builtin_completion(),
					    miniclue.gen_clues.g(),
					    miniclue.gen_clues.marks(),
					    miniclue.gen_clues.registers(),
					    miniclue.gen_clues.windows(),
					    miniclue.gen_clues.z(),
					  },
					})
			require("mini.files").setup()


			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require("mini.statusline")
			-- set use_icons to true if you have a Nerd Font
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- ... and there is more!
			--  Check out: https://github.com/echasnovski/mini.nvim
		end,
	},
}
