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
  "https://github.com/f-person/auto-dark-mode.nvim",
  "https://github.com/folke/flash.nvim",
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/chentoast/marks.nvim",
})

vim.cmd("packadd nvim.undotree")

-- 'background' follows the terminal (re-queried on theme change); tokyonight picks the style from it
require("tokyonight").setup({ style = "moon", light_style = "day" })
vim.cmd.colorscheme("tokyonight")

-- [[ Plugin setup ]]
-- Basic mappings off: they replace the built-in gO (LSP symbols); their <C-s> save is mapped under Keymaps.
-- Its basic autocommands (yank highlight, insert on TermOpen) stay on.
require("mini.basics").setup({ mappings = { basic = false, windows = true } })
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
  return "%t"
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

require("mason").setup({})

-- [[ Completion ]] mini.completion: LSP first, then buffer words; <C-Space> forces it, <M-Space> forces buffer words
-- noinsert: the first item is preselected (not inserted), so <CR> accepts it right away
vim.o.completeopt = "menuone,noinsert,popup,fuzzy"
vim.o.pumheight = 10
-- clangd fixes "ptr.Member" to "ptr->Member" with an edit that starts at the ".". Start the popup after the "."
-- instead (so the typed text still matches the items) and let mini.completion apply the edit as a snippet.
require("mini.completion").setup({
  lsp_completion = {
    process_items = function(items, base)
      for _, item in ipairs(items) do
        local edit = item.textEdit
        if edit and edit.newText and edit.newText:find("^[%.%-]") then
          item.insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet
          if not edit.newText:find("[^\\]%${?%w") then
            edit.newText = edit.newText:gsub("[%$}\\]", "\\%0") .. "$0"
          end
        end
      end
      return MiniCompletion.default_process_items(items, base)
    end,
  },
})
local completefunc_lsp = MiniCompletion.completefunc_lsp
MiniCompletion.completefunc_lsp = function(findstart, base)
  local start = completefunc_lsp(findstart, base)
  if findstart == 1 and type(start) == "number" and start >= 0 then
    local line = vim.api.nvim_get_current_line()
    local word_start = vim.fn.match(line:sub(1, vim.api.nvim_win_get_cursor(0)[2]), "\\k*$")
    if word_start > start and line:sub(start + 1, word_start):find("^[%.>%-]+$") then
      return word_start
    end
  end
  return start
end

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

-- Notifications and LSP progress in a corner window (replaces fidget)
require("mini.notify").setup()
vim.notify = MiniNotify.make_notify()

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

-- [[ Sessions ]] mini.sessions: one per working directory, saved on exit
vim.opt.sessionoptions = { "buffers", "curdir", "folds", "help", "tabpages", "winsize" }
local session_dir = vim.fn.stdpath("state") .. "/sessions"
vim.fn.mkdir(session_dir, "p")
require("mini.sessions").setup({ autowrite = false, directory = session_dir, file = "" })

-- the directory name, so two projects with the same folder name share a session
local function session_name()
  local name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  return name ~= "" and name or "root"
end

local function restore_session()
  if vim.uv.fs_stat(session_dir .. "/" .. session_name()) then
    MiniSessions.read(session_name())
  end
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  desc = "Save the session for the current directory",
  group = vim.api.nvim_create_augroup("user-session", { clear = true }),
  callback = function()
    local has_file = vim.iter(vim.fn.getbufinfo({ buflisted = 1 })):any(function(buf)
      return buf.name ~= "" and vim.bo[buf.bufnr].buftype == ""
    end)
    if has_file then
      MiniSessions.write(session_name(), { force = true, verbose = false })
    end
  end,
})

-- [[ Pickers ]] mini.pick (replaces the built-in :find/:buffer/:grep setup); files and grep use rg, fd or git
-- <CR> applies pending file system edits (default "=")
require("mini.files").setup({ mappings = { synchronize = "<CR>" } })
require("mini.pick").setup()
require("mini.extra").setup()
vim.ui.select = MiniPick.ui_select

-- Project root of the current buffer: the nearest parent with one of these
-- (mini.misc find_root, no auto cd), else the buffer's own directory, else the working directory
local root_markers = { "README.md", ".git", ".gitignore", ".dockerignore" }
local find_root = require("mini.misc").find_root
local function buf_root()
  return find_root(0, root_markers, vim.fs.dirname) or vim.fn.getcwd()
end

-- File picker; <M-h> / <M-i> toggle hidden / gitignored files while it is open
local files = { hidden = false, ignored = false, listing = nil, cwd = nil }

local function files_reload()
  local cmd = { "rg", "--files", "--color=never", "-g", "!.git" }
  if files.hidden then
    table.insert(cmd, "--hidden")
  end
  if files.ignored then
    table.insert(cmd, "--no-ignore")
  end
  local name = "Files (rg" .. (files.hidden and " +hidden" or "") .. (files.ignored and " +ignored" or "") .. ")"
  MiniPick.set_picker_opts({ source = { name = name } })
  -- stop the previous listing so a slow one cannot overwrite the new items
  if files.listing then
    pcall(files.listing.kill)
  end
  files.listing = MiniPick.set_picker_items_from_cli(cmd, { spawn_opts = { cwd = files.cwd } })
end

local function files_toggle_hidden()
  files.hidden = not files.hidden
  files_reload()
end

local function files_toggle_ignored()
  files.ignored = not files.ignored
  files_reload()
end

local function find_files()
  if vim.fn.executable("rg") == 0 then
    return MiniPick.builtin.files(nil, { source = { cwd = buf_root() } })
  end
  files.hidden, files.ignored, files.listing, files.cwd = false, false, nil, buf_root()
  MiniPick.builtin.files({ tool = "rg" }, {
    source = { cwd = files.cwd },
    mappings = {
      toggle_hidden = { char = "<M-h>", func = files_toggle_hidden },
      toggle_ignored = { char = "<M-i>", func = files_toggle_ignored },
    },
  })
end

local function grep_files()
  MiniPick.builtin.grep_live(nil, { source = { cwd = buf_root() } })
end

-- [[ Start page ]] mini.starter: press an item's first letter to run it
local starter = require("mini.starter")
starter.setup({
  evaluate_single = true,
  header = table.concat({
    "███╗   ███╗ ██╗███╗   ██╗ ██╗",
    "████╗ ████║███║████╗  ██║███║",
    "██╔████╔██║╚██║██╔██╗ ██║╚██║",
    "██║╚██╔╝██║ ██║██║╚██╗██║ ██║",
    "██║ ╚═╝ ██║ ██║██║ ╚████║ ██║",
    "╚═╝     ╚═╝ ╚═╝╚═╝  ╚═══╝ ╚═╝",
  }, "\n"),
  items = {
    { name = "Find file", action = find_files, section = "" },
    { name = "New file", action = "enew | startinsert", section = "" },
    { name = "Grep text", action = grep_files, section = "" },
    { name = "Recent files", action = "lua MiniExtra.pickers.oldfiles()", section = "" },
    {
      name = "Session restore",
      action = restore_session,
      section = "",
    },
    {
      name = "Config",
      action = function()
        MiniPick.builtin.files(nil, { source = { cwd = vim.fn.stdpath("config") } })
      end,
      section = "",
    },
    { name = "Quit", action = "qa", section = "" },
  },
  content_hooks = { starter.gen_hook.aligning("center", "center") },
  footer = "",
})

-- Command-line completion popup
vim.o.wildmode = "noselect:lastused,full"
vim.o.wildoptions = "pum,fuzzy"

-- [[ Keymaps ]]
local map = vim.keymap.set

-- Height of bottom splits (terminal, undo tree): 30% of the screen, recomputed on every open
local function bottom_height()
  return math.floor(vim.o.lines * 0.3)
end

-- Enter accepts the selected completion item, otherwise lets mini.pairs handle it;
-- Tab/S-Tab move through the completion menu, otherwise jump between snippet fields
local multistep = require("mini.keymap").map_multistep
multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
multistep("i", "<Tab>", { "pmenu_next", "vimsnippet_next" })
multistep("i", "<S-Tab>", { "pmenu_prev", "vimsnippet_prev" })

map("n", "<Esc>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
  vim.cmd.nohlsearch()
end)

map("n", "<leader>U", function()
  require("undotree").open({ command = "botright " .. bottom_height() .. "new" })
end, { desc = "[U]ndo tree" })

local marks = require("marks")
map("n", "dm", marks.delete, { desc = "Delete mark" })
map("n", "dm-", marks.delete_line, { desc = "Delete marks on line" })
map("n", "dm<space>", marks.delete_buf, { desc = "Delete marks in buffer" })
map("n", "<leader>x", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfi[x] list" })

-- terminals of programs that use <Esc> themselves (vim.b.raw_esc) keep it; leave those with <C-\><C-n>
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(args)
    if not vim.b[args.buf].raw_esc then
      vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = args.buf, desc = "Exit terminal mode" })
    end
  end,
})

map("n", "<C-w>c", "<cmd>tabclose<cr>", { desc = "Close tab" })

-- Run a program in its own tab, in the current buffer's project root;
-- the tab closes when the program exits successfully (unless opts.keep_open, or it failed: the output stays readable)
-- opts.raw_esc: pass <Esc><Esc> to the program instead of leaving terminal mode
local function tab_terminal(cmd, opts)
  opts = opts or {}
  local root = buf_root()
  vim.cmd.tabnew()
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buflisted = false
  -- keep this window on the program: H/L (:bprevious/:bnext) must not swap in the other tab's buffers
  vim.wo.winfixbuf = true
  vim.b[buf].raw_esc = opts.raw_esc
  vim.fn.jobstart(cmd, {
    term = true,
    cwd = root,
    on_exit = function(_, code)
      if opts.keep_open or code ~= 0 then
        return
      end
      vim.schedule(function()
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end)
    end,
  })
end

-- Any shell command in its own tab; the tab stays open after exit so the output can be read
map("n", "<leader>t", function()
  local cmd = vim.fn.input("Command: ", "", "shellcmd")
  if cmd ~= "" then
    tab_terminal(cmd, { keep_open = true })
  end
end, { desc = "Run command in [t]ab terminal" })

-- opens at the current file, or at the working directory for unnamed buffers
map("n", "<leader>e", function()
  local path = vim.api.nvim_buf_get_name(0)
  MiniFiles.open(vim.uv.fs_stat(path) and path or nil)
end, { desc = "Open file [e]xplorer" })

map("n", "<leader><leader>", find_files, { desc = "Find file" })

map("n", "<leader>qq", "<cmd>silent! xa<cr><cmd>qa<cr>", { desc = "[q]uit All" })

-- replaces insert-mode <C-s> signature help; it stays on <C-k>
map({ "n", "x", "s", "i" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Save file" })

map("n", "<leader>sf", find_files, { desc = "Search [f]ile" })
map("n", "<leader>sb", MiniPick.builtin.buffers, { desc = "Search [b]uffer" })
map("n", "<leader>sg", grep_files, { desc = "Search [g]rep" })
map("n", "<leader>sc", function()
  vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Search [c]onfig file" })
map("n", "<leader>sh", function()
  MiniExtra.pickers.history({ scope = ":" })
end, { desc = "Search command [h]istory" })
map("n", "<leader>sC", MiniExtra.pickers.commands, { desc = "Search [C]ommands" })
map("n", "<leader>sH", MiniPick.builtin.help, { desc = "Search [H]elp" })
map("n", "<leader>sk", MiniExtra.pickers.keymaps, { desc = "Search [k]eymaps" })
map("n", "<leader>sm", MiniExtra.pickers.marks, { desc = "Search [m]arks" })
map("n", "<leader>sq", function()
  MiniExtra.pickers.list({ scope = "quickfix" })
end, { desc = "Search [q]uickfix" })
map("n", "<leader>sr", MiniExtra.pickers.registers, { desc = "Search [r]egisters" })
map("n", "<leader>uC", MiniExtra.pickers.colorschemes, { desc = "UI [C]olorschemes" })
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

-- One terminal per project root in a bottom split, hidden and shown again with the same key
-- (like snacks.nvim's terminal with LazyVim's root): the shell starts in the current buffer's root
local term_bufs = {} -- root -> terminal buffer

local function toggle_terminal()
  -- inside a terminal window: hide it
  if vim.b.term_root then
    vim.api.nvim_win_close(0, false)
    return
  end
  local root = buf_root()
  local buf = term_bufs[root]
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    buf = nil
  end
  local open_win = buf and vim.fn.bufwinid(buf) or -1
  -- one bottom terminal at a time: hide the shown one (another project's, or this one to toggle)
  for _, b in pairs(term_bufs) do
    local win = vim.api.nvim_buf_is_valid(b) and vim.fn.bufwinid(b) or -1
    if win ~= -1 then
      vim.api.nvim_win_close(win, false)
    end
  end
  if open_win ~= -1 then
    return
  end

  vim.cmd("botright " .. bottom_height() .. "split")
  -- the split copies winfixbuf from a program tab; clear it to switch buffer, then lock the window on the
  -- terminal so H/L (:bprevious/:bnext) cannot swap other buffers in
  vim.wo.winfixbuf = false
  if buf then
    vim.api.nvim_win_set_buf(0, buf)
    vim.wo.winfixbuf = true
    vim.cmd.startinsert()
    return
  end
  -- unlisted: kept out of the tabline and :bnext/:bprevious
  buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.wo.winfixbuf = true
  vim.fn.jobstart({ vim.o.shell }, { term = true, cwd = root })
  vim.b[buf].term_root = root
  term_bufs[root] = buf
end
map({ "n", "t" }, "<c-/>", toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<c-_>", toggle_terminal, { desc = "Toggle Terminal" })

map("n", "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[f]ormat buffer" })

map("n", "<leader>qs", restore_session, { desc = "Load [s]ession for current dir" })
map("n", "<leader>qS", function()
  MiniSessions.select("read")
end, { desc = "Find [S]ession" })
map("n", "<leader>ql", function()
  MiniSessions.read()
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

if vim.fn.executable("claude") == 1 then
  map("n", "<leader>C", function()
    tab_terminal({ "claude" }, { raw_esc = true })
  end, { desc = "[C]laude code" })
end

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

-- [[ Auto dark mode ]]
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
