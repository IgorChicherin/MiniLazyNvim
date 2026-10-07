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

-- PowerShell as 'shell' on Windows (:h shell-powershell), pwsh if installed;
-- 'shellpipe' and UTF-8 output are needed for :grep / :make to fill the quickfix list
if vim.fn.has("win32") == 1 then
  local pwsh = vim.fn.executable("pwsh") == 1
  vim.o.shell = pwsh and "pwsh" or "powershell"
  vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
    .. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
    .. "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
    .. (pwsh and "$PSStyle.OutputRendering='PlainText';" or "")
  vim.o.shellpipe = "> %s 2>&1"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
  vim.o.shelltemp = false
  if pwsh then
    vim.env.__SuppressAnsiEscapeSequences = "1"
  end
end

vim.diagnostic.config({ virtual_text = false, virtual_lines = { current_line = true } })

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
  "https://github.com/echasnovski/mini.nvim",

  -- LSP
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/williamboman/mason.nvim",

  -- Treesitter
  "https://github.com/nvim-treesitter/nvim-treesitter",

  -- C/C++
  "https://github.com/Civitasv/cmake-tools.nvim",
  "https://github.com/nvim-lua/plenary.nvim", -- required by cmake-tools

  -- Utils
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/folke/flash.nvim",
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/chentoast/marks.nvim",
  "https://github.com/albenisolmos/autochdir.nvim",
})

vim.cmd("packadd nvim.undotree")

-- 'background' follows the terminal (re-queried on theme change); tokyonight picks the style from it
require("tokyonight").setup({ style = "moon", light_style = "day" })
vim.cmd.colorscheme("tokyonight")

-- [[ Plugin setup ]]
-- Basic mappings off: they replace the built-in gO (LSP symbols) and insert-mode <C-s> (signature help).
-- Its basic autocommands (yank highlight, insert on TermOpen) stay on.
require("mini.basics").setup({ mappings = { basic = false } })
require("mini.bufremove").setup()
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
  n_lines = 500,
  custom_textobjects = {
    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
    d = { "%f[%d]%d+" },
    e = {
      { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
      "^().*()$",
    },
    u = ai.gen_spec.function_call(),
    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
  },
})

require("mini.git").setup()
require("mini.diff").setup()
require("mini.tabline").setup()
require("mini.icons").setup()
require("marks").setup({ default_mappings = false })

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
    { mode = "n", keys = "<Leader>sGs", desc = "Search [G]it Status" },
    { mode = "n", keys = "<Leader>u", desc = "[u]i" },
  },
})

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
  filetype = MiniIcons.get("filetype", filetype) .. " " .. filetype
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

require("mason").setup({})

-- [[ Completion ]] built-in: LSP (omnifunc) first, then up to 5 words from the current buffer, as you type
vim.o.autocomplete = true
vim.o.complete = "o,.^5"
-- noinsert: the first item is preselected (not inserted), so <CR> accepts it right away
vim.o.completeopt = "menuone,noinsert,popup,fuzzy"
vim.o.pumheight = 10

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
  callback = function(event)
    local function map(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("<leader>cl", "<cmd>LspInfo<CR>", "LSP info")
    -- references are the built-in "grr"
    map("gd", vim.lsp.buf.definition, "Goto definition")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
    map("gI", vim.lsp.buf.implementation, "Goto implementation")
    map("gy", vim.lsp.buf.type_definition, "Goto type definition")
    map("<leader>cd", vim.diagnostic.open_float, "Line [d]iagnostics")
    map("gK", vim.lsp.buf.signature_help, "Signature help")
    map("<c-k>", vim.lsp.buf.signature_help, "Signature help", "i")
    map("<leader>cs", vim.lsp.buf.document_symbol, "Symbols")
    map("<leader>cr", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x", "v" })

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
      -- trigger characters (".", "->", ...) and snippet expansion on accept
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
      map("<C-Space>", vim.lsp.completion.get, "Trigger completion", "i")
    end
    if client and client.name == "clangd" then
      map("<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", "Switch Source/[h]eader (C/C++)")
    end
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      map("<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "Toggle inlay [h]ints")
    end
  end,
})

-- Show LSP progress via the built-in progress messages (replaces fidget)
vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("user-lsp-progress", { clear = true }),
  callback = function(ev)
    local value = ev.data.params.value
    vim.api.nvim_echo({ { value.message or "done" } }, false, {
      id = "lsp." .. ev.data.params.token,
      kind = "progress",
      source = "vim.lsp",
      title = value.title,
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percentage,
    })
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

-- Python for basedpyright: the project's .venv/ or venv/, else the activated venv, else the system python
local function get_python(root)
  local win = vim.fn.has("win32") == 1
  local bin = win and "/Scripts/python.exe" or "/bin/python"
  local venvs = { root .. "/.venv", root .. "/venv", os.getenv("VIRTUAL_ENV") }
  for i = 1, 3 do
    if venvs[i] and vim.uv.fs_stat(venvs[i] .. bin) then
      return venvs[i] .. bin
    end
  end
  return win and "python" or "python3"
end

-- Server defaults come from nvim-lspconfig; only overrides are listed here.
local servers = {
  gopls = {},
  ruff = {
    -- a project's own ruff config wins; without one, only ruff's classic core rules
    -- (newer ruff enables 400+ rules by default and assumes a modern Python target)
    init_options = {
      settings = {
        configurationPreference = "filesystemFirst",
        lint = { select = { "E4", "E7", "E9", "F" } },
      },
    },
  },
  basedpyright = {
    -- per project: each root gets its own client, so its own venv
    before_init = function(_, config)
      config.settings.python = { pythonPath = get_python(config.root_dir or vim.fn.getcwd()) }
    end,
    settings = {
      basedpyright = {
        -- "off": no type-correctness checks; syntax errors and go-to/hover/completion still work.
        -- Unresolved imports stay on (they also reveal a wrong venv).
        -- A project's pyrightconfig.json or [tool.basedpyright] can turn checking back on.
        analysis = {
          diagnosticMode = "workspace",
          typeCheckingMode = "off",
          diagnosticSeverityOverrides = { reportMissingImports = "error" },
        },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        -- Neovim API and libuv types (replaces lazydev)
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            "${3rd}/luv/library",
          },
        },
        completion = {
          callSnippet = "Replace",
        },
      },
    },
  },
  clangd = {
    -- nested lists are tried in order of priority
    root_markers = {
      { "Makefile", "configure.ac", "configure.in", "config.h.in", "meson.build", "meson_options.txt", "build.ninja" },
      { "compile_commands.json", "compile_flags.txt" },
      ".git",
    },
    -- background index, clang-tidy, iwyu header insertion and arg placeholders are clangd defaults
    cmd = { "clangd", "--completion-style=detailed" },
  },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
end
vim.lsp.enable(vim.tbl_keys(servers))

-- Mason package names (differ from LSP config names for some servers)
local mason_packages = {
  "gopls",
  "ruff",
  "basedpyright",
  "lua-language-server",
  "clangd",
  "stylua",
}
local registry = require("mason-registry")
registry.refresh(function()
  for _, name in ipairs(mason_packages) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and not pkg:is_installed() then
      pkg:install()
    end
  end
end)

-- Installing parsers needs the tree-sitter CLI; already installed parsers are skipped
if vim.fn.executable("tree-sitter") == 1 then
  require("nvim-treesitter").install({ "c", "cpp", "go", "python", "lua", "json", "yaml" })
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

require("cmake-tools").setup({})

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

require("autochdir").setup({
  generic_flags = { "README.md", ".git", ".gitignore", ".dockerignore" },
})

-- [[ Sessions ]] one per working directory, saved on exit (replaces persistence.nvim)
vim.opt.sessionoptions = { "buffers", "curdir", "folds", "help", "tabpages", "winsize" }
local session_dir = vim.fn.stdpath("state") .. "/sessions/"
vim.fn.mkdir(session_dir, "p")

local function session_file()
  return session_dir .. vim.fn.getcwd():gsub("[\\/:]", "%%") .. ".vim"
end

local function load_session(file)
  if file and vim.uv.fs_stat(file) then
    vim.cmd.source(vim.fn.fnameescape(file))
  end
end

local function list_sessions()
  local files = vim.fn.glob(session_dir .. "*.vim", false, true)
  table.sort(files, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)
  return files
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  desc = "Save the session for the current directory",
  group = vim.api.nvim_create_augroup("user-session", { clear = true }),
  callback = function()
    local has_file = vim.iter(vim.fn.getbufinfo({ buflisted = 1 })):any(function(buf)
      return buf.name ~= "" and vim.bo[buf.bufnr].buftype == ""
    end)
    if has_file then
      vim.cmd.mksession({ vim.fn.fnameescape(session_file()), bang = true })
    end
  end,
})

-- [[ Find / grep ]] built-in :find, :buffer and :grep (replaces the snacks picker)
-- fd is installed as "fdfind" on Debian/Ubuntu
local fd = vim.fn.executable("fd") == 1 and "fd" or vim.fn.executable("fdfind") == 1 and "fdfind" or nil
if fd then
  local files
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    desc = "Refresh the :find file list once per command line",
    group = vim.api.nvim_create_augroup("user-find-files", { clear = true }),
    callback = function()
      files = nil
    end,
  })
  function _G.FindFiles(arg)
    files = files or vim.fn.systemlist({ fd, "--type", "f", "--hidden", "--exclude", ".git" })
    return arg == "" and files or vim.fn.matchfuzzy(files, arg)
  end
  vim.o.findfunc = "v:lua.FindFiles"
else
  -- without fd, :find searches subdirectories through 'path'
  vim.opt.path:append("**")
end

if vim.fn.executable("rg") == 1 then
  vim.o.grepprg = "rg --vimgrep --smart-case --hidden --glob=!.git"
end

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  desc = "Open the quickfix list after :grep",
  group = vim.api.nvim_create_augroup("user-grep", { clear = true }),
  pattern = "grep",
  command = "cwindow",
})

-- Completion popup as you type :find, :buffer, :help and :colorscheme arguments
vim.o.wildmode = "noselect:lastused,full"
vim.o.wildoptions = "pum,fuzzy"
-- (and command names too, when the command line was opened with <leader>sC)
local live_complete =
  { find = true, fin = true, b = true, buffer = true, h = true, help = true, colo = true, colorscheme = true }
local complete_commands = false
local cmdline_group = vim.api.nvim_create_augroup("user-cmdline-complete", { clear = true })
vim.api.nvim_create_autocmd("CmdlineChanged", {
  group = cmdline_group,
  pattern = ":",
  callback = function()
    if complete_commands or live_complete[vim.fn.getcmdline():match("^(%a+)%s")] then
      vim.fn.wildtrigger()
    end
  end,
})
vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = cmdline_group,
  callback = function()
    complete_commands = false
  end,
})
local function search_commands()
  complete_commands = true
  vim.api.nvim_feedkeys(":", "n", false)
end

-- [[ Keymaps ]]
local map = vim.keymap.set

-- Enter accepts the selected completion item, otherwise lets mini.pairs handle it
map("i", "<CR>", function()
  if vim.fn.complete_info({ "selected" }).selected ~= -1 then
    return "\25" -- <C-y>
  end
  return MiniPairs.cr()
end, { expr = true, replace_keycodes = false, desc = "Accept completion / newline" })

-- Tab/S-Tab move through the completion menu, otherwise jump between snippet fields
map("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif vim.snippet.active({ direction = 1 }) then
    return "<Cmd>lua vim.snippet.jump(1)<CR>"
  end
  return "<Tab>"
end, { expr = true, desc = "Next completion / snippet field" })
map("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  elseif vim.snippet.active({ direction = -1 }) then
    return "<Cmd>lua vim.snippet.jump(-1)<CR>"
  end
  return "<S-Tab>"
end, { expr = true, desc = "Prev completion / snippet field" })

map("n", "<Esc>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
  vim.cmd.nohlsearch()
end)

map("n", "<leader>U", require("undotree").open, { desc = "[U]ndo tree" })

local marks = require("marks")
map("n", "dm", marks.delete, { desc = "Delete mark" })
map("n", "dm-", marks.delete_line, { desc = "Delete marks on line" })
map("n", "dm<space>", marks.delete_buf, { desc = "Delete marks in buffer" })
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

-- Run a program in its own tab; the tab closes when the program exits (unless keep_open)
local function tab_terminal(cmd, keep_open)
  vim.cmd.tabnew()
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buflisted = false
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      if keep_open then
        return
      end
      vim.schedule(function()
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end)
    end,
  })
  vim.cmd.startinsert()
end

-- Any shell command in its own tab; the tab stays open after exit so the output can be read
map("n", "<leader>t", function()
  local cmd = vim.fn.input("Command: ", "", "shellcmd")
  if cmd ~= "" then
    tab_terminal(cmd, true)
  end
end, { desc = "Run command in [t]ab terminal" })

map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "Open file [e]xplorer" })

map("n", "<leader><leader>", ":find ", { desc = "Find file" })

map("n", "<leader>qq", "<cmd>silent! xa<cr><cmd>qa<cr>", { desc = "[q]uit All" })

map("n", "<leader>sf", ":find ", { desc = "Search [f]ile" })
map("n", "<leader>sb", ":buffer ", { desc = "Search [b]uffer" })
map("n", "<leader>sg", ":silent grep! ", { desc = "Search [g]rep" })
map("n", "<leader>sc", function()
  vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Search [c]onfig file" })
map("n", "<leader>sh", "q:", { desc = "Search command [h]istory" })
map("n", "<leader>sC", search_commands, { desc = "Search [C]ommands" })
map("n", "<leader>sH", ":help ", { desc = "Search [H]elp" })
map("n", "<leader>sk", "<cmd>map<cr>", { desc = "Search [k]eymaps" })
map("n", "<leader>sm", "<cmd>marks<cr>", { desc = "Search [m]arks" })
map("n", "<leader>sq", "<cmd>copen<cr>", { desc = "Search [q]uickfix" })
map("n", "<leader>sr", "<cmd>registers<cr>", { desc = "Search [r]egisters" })
map("n", "<leader>uC", ":colorscheme ", { desc = "UI [C]olorschemes" })
map("n", "<leader>sGs", "<cmd>Git status<cr>", { desc = "Search Git [s]tatus" })

map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other [b]uffer" })
map("n", "<leader>bd", function()
  MiniBufremove.delete()
end, { desc = "[d]elete Buffer" })
map("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted then
      MiniBufremove.delete(buf)
    end
  end
end, { desc = "Delete [o]ther Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "[D]elete Buffer and Window" })

-- One terminal in a bottom split, hidden and shown again with the same key
local term_buf
local function toggle_terminal()
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    local win = vim.fn.bufwinid(term_buf)
    if win ~= -1 then
      vim.api.nvim_win_close(win, false)
      return
    end
    vim.cmd("botright 15split")
    vim.api.nvim_win_set_buf(0, term_buf)
    vim.cmd.startinsert()
  else
    vim.cmd("botright 15split | terminal")
    term_buf = vim.api.nvim_get_current_buf()
    -- keep it out of the tabline and :bnext/:bprevious
    vim.bo[term_buf].buflisted = false
  end
end
map({ "n", "t" }, "<c-/>", toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<c-_>", toggle_terminal, { desc = "Toggle Terminal" })

map("n", "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[f]ormat buffer" })

map("n", "<leader>qs", function()
  load_session(session_file())
end, { desc = "Load [s]ession for current dir" })
map("n", "<leader>qS", function()
  vim.ui.select(list_sessions(), {
    prompt = "Session",
    format_item = function(file)
      return (vim.fn.fnamemodify(file, ":t:r"):gsub("%%", "/"))
    end,
  }, load_session)
end, { desc = "Find [S]ession" })
map("n", "<leader>ql", function()
  load_session(list_sessions()[1])
end, { desc = "Load [l]ast session" })

map("n", "[e", function()
  vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to previous ERROR" })
map("n", "]e", function()
  vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to next ERROR" })
map("n", "[w", function()
  vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.WARN })
end, { desc = "Go to previous WARNING" })
map("n", "]w", function()
  vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.WARN })
end, { desc = "Go to next WARNING" })

local function toggle(lhs, name, get, set)
  map("n", lhs, function()
    set(not get())
    vim.notify(name:gsub("[%[%]]", "") .. (get() and " on" or " off"))
  end, { desc = "Toggle " .. name })
end

local function toggle_option(lhs, option, name, off, on)
  if off == nil then
    off, on = false, true
  end
  toggle(lhs, name, function()
    return vim.o[option] ~= off
  end, function(state)
    vim.o[option] = state and on or off
  end)
end

toggle_option("<leader>us", "spell", "[s]pelling")
toggle_option("<leader>uw", "wrap", "[w]rap")
toggle_option("<leader>uL", "relativenumber", "Relative [L]ine number")
toggle_option("<leader>uc", "conceallevel", "[c]onceal Level", 0, 2)
toggle_option("<leader>ut", "showtabline", "[t]abline", 0, 2)
toggle_option("<leader>ub", "background", "Dark [b]ackground", "light", "dark")
toggle("<leader>ud", "[d]iagnostics", vim.diagnostic.is_enabled, vim.diagnostic.enable)
toggle("<leader>ul", "[l]ine number", function()
  return vim.o.number or vim.o.relativenumber
end, function(state)
  vim.o.number, vim.o.relativenumber = state, state
end)
toggle("<leader>uT", "[T]reesitter Highlight", function()
  return vim.b.ts_highlight == true
end, function(state)
  if state then
    vim.treesitter.start()
  else
    vim.treesitter.stop()
  end
end)
toggle("<leader>uf", "[f]ormat on Save (global)", function()
  return not vim.g.disable_autoformat
end, function(state)
  vim.g.disable_autoformat = not state
end)
toggle("<leader>uF", "[F]ormat on Save (buffer)", function()
  return not vim.b.disable_autoformat
end, function(state)
  vim.b.disable_autoformat = not state
end)

map("n", "<leader>w", "<c-w>", { desc = "Windows", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "[d]elete Window", remap = true })

if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function()
    tab_terminal({ "lazygit" })
  end, { desc = "Lazy[g]it" })
end
if vim.fn.executable("lazysql") == 1 then
  map("n", "<leader>D", function()
    tab_terminal({ "lazysql" })
  end, { desc = "Lazysql [D]atabase" })
end
map("n", "<leader>gf", function()
  vim.cmd("Git log --oneline -- " .. vim.fn.fnameescape(vim.fn.expand("%")))
end, { desc = "Git Current [f]ile History" })
map("n", "<leader>gl", "<cmd>Git log --oneline<cr>", { desc = "Git [l]og" })

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

-- [[ Debugging ]] tdb (pip install textual-debugger): TUI debugger over DAP for Python, Go and C/C++
map("n", "<leader>dd", function()
  if vim.fn.executable("tdb") ~= 1 then
    vim.notify("tdb not found: pip install textual-debugger", vim.log.levels.ERROR)
    return
  end
  local cmd = { "tdb" }
  if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
    local program = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    if program == "" then
      return
    end
    table.insert(cmd, program)
  else
    table.insert(cmd, vim.fn.expand("%:p"))
  end
  tab_terminal(cmd)
end, { desc = "[d]ebug current file with tdb" })
