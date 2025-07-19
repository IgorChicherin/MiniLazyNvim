--  pip install basedpyright
return {
  cmd = { "basedpyright" },
  filetypes = { "py" },
  root_markers = { "venv", ".venv", ".git" },
}
