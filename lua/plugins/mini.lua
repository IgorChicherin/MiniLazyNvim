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
      require("mini.diff").setup()
      require("mini.tabline").setup()
      require("mini.icons").setup()
      require("mini.fuzzy").setup()

      require("mini.misc").setup({ make_global = { "put", "put_text" } })
    end,
  },
  {
    "echasnovski/mini.clue",
    version = false,
    init = function()
      local miniclue = require("mini.clue")
      miniclue.setup({
        window = {
          config = { width = "auto" },
        },
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },

          -- Built-in completion
          { mode = "i", keys = "<C-x>" },

          -- `g` key
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },

          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },

          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },
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
    end,
  },
  {
    "echasnovski/mini.statusline",
    version = false,
    init = function()
      local statusline = require("mini.statusline")

      statusline.section_location = function()
        return "%2l:%-2v"
      end

      statusline.section_filename = function()
        return "%f"
      end

      statusline.section_fileinfo = function()
        local filetype = vim.bo.filetype

        -- Don't show anything if there is no filetype
        if filetype == "" then
          return ""
        end

        -- Add filetype icon
        filetype = _G.MiniIcons.get("filetype", filetype) .. " " .. filetype

        local size = vim.fn.getfsize(vim.fn.getreg("%"))
        if size < 1024 then
          size = string.format("%dB", size)
        elseif size < 1048576 then
          size = string.format("%.2fKiB", size / 1024)
        else
          size = string.format("%.2fMiB", size / 1048576)
        end

        return string.format("%s %s", filetype, size)
      end

      local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
      local git = statusline.section_git({ trunc_width = 40 })
      local lsp = statusline.section_lsp({ trunc_width = 75 })
      local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
      local filename = statusline.section_filename({ trunc_width = 75 })
      local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
      local location = statusline.section_location({ trunc_width = 75 })
      local search = statusline.section_searchcount({ trunc_width = 75 })

      local active_content = function()
        return statusline.combine_groups({
          { hl = mode_hl, strings = { mode } },
          { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics, lsp } },
          "%<", -- Mark general truncate point
          { hl = "MiniStatuslineFilename", strings = { filename } },
          "%=", -- End left alignment
          { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
          { hl = mode_hl, strings = { search, location } },
        })
      end
      statusline.setup({
        use_icons = vim.g.have_nerd_font,
        content = { active = active_content },
      })
    end,
  },
}
