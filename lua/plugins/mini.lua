return {
  {
    "echasnovski/mini.nvim",
    version = false,
    init = function()
      local miniclue = require("mini.clue")
      require("mini.basics").setup()

      -- Typing enhacements
      require("mini.bracketed").setup()
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.move").setup()
      require("mini.pairs").setup()
      require("mini.splitjoin").setup()
      require("mini.surround").setup()

      -- UI enhacements
      require("mini.files").setup({ mappings = { synchronize = "<CR>" } })
      require("mini.pick").setup()
      require("mini.git").setup()
      require("mini.notify").setup()
      require("mini.diff").setup()

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
      require("mini.statusline").setup({
        init = function()
          ---@diagnostic disable-next-line: duplicate-set-field
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
        end,
      })
      require("mini.tabline").setup()
      require("mini.icons").setup()
      require("mini.fuzzy").setup()
    end,
  },
}
