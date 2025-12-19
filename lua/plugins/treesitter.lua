return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,

    init = function()
      -- Start Treesitter automatically when a buffer gets a filetype
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then
            return
          end

          -- Try to load parser (won't error if missing)
          pcall(vim.treesitter.language.add, lang)

          -- Start Treesitter highlighting
          pcall(vim.treesitter.start, args.buf, lang)
        end,
      })
    end,
  },
}
