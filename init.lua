-- [[ Fast runtime path loading ]]
vim.loader.enable()

-- [[ Options ]]
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.opt.swapfile = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

require("vim._core.ui2").enable({})

vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10

if vim.loop.os_uname().sysname == "Windows_NT" then
  vim.opt.shell = "powershell.exe"
  vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end

vim.diagnostic.config({ virtual_text = false, virtual_lines = { current_line = true }, jump = { on_jump = true } })

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ vim.pack - Plugin manager ]]
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
  "https://github.com/saghen/blink.lib",
  "https://github.com/rafamadriz/friendly-snippets",

  -- Treesitter
  "https://github.com/nvim-treesitter/nvim-treesitter",

  -- C/C++
  "https://github.com/p00f/clangd_extensions.nvim",
  "https://github.com/Civitasv/cmake-tools.nvim",

  -- DAP
  { src = "https://github.com/igorlfs/nvim-dap-view", version = vim.version.range("1.*") },
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/mfussenegger/nvim-dap-python",
  "https://github.com/leoluz/nvim-dap-go",
  "https://github.com/theHamsta/nvim-dap-virtual-text",

  -- Utils
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/folke/flash.nvim",
  "https://github.com/wintermute-cell/gitignore.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/albenisolmos/autochdir.nvim",
  "https://github.com/f-person/auto-dark-mode.nvim",
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/nvim-lua/plenary.nvim",
})

vim.cmd("packadd nvim.undotree")
vim.cmd.colorscheme("tokyonight")

-- [[ Plugin setup ]]
require("snacks").setup({
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
          icon = " ",
          key = "s",
          desc = "Restore Session",
          action = function()
            require("persistence").load()
          end,
        },
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
})

require("mini.basics").setup()
require("mini.move").setup()
require("mini.pairs").setup()
require("mini.splitjoin").setup()

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

require("mini.surround").setup({
  mappings = {
    add = "gsa",
    delete = "gsd",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
    replace = "gsr",
    update_n_lines = "gsn",
  },
})

local ai = require("mini.ai")
ai.setup({
  {
    n_lines = 500,
    custom_textobjects = {
      o = ai.gen_spec.treesitter({
        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
      }),
      f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
      c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
      t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
      d = { "%f[%d]%d+" },
      e = {
        { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
        "^().*()$",
      },
      u = ai.gen_spec.function_call(),
      U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
    },
  },
})

require("mini.pick").setup()
require("mini.git").setup()
require("mini.notify").setup({
  window = {
    config = {},
  },

  lsp_progress = {
    enable = false,
  },
})
require("mini.diff").setup()
require("mini.tabline").setup()
require("mini.icons").setup()
require("mini.fuzzy").setup()

local miniclue = require("mini.clue")
miniclue.setup({
  window = {
    config = { width = "auto" },
    delay = 99,
  },
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "i", keys = "<C-x>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },
  clues = {
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
    { mode = "n", keys = "<Leader>b", desc = "[b]uffers" },
    { mode = "n", keys = "<Leader>c", desc = "[c]ode" },
    { mode = "n", keys = "<Leader>d", desc = "[d]ebug" },
    { mode = "n", keys = "<Leader>g", desc = "[g]it" },
    { mode = "n", keys = "<Leader>q", desc = "[q]uit/session" },
    { mode = "n", keys = "<Leader>s", desc = "[s]earch" },
    { mode = "n", keys = "<Leader>sG", desc = "Search [G]it" },
    { mode = "n", keys = "<Leader>w", desc = "[w]indows" },
    { mode = "n", keys = "<Leader>e", desc = "[e]xplorer" },
    { mode = "n", keys = "<Leader><Leader>", desc = "[f]ind files" },
    { mode = "n", keys = "<Leader>sGl", desc = "Search [G]it Log" },
    { mode = "n", keys = "<Leader>sGs", desc = "Search [G]it Status" },
    { mode = "n", keys = "<Leader>u", desc = "[u]i" },
  },
})

local icons = require("mini.icons")
local statusline = require("mini.statusline")

statusline.section_location = function()
  return "%2l:%-2v"
end

statusline.section_filename = function()
  return "%f"
end

statusline.section_fileinfo = function()
  local filetype = vim.bo.filetype
  if filetype == "" then
    return ""
  end
  filetype = icons.get("filetype", filetype) .. " " .. filetype
  local bufname = vim.api.nvim_buf_get_name(0)
  local size = bufname ~= "" and vim.fn.getfsize(bufname) or -1
  local size_str
  if size < 0 then
    size_str = ""
  elseif size < 1024 then
    size_str = string.format("%dB", size)
  elseif size < 1048576 then
    size_str = string.format("%.2fKiB", size / 1024)
  else
    size_str = string.format("%.2fMiB", size / 1048576)
  end
  return size_str ~= "" and string.format("%s %s", filetype, size_str) or filetype
end

statusline.setup({ use_icons = vim.g.have_nerd_font })
require("mini.misc").setup({ make_global = { "put", "put_text" } })

require("persistence").setup({})

require("mason").setup({})
require("fidget").setup({})
require("dressing").setup({})
require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
  callback = function(event)
    local function map(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("<leader>cl", "<cmd>LspInfo<CR>", "LSP info")
    map("gd", function()
      require("snacks").picker.lsp_definitions()
    end, "Goto definition")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
    map("gr", function()
      require("snacks").picker.lsp_references()
    end, "Goto references")
    map("gI", function()
      require("snacks").picker.lsp_implementations()
    end, "Goto implementation")
    map("gy", function()
      require("snacks").picker.lsp_type_definitions()
    end, "Goto type definition")
    map("K", vim.lsp.buf.hover, "Hover")
    map("gx", vim.diagnostic.open_float, "Diagnostics")
    map("gK", vim.lsp.buf.signature_help, "Signature help")
    map("<c-k>", vim.lsp.buf.signature_help, "Signature help", "i")
    map("<leader>cs", function()
      require("snacks").picker.lsp_symbols()
    end, "Symbols")
    map("<leader>cR", function()
      require("snacks").rename.rename_file()
    end, "Rename file")
    map("<leader>cr", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x", "v" })
    map("]]", function()
      require("snacks").words.jump(vim.v.count1)
    end, "Next reference", { "n", "x", "v" })
    map("[[", function()
      require("snacks").words.jump(-vim.v.count1)
    end, "Prev reference", { "n", "x", "v" })
    map("a-n", function()
      require("snacks").words.lspjump(vim.v.count1, true)
    end, "Next reference", { "n", "x", "v" })
    map("a-p", function()
      require("snacks").words.jump(-vim.v.count1, true)
    end, "Prev reference", { "n", "x", "v" })

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
      local highlight_augroup = vim.api.nvim_create_augroup("user-lsp-highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("user-lsp-detach", { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "user-lsp-highlight", buffer = event2.buf })
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      map("<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "Toggle inlay [h]ints")
    end
  end,
})

if vim.g.have_nerd_font then
  local signs = { ERROR = " ", WARN = " ", INFO = " ", HINT = " " }
  local diagnostic_signs = {}
  for type, icon in pairs(signs) do
    diagnostic_signs[vim.diagnostic.severity[type]] = icon
  end
  vim.diagnostic.config({ signs = { text = diagnostic_signs } })
end

local function get_python()
  local venv = os.getenv("VIRTUAL_ENV")
  if venv then
    if vim.fn.has("win32") == 1 then
      return venv .. "\\Scripts\\python.exe"
    end
    return venv .. "/bin/python"
  end
  return vim.fn.has("win32") == 1 and "python" or "python3"
end

local servers = {
  gopls = {},
  ruff = {},
  basedpyright = {
    settings = {
      python = {
        pythonPath = get_python(),
      },
    },
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
      },
    },
  },
  clangd = {
    keys = {
      { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/[h]eader (C/C++)" },
    },
    root_dir = function(fname)
      return require("lspconfig.util").root_pattern(
        "Makefile",
        "configure.ac",
        "configure.in",
        "config.h.in",
        "meson.build",
        "meson_options.txt",
        "build.ninja"
      )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname) or require(
        "lspconfig.util"
      ).find_git_ancestor(fname)
    end,
    capabilities = {
      offsetEncoding = { "utf-16" },
    },
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
      "--fallback-style=llvm",
    },
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true,
    },
  },
}

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, { "stylua" })
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
require("mason-nvim-dap").setup({ ensure_installed = { "codelldb" }, automatic_setup = true })

require("mason-lspconfig").setup({
  handlers = {
    function(server_name)
      local server = servers[server_name] or {}
      require("lspconfig")[server_name].setup(server)
    end,
  },
})

require("blink.cmp").build():pwait()
require("blink.cmp").setup({
  keymap = { preset = "enter" },
  appearance = { nerd_font_variant = "mono" },
  completion = { documentation = { auto_show = false } },
  signature = { enabled = true },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})

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

require("clangd_extensions").setup({
  inlay_hints = { inline = false },
  ast = {
    role_icons = {
      type = "",
      declaration = "",
      expression = "",
      specifier = "",
      statement = "",
      ["template argument"] = "",
    },
    kind_icons = {
      Compound = "",
      Recovery = "",
      TranslationUnit = "",
      PackExpansion = "",
      TemplateTypeParm = "",
      TemplateTemplateParm = "",
      TemplateParamObject = "",
    },
  },
})

require("cmake-tools").setup({})

require("dap-view").setup({
  winbar = {
    sections = { "console", "watches", "scopes", "exceptions", "breakpoints", "threads", "repl" },
    show = true,
    default_section = "console",
    show_keymap_hints = true,
  },
  windows = {
    size = 15,
    position = "below",
    terminal = { hide = true },
  },
  virtual_text = { enabled = true },
  auto_toggle = true,
})

local dap = require("dap")
local dap_go = require("dap-go")
local dap_python = require("dap-python")
require("nvim-dap-virtual-text").setup({ commented = true })
dap_python.setup("python3")
dap_go.setup()

local install_root_dir = vim.fn.stdpath("data") .. "/mason"
local extension_path = install_root_dir .. "/packages/codelldb/extension/"
local codelldb_path = extension_path .. "adapter/codelldb"

if vim.loop.os_uname().sysname == "Windows_NT" then
  codelldb_path = codelldb_path .. ".exe"
end

if not dap.adapters.codelldb then
  dap.adapters.codelldb = {
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = {
      command = codelldb_path,
      args = { "--port", "${port}" },
    },
  }
end

for _, lang in ipairs({ "c", "cpp" }) do
  dap.configurations[lang] = {
    {
      type = "codelldb",
      request = "launch",
      name = "Launch file",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      port = 13000,
    },
    {
      type = "codelldb",
      request = "attach",
      name = "Attach to process",
      pid = function()
        return require("dap.utils").pick_process()
      end,
      cwd = "${workspaceFolder}",
      port = 13000,
    },
  }
end

require("conform").setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    local disable_filetypes = { c = true, cpp = true }
    local lsp_format_opt
    if disable_filetypes[vim.bo[bufnr].filetype] then
      lsp_format_opt = "never"
    else
      lsp_format_opt = "fallback"
    end
    return {
      timeout_ms = 500,
      lsp_format = lsp_format_opt,
    }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
  },
})

require("flash").setup({})
require("gitignore")
require("autochdir").setup({
  generic_flags = { "README.md", ".git", ".gitignore", ".dockerignore" },
})

require("auto-dark-mode").setup({
  update_interval = 1000,
  set_dark_mode = function()
    vim.api.nvim_set_option_value("background", "dark", {})
    require("tokyonight").load({ style = "moon" })
  end,
  set_light_mode = function()
    vim.api.nvim_set_option_value("background", "light", {})
    require("tokyonight").load({ style = "day" })
  end,
  fallback = "light",
})

-- [[ Keymaps ]]
local map = vim.keymap.set

local function snacks_picker()
  return require("snacks")
end

map("n", "<Esc>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end)
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "<leader>U", require("undotree").open, { desc = "[U]ndo tree" })
map("n", "<leader>x", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfi[x] list" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

map("n", "<leader>e", function()
  snacks_picker().explorer()
end, { desc = "Open file [e]xplorer" })

map("n", "<leader><leader>", function()
  snacks_picker().picker.files()
end, { desc = "Find file" })

map("n", "<leader>qq", "<cmd>silent! xa<cr><cmd>qa<cr>", { desc = "[q]uit All" })

map("n", "<leader>sf", function()
  snacks_picker().picker.files()
end, { desc = "Search [f]ile" })
map("n", "<leader>sp", function()
  snacks_picker().picker.projects()
end, { desc = "Search [p]roject" })
map("n", "<leader>sb", function()
  snacks_picker().picker.buffers()
end, { desc = "Search [b]uffer" })
map("n", "<leader>sg", function()
  snacks_picker().picker.grep()
end, { desc = "Search [g]rep" })
map("n", "<leader>sc", function()
  snacks_picker().picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Search [c]onfig file" })
map("n", "<leader>sh", function()
  snacks_picker().picker.command_history()
end, { desc = "Search command [h]istory" })
map("n", "<leader>sC", function()
  snacks_picker().picker.commands()
end, { desc = "Search [C]ommands" })
map("n", "<leader>sH", function()
  snacks_picker().picker.help()
end, { desc = "Search [H]elp" })
map("n", "<leader>sk", function()
  snacks_picker().picker.keymaps()
end, { desc = "Search [k]eymaps" })
map("n", "<leader>sm", function()
  snacks_picker().picker.marks()
end, { desc = "Search [m]arks" })
map("n", "<leader>sq", function()
  snacks_picker().picker.qflist()
end, { desc = "Search [q]uickfix" })
map("n", "<leader>sr", function()
  snacks_picker().picker.registers()
end, { desc = "Search [r]egisters" })
map("n", "<leader>uC", function()
  snacks_picker().picker.colorschemes()
end, { desc = "UI [C]olorschemes" })
map("n", "<leader>sGl", function()
  snacks_picker().picker.git_log()
end, { desc = "Search Git [l]og" })
map("n", "<leader>sGs", function()
  snacks_picker().picker.git_status()
end, { desc = "Search Git [s]tatus" })

map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other [b]uffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function()
  snacks_picker().bufdelete()
end, { desc = "[d]elete Buffer" })
map("n", "<leader>bo", function()
  snacks_picker().bufdelete.other()
end, { desc = "Delete [o]ther Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "[D]elete Buffer and Window" })

map("n", "<c-/>", function()
  snacks_picker().terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "Terminal (Root Dir)" })
map("n", "<c-_>", function()
  snacks_picker().terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "which_key_ignore" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

map("n", "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[f]ormat buffer" })

map("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Load [s]ession for current dir" })
map("n", "<leader>qS", function()
  require("persistence").select()
end, { desc = "Find [S]ession" })
map("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, { desc = "Load [l]ast session" })

map("n", "[e", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
end, { desc = "Go to previous ERROR" })
map("n", "]e", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
end, { desc = "Go to next ERROR" })
map("n", "[w", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARNING, wrap = true })
end, { desc = "Go to previous WARNING" })
map("n", "]w", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARNING, wrap = true })
end, { desc = "Go to next WARNING" })

vim.schedule(function()
  local toggle = snacks_picker().toggle
  toggle.option("spell", { name = "[s]pelling" }):map("<leader>us")
  toggle.option("wrap", { name = "[w]rap" }):map("<leader>uw")
  toggle.option("relativenumber", { name = "Relative [L]ine number" }):map("<leader>uL")
  toggle.diagnostics({ name = "[d]iagnostics" }):map("<leader>ud")
  toggle.line_number({ name = "[l]ine number" }):map("<leader>ul")
  toggle
    .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "[c]onceal Level" })
    :map("<leader>uc")
  toggle
    .option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "[t]abline" })
    :map("<leader>ut")
  toggle.treesitter({ name = "[T]reesitter Highlight" }):map("<leader>uT")
  toggle.option("background", { off = "light", on = "dark", name = "Dark [b]ackground" }):map("<leader>ub")
  toggle
    .new({
      id = "dim",
      name = "[D]im",
      get = function()
        return Snacks.dim.enabled
      end,
      set = function(state)
        if state then
          Snacks.dim.enable()
        else
          Snacks.dim.disable()
        end
      end,
    })
    :map("<leader>uD")
  toggle
    .new({
      id = "animate",
      name = "[a]nimate",
      get = function()
        return vim.g.snacks_animate ~= false
      end,
      set = function(state)
        vim.g.snacks_animate = state
      end,
    })
    :map("<leader>ua")
  toggle
    .new({
      id = "indent",
      name = "[i]ndent",
      get = function()
        return Snacks.indent.enabled
      end,
      set = function(state)
        if state then
          Snacks.indent.enable()
        else
          Snacks.indent.disable()
        end
      end,
    })
    :map("<leader>ui")
  toggle
    .new({
      id = "scroll",
      name = "[S]croll",
      get = function()
        return Snacks.scroll.enabled
      end,
      set = function(state)
        if state then
          Snacks.scroll.enable()
        else
          Snacks.scroll.disable()
        end
      end,
    })
    :map("<leader>uS")
  toggle.profiler():map("<leader>dpp")
  toggle.profiler_highlights():map("<leader>dph")
  toggle
    .new({
      id = "format_on_save",
      name = "[f]ormat on Save (global)",
      get = function()
        return not vim.g.disable_autoformat
      end,
      set = function(state)
        vim.g.disable_autoformat = not state
      end,
    })
    :map("<leader>uf")
  toggle
    .new({
      id = "format_on_save_buffer",
      name = "[F]ormat on Save (buffer)",
      get = function()
        return not vim.b.disable_autoformat
      end,
      set = function(state)
        vim.b.disable_autoformat = not state
      end,
    })
    :map("<leader>uF")
  toggle
    .new({
      id = "zoom",
      name = "[Z]oom",
      get = function()
        return Snacks.zen.win and Snacks.zen.win:valid() or false
      end,
      set = function(state)
        if state then
          Snacks.zen.zoom()
        elseif Snacks.zen.win then
          Snacks.zen.win:close()
        end
      end,
    })
    :map("<leader>uZ")
  toggle
    .new({
      id = "zen",
      name = "[z]en",
      get = function()
        return Snacks.zen.win and Snacks.zen.win:valid() or false
      end,
      set = function(state)
        if state then
          Snacks.zen()
        elseif Snacks.zen.win then
          Snacks.zen.win:close()
        end
      end,
    })
    :map("<leader>uz")
end)

map("n", "<leader>w", "<c-w>", { desc = "Windows", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "[d]elete Window", remap = true })

if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function()
    snacks_picker().lazygit({ cwd = vim.uv.cwd() })
  end, { desc = "Lazy[g]it (Root Dir)" })
  map("n", "<leader>gG", function()
    snacks_picker().lazygit()
  end, { desc = "Lazy[G]it (cwd)" })
  map("n", "<leader>gf", function()
    snacks_picker().picker.git_log_file()
  end, { desc = "Git Current [f]ile History" })
  map("n", "<leader>gl", function()
    snacks_picker().picker.git_log({ cwd = vim.uv.cwd() })
  end, { desc = "Git [l]og" })
  map("n", "<leader>gL", function()
    snacks_picker().picker.git_log()
  end, { desc = "Git [L]og (cwd)" })
end

local flash = require("flash")
map({ "n", "x", "o" }, "s", function()
  flash.jump()
end, { desc = "Flash" })
map({ "n", "o", "x" }, "S", function()
  flash.treesitter()
end, { desc = "Flash Treesitter" })
map("o", "r", function()
  flash.remote()
end, { desc = "Remote Flash" })
map({ "o", "x" }, "R", function()
  flash.treesitter_search()
end, { desc = "Treesitter Search" })
map("c", "<c-s>", function()
  flash.toggle()
end, { desc = "Toggle Flash Search" })

map("n", "<F5>", function()
  require("dap").continue()
end, { desc = "Run/Continue" })
map("n", "<F7>", function()
  require("dap").step_into()
end, { desc = "Step Into" })
map("n", "<F4>", function()
  require("dap").run_last()
end, { desc = "Run Last" })
map("n", "<F9>", function()
  require("dap").step_out()
end, { desc = "Step Out" })
map("n", "<F8>", function()
  require("dap").step_over()
end, { desc = "Step Over" })
map("n", "<F10>", function()
  require("dap").terminate()
end, { desc = "Terminate" })
map("n", "<leader>dv", function()
  require("dap-view").toggle()
end, { desc = "Toggle DAP [v]iew" })
map("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "Toggle [b]reakpoint" })
map("n", "<leader>dB", function()
  local condition = vim.fn.input("Breakpoint condition (optional): ")
  local hit_condition = vim.fn.input("Hit count (optional): ")
  condition = condition ~= "" and condition or nil
  hit_condition = hit_condition ~= "" and hit_condition or nil
  require("dap").toggle_breakpoint(condition, hit_condition)
end, { desc = "Advanced [B]reakpoint" })
