return {
  {
    "echasnovski/mini.nvim",
    version = false,
    init = function()
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
