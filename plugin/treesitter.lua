-- nvim-treesitter
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

require("nvim-treesitter.configs").setup({
  ensure_installed = { "go", "python", "cpp", "lua", "json", "yaml" },
  sync_install = false,
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end
    pcall(vim.treesitter.language.add, lang)
    pcall(vim.treesitter.start, args.buf, lang)
  end,
})
