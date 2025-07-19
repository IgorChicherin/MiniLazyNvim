--  pip install basedpyright
return {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { { "pyproject.toml", "setup.cfg", "setup.py" }, "requirements.txt",
    ".git", { ".venv", "venv" } },
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard",
        autoImportCompletions = true,
        autoSearchPaths = true,
      },
    },
  },
}
