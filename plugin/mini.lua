-- mini.nvim
vim.api.nvim_create_autocmd("User", {
  pattern = "PackChanged",
  callback = function(ev)
    if ev.data.spec.name == "mini.nvim" then
      vim.cmd.packadd("mini.nvim")
    end
  end,
})

vim.schedule(function()
  vim.pack.add({ "https://github.com/echasnovski/mini.nvim" })

  require("mini.basics").setup()

  -- Typing enhancements
  require("mini.move").setup()
  require("mini.pairs").setup()
  require("mini.splitjoin").setup()
  local hipatterns = require("mini.hipatterns")
  hipatterns.setup({
    highlighters = {
      fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
      hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
      todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
      note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
  require("mini.surround").setup({
    mappings = {
      add = "gsa",
      delete = "gsd",
      find = "gsf",
      find_left = "gsF",
      highlight = "gsh",
      replace = "gsr",
      update_n_lines = "gsn",
    },
  })
  local ai = require("mini.ai")
  ai.setup({
    {
      n_lines = 500,
      custom_textobjects = {
        o = ai.gen_spec.treesitter({
          a = { "@block.outer", "@conditional.outer", "@loop.outer" },
          i = { "@block.inner", "@conditional.inner", "@loop.inner" },
        }),
        f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
        t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
        d = { "%f[%d]%d+" },
        e = {
          { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
          "^().*()$",
        },
        u = ai.gen_spec.function_call(),
        U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
      },
    },
  })

  -- UI enhancements
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
      { mode = "n", keys = "<Leader>" },
      { mode = "x", keys = "<Leader>" },
      { mode = "i", keys = "<C-x>" },
      { mode = "n", keys = "g" },
      { mode = "x", keys = "g" },
      { mode = "n", keys = "'" },
      { mode = "n", keys = "`" },
      { mode = "x", keys = "'" },
      { mode = "x", keys = "`" },
      { mode = "n", keys = '"' },
      { mode = "x", keys = '"' },
      { mode = "i", keys = "<C-r>" },
      { mode = "c", keys = "<C-r>" },
      { mode = "n", keys = "<C-w>" },
      { mode = "n", keys = "z" },
      { mode = "x", keys = "z" },
    },
    clues = {
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
      { mode = "n", keys = "<Leader>b", desc = "[b]uffers" },
      { mode = "n", keys = "<Leader>c", desc = "[c]ode" },
      { mode = "n", keys = "<Leader>d", desc = "[d]ebug" },
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
    if filetype == "" then
      return ""
    end
    filetype = icons.get("filetype", filetype) .. " " .. filetype
    local bufname = vim.api.nvim_buf_get_name(0)
    local size = bufname ~= "" and vim.fn.getfsize(bufname) or -1
    local size_str
    if size < 0 then
      size_str = ""
    elseif size < 1024 then
      size_str = string.format("%dB", size)
    elseif size < 1048576 then
      size_str = string.format("%.2fKiB", size / 1024)
    else
      size_str = string.format("%.2fMiB", size / 1048576)
    end
    return size_str ~= "" and string.format("%s %s", filetype, size_str) or filetype
  end

  statusline.setup({
    use_icons = vim.g.have_nerd_font,
  })

  require("mini.misc").setup({ make_global = { "put", "put_text" } })
end)
