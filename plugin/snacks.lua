-- snacks.nvim
vim.api.nvim_create_autocmd("User", {
  pattern = "PackChanged",
  callback = function(ev)
    if ev.data.spec.name == "snacks.nvim" then
      vim.cmd.packadd("snacks.nvim")
    end
  end,
})

vim.schedule(function()
  vim.pack.add({ "https://github.com/folke/snacks.nvim" })

  ---@type snacks.config
  local opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[


███╗   ███╗ ██╗███╗   ██╗ ██╗
████╗ ████║███║████╗  ██║███║
██╔████╔██║╚██║██╔██╗ ██║╚██║
██║╚██╔╝██║ ██║██║╚██╗██║ ██║
██║ ╚═╝ ██║ ██║██║ ╚████║ ██║
╚═╝     ╚═╝ ╚═╝╚═╝  ╚═══╝ ╚═╝



        ]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header", padding = 2 },
        { section = "keys", gap = 1, padding = 1 },
        { section = "recent_files", icon = " ", title = "Recent Files", indent = 2, padding = 1, opts = { limit = 5 } },
      },
    },
    indent = { enabled = true },
    input = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    words = { enabled = true },
    terminal = { enabled = true },
    lazygit = { enabled = true },
    picker = { enabled = true },
  }

  require("snacks").setup(opts)
end)
