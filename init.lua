-- [[ Setting options ]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
-- vim.opt.list = true
-- vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

if vim.loop.os_uname().sysname == "Windows_NT" then
  vim.o.shell = "powershell"
end

vim.diagnostic.config({ jump = { float = true } })

-- Restrict omnifunc variants by disabling extra sources (buffer/path)
vim.opt.complete = ".,w,b,u,t" -- .: current buffer, w: buffers in window, b: open buffers, u: unloaded buffers, t: tags
vim.opt.pumheight = 10

-- [[ Setting options ]]


-- [[ Autocommands ]]
-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
-- [[ Autocommands ]]

-- [[ LSP ]]
--------------------------------------------------------------------------------
-- See https://gpanders.com/blog/whats-new-in-neovim-0-11/ for a nice overview
-- of how the lsp setup works in neovim 0.11+.

-- This actually just enables the lsp servers.
-- The configuration is found in the lsp folder inside the nvim config folder,
-- so in ~.config/lsp/lua_ls.lua for lua_ls, for example.

-- Treesitter
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter" }, }, { confirm = false })

require('nvim-treesitter.config').setup({
  ensure_installed = { "lua", "vim", "vimdoc", "python", "go", "c", "cpp" },
  auto_install = true,      -- This enables auto-compilation on file open
  indent = { enable = true },
})

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

-- Mason
vim.pack.add({
	{ src = "https://github.com/mason-org/mason.nvim.git" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim.git" },
	{ src = "https://github.com/neovim/nvim-lspconfig.git" },
}, { confirm = false })
require("mason").setup()
require("mason-lspconfig").setup({ ensure_installed = { "lua_ls", "basedpyright", "gopls", "clangd" }, })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method("textDocument/completion") then
			vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end

		-- Change diagnostic symbols in the sign column (gutter)
		if vim.g.have_nerd_font then
			local signs = { ERROR = " ", WARN = " ", INFO = " ", HINT = " " }
			local diagnostic_signs = {}
			for type, icon in pairs(signs) do
				diagnostic_signs[vim.diagnostic.severity[type]] = icon
			end
			vim.diagnostic.config({ signs = { text = diagnostic_signs } })
		end
	end,
})

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

local on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true }
	local map = vim.keymap.set
	vim.keymap.set("n", "<leader>ca", function()
		vim.lsp.buf.code_action({
			filter = function(action)
				return not action.disabled
			end,
		})
	end, opts)
	map("n", "gd", function() vim.lsp.buf.definition() end, opts)
	map("n", "K", function() vim.lsp.buf.hover() end, opts)
	map("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
	map("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
	map("n", "[d", function() vim.diagnostic.goto_next() end, opts)
	map("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
	map("n", "<leader>vr", function() vim.lsp.buf.references() end, opts)
	map("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
	map("i", "<C-k>", function() vim.lsp.buf.signature_help() end, opts)
	map("n", "<leader>lf", vim.lsp.buf.format, opts)
end

vim.lsp.config("lua_ls", { on_attach = on_attach })
vim.lsp.config("basedpyright", {
	on_attach = on_attach,
	root_dir = require("lspconfig.util").root_pattern(".git", "setup.py", "pyproject.toml", "requirements.txt"),
	settings = {
		python = {
			pythonPath = get_python(),
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				typeCheckingMode = 'basic'
			},
		},
	},
})
vim.lsp.config("gopls", { on_attach = on_attach })

-- Diagnostics
vim.diagnostic.config()

-- [[ LSP ]]

-- [[ Basic Keymaps ]]
local map = vim.keymap.set

map("n", "<Esc>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end)

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Buffers 
map("n", "<leader>bd", function() vim.api.nvim_buf_delete(0, {}) end, { desc = "Buffer delete" })

-- Diagnostic keymaps
map("n", "<leader>x", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Terminal
local function get_terminal_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'terminal' then
      return buf
    end
  end
  return nil
end

local function toggle_terminal()
  local term_buf = get_terminal_buffer()

  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    local found_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == term_buf then
        found_win = win
        break
      end
    end

    if found_win then
      vim.api.nvim_win_close(found_win, false)
    else
      vim.cmd('sb ' .. term_buf)
      vim.cmd('startinsert')
    end
  else
    vim.cmd('sp | term')
  end
end

-- Yank
map('v', '<C-c>', '"+y')

map("n", "<leader>t", toggle_terminal, { desc = "Toggle Terminal" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })


-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Files
map("n", "<leader>e", function()
  local netrw_open = false

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == "netrw" then
      netrw_open = true
      vim.api.nvim_buf_delete(0, {})
    end
  end

  if not netrw_open then
    vim.cmd("Ex")
  end
end, { desc = "Open file explorer" })
map("n", "<leader><leader>", "<cmd>Pick files<CR>", { desc = "Find file" })

-- Search
-- map('n', '<leader>sg', builtin.live_grep, {})

-- Quit
map("n", "<leader>qq", "<cmd>silent! xa<cr><cmd>qa<cr>", { desc = "Quit All" })

-- Mason
map("n", "<leader>cm", "<cmd>:Mason<CR>", { desc = "Mason" })

-- Flash
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash"})
map({ "n", "x", "o" }, "S", function() require("flash").treesitter() end , { desc = "Flash Treesitter" } )
map("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" } )
map({ "x", "o" }, "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" } )
map("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle Flash Search" })

-- LazyGit
local function floating_lazygit()
  -- Calculate floating window size and position
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create floating window config
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
    style = "minimal",
  }

  -- Create the buffer first
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Create the floating window with that buffer
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- IMPORTANT: Set terminal command BEFORE entering insert mode
  vim.api.nvim_buf_call(buf, function()
    vim.cmd('terminal lazygit')
  end)
  
  -- Auto-enter terminal mode
  vim.cmd('startinsert')
end

if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", floating_lazygit, { desc = "Lazygit (Root Dir)" })
end

-- Sessions
-- load the session for the current directory
map("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Load session for current dir" })

-- select a session to load
map("n", "<leader>qS", function()
  require("persistence").select()
end, { desc = "Find session" })

-- load the last session
map("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, { desc = "Load last session" })

-- map("n", "[e", function()
--   vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
-- end, { desc = "Go to previous diagnostics ERROR" })
-- map("n", "]e", function()
--   vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
-- end, { desc = "Go to next diagnostics ERROR" })
--
-- map("n", "[w", function()
--   vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARNING, wrap = true })
-- end, { desc = "Go to previous diagnostics WARNING" })
-- map("n", "]w", function()
--   vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARNING, wrap = true })
-- end, { desc = "Go to next diagnostics WARNING" })

-- [[ Basic Keymaps ]]
--
-- [[ Plugins ]]

-- Mini.nvim
vim.pack.add({ { src =  "https://github.com/nvim-mini/mini.nvim.git" } }, { confirm = false })
require("mini.move").setup()
require("mini.pairs").setup()
require("mini.pick").setup()
require("mini.surround").setup({
-- Module mappings. Use `''` (empty string) to disable one.
mappings = {
  add = "gsa", -- Add surrounding in Normal and Visual modes
  delete = "gsd", -- Delete surrounding
  find = "gsf", -- Find surrounding (to the right)
  find_left = "gsF", -- Find surrounding (to the left)
  highlight = "gsh", -- Highlight surrounding
  replace = "gsr", -- Replace surrounding
  update_n_lines = "gsn", -- Update `n_lines`
},
})
local ai = require("mini.ai")
ai.setup({
{
  n_lines = 500,
  custom_textobjects = {
    o = ai.gen_spec.treesitter({ -- code block
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    }),
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
    d = { "%f[%d]%d+" }, -- digits
    e = { -- Word with case
      { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
      "^().*()$",
    },
    -- g = LazyVim.mini.ai_buffer, -- buffer
    u = ai.gen_spec.function_call(), -- u for "Usage"
    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
  },
},
})
-- Mini.nvim

-- Auto dark mode
vim.pack.add({ { src =  "https://github.com/f-person/auto-dark-mode.nvim.git" } }, { confirm = false })
require("auto-dark-mode").setup({})
-- Auto dark mode

-- Flash.nvim
vim.pack.add({ { src ="https://github.com/folke/flash.nvim.git", } }, { confirm = false })
require("flash").setup({})
-- Flash.nvim

-- Blink.cmp
vim.pack.add({ { src = "https://github.com/saghen/blink.cmp.git" } }, { confirm = false })
require("blink.cmp").setup({
	keymap = { preset = "enter" },

    appearance = { nerd_font_variant = "mono" },

    completion = { documentation = { auto_show = false } },
    signature = { enabled = true },

    sources = { default = { "lsp", "path", "snippets", "buffer" } },

    fuzzy = { implementation = "prefer_rust_with_warning" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  opts_extend = { "sources.default" },
})
-- Blink.cmp 

-- [[ Plugins ]]
