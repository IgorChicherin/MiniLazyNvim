-- [[ Fast runtime path loading ]]
vim.loader.enable()

-- [[ Setting options ]]
require("options")

-- [[ Basic Autocommands ]]
require("autocommands")

-- [[ vim.pack - Plugin manager ]]
-- PackChanged hook for treesitter (must be registered BEFORE vim.pack.add)
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  -- UI / Base
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/folke/persistence.nvim",

  -- LSP
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/williamboman/mason-lspconfig.nvim",
  "https://github.com/jay-babu/mason-nvim-dap.nvim",
  "https://github.com/stevearc/dressing.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/j-hui/fidget.nvim",
  "https://github.com/folke/lazydev.nvim",

  -- Completion
  "https://github.com/saghen/blink.cmp",
  "https://github.com/rafamadriz/friendly-snippets",

  -- Treesitter
  "https://github.com/nvim-treesitter/nvim-treesitter",

  -- C/C++
  "https://github.com/p00f/clangd_extensions.nvim",
  "https://github.com/Civitasv/cmake-tools.nvim",

  -- DAP
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/igorlfs/nvim-dap-view",
  "https://github.com/mfussenegger/nvim-dap-python",
  "https://github.com/leoluz/nvim-dap-go",
  "https://github.com/theHamsta/nvim-dap-virtual-text",

  -- Utils
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/folke/flash.nvim",
  "https://github.com/wintermute-cell/gitignore.nvim",
  "https://github.com/albenisolmos/autochdir.nvim",
  "https://github.com/f-person/auto-dark-mode.nvim",
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/nvim-lua/plenary.nvim",
})

vim.cmd("packadd nvim.undotree")
require("vim._core.ui2").enable()

-- [[ Plugins that need immediate loading ]]
vim.cmd.colorscheme("tokyonight")

-- [[ Keymaps ]]
require("keymaps")
