-- autochdir.nvim
vim.pack.add({ "https://github.com/albenisolmos/autochdir.nvim" })

require("autochdir").setup({
  generic_flags = { "README.md", ".git", ".gitignore", ".dockerignore" },
})
