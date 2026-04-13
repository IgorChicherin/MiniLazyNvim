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
  { src = "https://github.com/folke/tokyonight.nvim", version = vim.version.range("*") },
  { src = "https://github.com/folke/snacks.nvim", version = vim.version.range("*") },
  { src = "https://github.com/echasnovski/mini.nvim", version = vim.version.range("*") },
  { src = "https://github.com/folke/persistence.nvim", version = vim.version.range("*") },

  -- LSP
  { src = "https://github.com/neovim/nvim-lspconfig", version = vim.version.range("*") },
  { src = "https://github.com/williamboman/mason.nvim", version = vim.version.range("*") },
  { src = "https://github.com/williamboman/mason-lspconfig.nvim", version = vim.version.range("*") },
  { src = "https://github.com/jay-babu/mason-nvim-dap.nvim", version = vim.version.range("*") },
  { src = "https://github.com/stevearc/dressing.nvim", version = vim.version.range("*") },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
  { src = "https://github.com/j-hui/fidget.nvim", version = vim.version.range("*") },
  { src = "https://github.com/folke/lazydev.nvim", version = vim.version.range("*") },

  -- Completion
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  "https://github.com/rafamadriz/friendly-snippets",

  -- Treesitter
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = vim.version.range("*") },

  -- C/C++
  "https://github.com/p00f/clangd_extensions.nvim",
  "https://github.com/Civitasv/cmake-tools.nvim",

  -- DAP
  "https://github.com/mfussenegger/nvim-dap",
  { src = "https://github.com/nvim-neotest/nvim-nio", version = vim.version.range("*") },
  { src = "https://github.com/igorlfs/nvim-dap-view", version = vim.version.range("1.*") },
  "https://github.com/mfussenegger/nvim-dap-python",
  "https://github.com/leoluz/nvim-dap-go",
  "https://github.com/theHamsta/nvim-dap-virtual-text",

  -- Utils
  { src = "https://github.com/stevearc/conform.nvim", version = vim.version.range("*") },
  { src = "https://github.com/folke/flash.nvim", version = vim.version.range("*") },
  "https://github.com/wintermute-cell/gitignore.nvim",
  "https://github.com/albenisolmos/autochdir.nvim",
  "https://github.com/f-person/auto-dark-mode.nvim",
  "https://github.com/tpope/vim-sleuth",
  { src = "https://github.com/nvim-lua/plenary.nvim", version = vim.version.range("*") },
})

-- [[ Plugins that need immediate loading ]]
vim.cmd.colorscheme("tokyonight")

-- [[ Keymaps ]]
require("keymaps")
