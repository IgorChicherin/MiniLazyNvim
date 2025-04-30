return {
  {
    "echasnovski/mini.nvim",
    version = false,
    init = function()
      require("mini.basics").setup()

      -- Typing enhacements
      require("mini.move").setup()
      require("mini.pairs").setup()
      require("mini.splitjoin").setup()
      require("mini.surround").setup({
        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          add = "gsa", -- Add surrounding in Normal and Visual modes
          delete = "gsd", -- Delete surrounding
          find = "gsf", -- Find surrounding (to the right)
          find_left = "gsF", -- Find surrounding (to the left)
          highlight = "gsh", -- Highlight surrounding
          replace = "gsr", -- Replace surrounding
          update_n_lines = "gsn", -- Update `n_lines`
        },
      })
      local ai = require("mini.ai")
      ai.setup({
        {
          n_lines = 500,
          custom_textobjects = {
            o = ai.gen_spec.treesitter({ -- code block
              a = { "@block.outer", "@conditional.outer", "@loop.outer" },
              i = { "@block.inner", "@conditional.inner", "@loop.inner" },
            }),
            f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
            c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
            t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
            d = { "%f[%d]%d+" }, -- digits
            e = { -- Word with case
              { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
              "^().*()$",
            },
            -- g = LazyVim.mini.ai_buffer, -- buffer
            u = ai.gen_spec.function_call(), -- u for "Usage"
            U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
          },
        },
      })

      -- UI enhacements
      require("mini.files").setup({ mappings = { synchronize = "<CR>" } })
      require("mini.pick").setup()
      require("mini.git").setup()
      require("mini.notify").setup()
      require("mini.diff").setup()
      require("mini.tabline").setup()
      require("mini.icons").setup()
      require("mini.fuzzy").setup()

      local miniclue = require("mini.clue")
      miniclue.setup({
        window = {
          config = { width = "auto" },
          delay = 99,
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
          { mode = "n", keys = "<Leader>b", desc = "[b]uffers" },
          { mode = "n", keys = "<Leader>c", desc = "[c]ode" },
          { mode = "n", keys = "<Leader>d", desc = "[d]edbug" },
          { mode = "n", keys = "<Leader>g", desc = "[g]it" },
          { mode = "n", keys = "<Leader>q", desc = "[q]uit/session" },
          { mode = "n", keys = "<Leader>u", desc = "[u]i" },
        },
      })

      local statusline = require("mini.statusline")
      local icons = require("mini.icons")

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
        filetype = icons.get("filetype", filetype) .. " " .. filetype

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

      statusline.setup({
        use_icons = vim.g.have_nerd_font,
      })

      require("mini.misc").setup({ make_global = { "put", "put_text" } })
    end,
  },
}
