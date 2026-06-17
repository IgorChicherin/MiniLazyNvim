local languages = { "go", "python", "cpp", "lua", "json", "yaml" }

for _, lang in ipairs(languages) do
  vim.treesitter.language.add(lang)
end

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
