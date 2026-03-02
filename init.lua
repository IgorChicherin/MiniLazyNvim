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

-- Disable wrap
vim.opt.wrap = false

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
vim.opt.timeout = true
vim.opt.timeoutlen = 800

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

-- [[ Utils ]]
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
	map("n", "gd", vim.lsp.buf.definition, opts)
	map("n", "K", vim.lsp.buf.hover, opts)
	map("n", "<leader>cs", vim.lsp.buf.workspace_symbol, opts)
	map("n", "<leader>vd", vim.diagnostic.open_float, opts)
	map("n", "[d", vim.diagnostic.goto_next, opts)
	map("n", "]d", vim.diagnostic.goto_prev, opts)
	map("n", "<leader>gr", vim.lsp.buf.references, opts)
	map("n", "<leader>cr", vim.lsp.buf.rename, opts)
	map("i", "<C-k>", vim.lsp.buf.signature_help, opts)
	map("n", "<leader>lf", vim.lsp.buf.format, opts)

	-- The following code creates a keymap to toggle inlay hints in your
	-- code, if the language server you are using supports them
	--
	-- This may be unwanted, since they displace some of your code
	if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
		map("n", "<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
		end, opts)
	end
end

local function get_terminal_buffer()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_get_option_value("buftype", { buf = buf }) == "terminal" then
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
			vim.cmd("sb " .. term_buf)
			vim.cmd("startinsert")
		end
	else
		vim.cmd("sp | term")
	end
end

local function toggle_lazygit()
	-- If window exists → close it
	if lazygit_win and vim.api.nvim_win_is_valid(lazygit_win) then
		vim.api.nvim_win_close(lazygit_win, true)
		lazygit_win = nil
		return
	end

	-- Create buffer if needed
	if not lazygit_buf or not vim.api.nvim_buf_is_valid(lazygit_buf) then
		lazygit_buf = vim.api.nvim_create_buf(false, true)
	end

	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.9)

	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	lazygit_win = vim.api.nvim_open_win(lazygit_buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- Only start lazygit once
	if vim.bo[lazygit_buf].buftype ~= "terminal" then
		vim.fn.termopen({ "lazygit" })
	end

	vim.cmd("startinsert")
end

local function rg_search_project()
	local query = vim.fn.input("Search word: ")
	if query == "" then
		return
	end

	-- Windows-friendly ripgrep
	local cmd = "rg --vimgrep --smart-case " .. vim.fn.shellescape(query) .. " ."

	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()

	if result == "" then
		vim.notify("No matches found!", vim.log.levels.INFO)
		return
	end

	local lines = vim.split(result, "\n")
	local qf_list = {}

	for _, line in ipairs(lines) do
		local file, lnum, col, text = line:match("^([^\n]-):(%d+):(%d+):(.*)$")
		if file and lnum and col and text then
			table.insert(qf_list, {
				filename = file,
				lnum = tonumber(lnum),
				col = tonumber(col),
				text = text,
			})
		end
	end

	if #qf_list == 0 then
		vim.notify("No matches found!", vim.log.levels.INFO)
		return
	end

	-- Устанавливаем quickfix
	vim.fn.setqflist({}, " ", { title = "rg Search", items = qf_list })
	vim.cmd("copen")
end
-- [[ Utils ]]

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
--

local parsers = { "lua", "go", "cpp", "python", "yaml" }
local langs = { "lua_ls", "gopls", "basedpyright", "clangd", "stylua" }

vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim",
	"https://github.com/neovim/nvim-lspconfig",
})

require("mason").setup()
require("nvim-treesitter").setup({ ensure_installed = parsers })
require("mason-lspconfig").setup({ ensure_installed = langs })

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

vim.lsp.config("gopls", { on_attach = on_attach })
vim.lsp.config("lua_ls", {
	on_attach = on_attach,
	Lua = {
		completion = {
			callSnippet = "Replace",
		},
	},
})
vim.lsp.config("basedpyright", {
	on_attach = on_attach,
	-- root_dir = ".git", "setup.py", "pyproject.toml", "requirements.txt"),
	python = {
		pythonPath = get_python(),
		analysis = {
			autoSearchPaths = true,
			useLibraryCodeForTypes = true,
			typeCheckingMode = "basic",
		},
	},
})

vim.lsp.config("clangd", {
	on_attach = on_attach,
	keys = {
		{ "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
	},
	-- root_dir = function(fname)
	-- 	return require("lspconfig.util").root_pattern(
	-- 		"Makefile",
	-- 		"configure.ac",
	-- 		"configure.in",
	-- 		"config.h.in",
	-- 		"meson.build",
	-- 		"meson_options.txt",
	-- 		"build.ninja"
	-- 	)(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname) or require(
	-- 		"lspconfig.util"
	-- 	).find_git_ancestor(fname)
	-- end,
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
})
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

-- Save
map("n", "<leader>s", "<cmd>w!<cr>", { desc = "Save file" })

-- Buffers
map("n", "<leader>bd", function()
	vim.api.nvim_buf_delete(0, {})
end, { desc = "Buffer delete" })

-- Diagnostic keymaps
map("n", "<leader>x", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Omnifunc
map("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 then
		local ci = vim.fn.complete_info({ "selected" })
		if ci.selected == -1 then
			return "<C-n><C-y>" -- select first, then confirm
		else
			return "<C-y>" -- confirm current selection
		end
	end
	return "<CR>" -- plain newline
end, { expr = true, desc = "Confirm completion or newline" })

-- Yank
map("v", "<C-c>", '"+y')

-- Terminal
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
map("n", "<leader>h", "<cmd>Pick help<CR>", { desc = "Find help" })

-- Search
vim.keymap.set("n", "<leader>sg", rg_search_project, { noremap = true, silent = true })

-- Quit
map("n", "<leader>qq", "<cmd>silent! xa<cr><cmd>qa<cr>", { desc = "Quit All" })

-- Mason
map("n", "<leader>cm", "<cmd>:Mason<CR>", { desc = "Mason" })

-- Flash
map({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })
map({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })
map("o", "r", function()
	require("flash").remote()
end, { desc = "Remote Flash" })
map({ "x", "o" }, "R", function()
	require("flash").treesitter_search()
end, { desc = "Treesitter Search" })

-- LazyGit
if vim.fn.executable("lazygit") == 1 then
	map("n", "<leader>gg", toggle_lazygit, { desc = "Lazygit (Root Dir)" })
end

-- [[ Basic Keymaps ]]
-- [[ Plugins ]]

-- Mini.nvim
vim.pack.add({ { src = "https://github.com/nvim-mini/mini.nvim" } })
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
vim.pack.add({
	"https://github.com/f-person/auto-dark-mode.nvim",
})
require("auto-dark-mode").setup({
	update_interval = 1000,
	-- for gnome dection we need fallback
	fallback = "light",
})
-- Auto dark mode

-- Flash.nvim
vim.pack.add({ "https://github.com/folke/flash.nvim" })
require("flash").setup()
-- Flash.nvim

-- Blink
vim.pack.add({
	"https://github.com/saghen/blink.cmp",
})
require("blink.cmp").setup({
	keymap = { preset = "enter" },
	appearance = { nerd_font_variant = "mono" },

	completion = { documentation = { auto_show = false } },
	signature = { enabled = true },

	sources = { default = { "lsp", "path", "snippets", "buffer" } },
	fuzzy = { implementation = "lua" },
})
-- Blink

-- [[ Plugins ]]
