return {
  "f-person/auto-dark-mode.nvim",
  opts = {
    update_interval = 1000,
    set_dark_mode = function()
      vim.api.nvim_set_option_value("background", "dark", {})
      require("tokyonight").load({ style = "moon" })
    end,
    set_light_mode = function()
      vim.api.nvim_set_option_value("background", "light", {})
      require("tokyonight").load({ style = "day" })
    end,
    -- for gnome dection we need fallback
    fallback = "light",
  },
}
