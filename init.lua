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

vim.opt.path:append("**")

if vim.loop.os_uname().sysname == "Windows_NT" then
	vim.o.shell = "powershell"
end

vim.diagnostic.config({ jump = { float = true } })

-- Restrict omnifunc variants by disabling extra sources (buffer/path)
vim.opt.complete = ".,w,b,u,t" -- .: current buffer, w: buffers in window, b: open buffers, u: unloaded buffers, t: tags
vim.opt.pumheight = 10

-- [[ Utils ]]
local on_attach = function(client, bufnr) end

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
map({ "n", "i", "v" }, "<C-s>", "<cmd>w!<cr>", { desc = "Save file" })

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
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

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
map("n", "<leader><leader>", ":find ", { desc = "Find file" })
map("n", "<leader>h", ":help", { desc = "Find help" })

-- Search
vim.keymap.set("n", "<leader>sg", rg_search_project, { noremap = true, silent = true })

-- Quit
map("n", "<leader>qq", "<cmd>silent! xa<cr><cmd>qa<cr>", { desc = "Quit All" })

-- Mason
map("n", "<leader>cm", "<cmd>:Mason<CR>", { desc = "Mason" })

-- LazyGit
if vim.fn.executable("lazygit") == 1 then
	map("n", "<leader>gg", toggle_lazygit, { desc = "Lazygit (Root Dir)" })
end
-- [[ Basic Keymaps ]]

-- [[ Plugins ]]
-- Lazy
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
--  Lazy

--------------------------------------------------------------------------------
-- See https://gpanders.com/blog/whats-new-in-neovim-0-11/ for a nice overview
-- of how the lsp setup works in neovim 0.11+.

-- This actually just enables the lsp servers.
-- The configuration is found in the lsp folder inside the nvim config folder,
-- so in ~.config/lsp/lua_ls.lua for lua_ls, for example.
--
require("lazy").setup({
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"rcarriga/nvim-dap-ui",
			"mfussenegger/nvim-dap-python",
			"leoluz/nvim-dap-go",
			"theHamsta/nvim-dap-virtual-text",
			{
				"williamboman/mason.nvim",
				optional = true,
				opts = { ensure_installed = { "codelldb" } },
			},
		},
		keys = {
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				desc = "Run/Continue",
			},
			{
				"<F7>",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
			},
			{
				"<F4>",
				function()
					require("dap").run_last()
				end,
				desc = "Run Last",
			},
			{
				"<F9>",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
			},
			{
				"<F8>",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
			},
			{
				"<F10>",
				function()
					require("dap").terminate()
					-- require("dapui").close()
				end,
				desc = "Terminate",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
			},
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
			},
			{
				"<leader>dB",
				function()
					local condition = vim.fn.input("Breakpoint condition (optional): ")
					local hit_condition = vim.fn.input("Hit count (optional): ")

					-- Convert empty strings to nil
					condition = condition ~= "" and condition or nil
					hit_condition = hit_condition ~= "" and hit_condition or nil

					require("dap").toggle_breakpoint(condition, hit_condition)
				end,
				desc = "Debug: Toggle Advanced Breakpoint",
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			local dap_python = require("dap-python")
			local dap_go = require("dap-go")

			require("dapui").setup({})
			require("nvim-dap-virtual-text").setup({
				commented = true,
			})
			dap_python.setup("python3")
			dap_go.setup()

			-- dap.listeners.after.event_initialized["dapui_config"] = function()
			--   dapui.open()
			-- end
		end,
		opts = function()
			local dap = require("dap")
			local install_root_dir = vim.fn.stdpath("data") .. "/mason"
			local extension_path = install_root_dir .. "/packages/codelldb/extension/"
			local codelldb_path = extension_path .. "adapter/codelldb"

			if vim.loop.os_uname().sysname == "Windows_NT" then
				codelldb_path = codelldb_path .. ".exe"
			end

			if not dap.adapters["codelldb"] then
				require("dap").adapters["codelldb"] = {
					type = "server",
					host = "127.0.0.1",
					port = "${port}",
					executable = {
						command = codelldb_path,
						args = {
							"--port",
							"${port}",
						},
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
							return vim.fn.input("Path to executable: ",
								vim.fn.getcwd() .. "/", "file")
						end,
						cwd = "${workspaceFolder}",
						port = 13000,
					},
					{
						type = "codelldb",
						request = "attach",
						name = "Attach to process",
						pid = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
						port = 13000,
					},
				}
			end
		end,
	},
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			-- Mason must be loaded before its dependents so we need to set it up here.
			-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
			{ "williamboman/mason.nvim",      opts = {} },
			{ "jay-babu/mason-nvim-dap.nvim", opts = { automatic_installation = true } },
			{ "stevearc/dressing.nvim",       opts = {},                               event = "VeryLazy" },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} },

			{
				"folke/lazydev.nvim",
				ft = "lua", -- only load on lua files
				opts = {
					library = {
						-- See the configuration section for more details
						-- Load luvit types when the `vim.uv` word is found
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		config = function()
			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
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
					map("n", "gI", function()
						vim.lsp.buf.implementation({
							on_list = function(options)
								vim.fn.setqflist({}, " ", options)
								vim.cmd("copen")
							end,
						})
					end, opts)
					map("n", "K", vim.lsp.buf.hover, opts)
					map("n", "<leader>cs", vim.lsp.buf.workspace_symbol, opts)
					map("n", "<leader>vd", vim.diagnostic.open_float, opts)
					map("n", "[d", vim.diagnostic.goto_next, opts)
					map("n", "]d", vim.diagnostic.goto_prev, opts)
					map("n", "<leader>gr", vim.lsp.buf.references, opts)
					map("n", "<leader>cr", vim.lsp.buf.rename, opts)
					map("i", "<C-k>", vim.lsp.buf.signature_help, opts)
					map("n", "<leader>lf", vim.lsp.buf.format, opts)

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
						    vim.api.nvim_create_augroup("kickstart-lsp-highlight",
							    { clear = false })
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
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach",
								{ clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({
									group = "kickstart-lsp-highlight",
									buffer = event2.buf,
								})
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("n", "<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr =
							event.buf }))
						end, opts)
					end
				end,
			})
			--
			-- Change diagnostic symbols in the sign column (gutter)
			if vim.g.have_nerd_font then
				local signs = { ERROR = " ", WARN = " ", INFO = " ", HINT = " " }
				local diagnostic_signs = {}
				for type, icon in pairs(signs) do
					diagnostic_signs[vim.diagnostic.severity[type]] = icon
				end
				vim.diagnostic.config({ signs = { text = diagnostic_signs } })
			end

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			-- local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

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
							diagnosticMode = "workspace", -- 🔥 REQUIRED
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
						{ "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
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
						)(fname) or require("lspconfig.util").root_pattern(
							"compile_commands.json",
							"compile_flags.txt"
						)(fname) or require("lspconfig.util").find_git_ancestor(fname)
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

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						-- server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
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
	{
		"saghen/blink.cmp",
		event = { "LspAttach" },
		dependencies = { "rafamadriz/friendly-snippets" },

		-- use a release tag to download pre-built binaries
		version = "1.*",
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
			-- 'super-tab' for mappings similar to vscode (tab to accept)
			-- 'enter' for enter to accept
			-- 'none' for no mappings
			--
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs if already open
			-- C-n/C-p or Up/Down: Select next/previous item
			-- C-e: Hide menu
			-- C-k: Toggle signature help (if signature.enabled = true)
			--
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = { preset = "enter" },

			appearance = { nerd_font_variant = "mono" },

			completion = { documentation = { auto_show = false } },
			signature = { enabled = true },

			sources = { default = { "lsp", "path", "snippets", "buffer" } },

			fuzzy = { implementation = "lua" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		opts_extend = { "sources.default" },
	},
	{
		"p00f/clangd_extensions.nvim",
		lazy = true,
		config = function() end,
		opts = {
			inlay_hints = {
				inline = false,
			},
			ast = {
				--These require codicons (https://github.com/microsoft/vscode-codicons)
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
		},
	},
	{ "tpope/vim-sleuth" },
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		vscode = true,
		---@type Flash.Config
		opts = {},
		-- stylua: ignore
		keys = {
			{ "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "S",     mode = { "n", "o", "x" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
	},
	{
		"echasnovski/mini.nvim",
		version = false,
		init = function()
			require("mini.basics").setup()

			-- Typing enhacements
			require("mini.move").setup()
			require("mini.pairs").setup()
			local hipatterns = require("mini.hipatterns")
			hipatterns.setup({
				highlighters = {
					-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
					fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
					hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
					todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
					note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

					-- Highlight hex color strings (`#rrggbb`) using that color
					hex_color = hipatterns.gen_highlighter.hex_color(),
				},
			})
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
						d = { "%f[%d]%d+" },                -- digits
						e = {                               -- Word with case
							{
								"%u[%l%d]+%f[^%l%d]",
								"%f[%S][%l%d]+%f[^%l%d]",
								"%f[%P][%l%d]+%f[^%l%d]",
								"^[%l%d]+%f[^%l%d]",
							},
							"^().*()$",
						},
						-- g = LazyVim.mini.ai_buffer, -- buffer
						u = ai.gen_spec.function_call(), -- u for "Usage"
						U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
					},
				},
			})

			-- UI enhacements
			require("mini.notify").setup()
			require("mini.git").setup()
			require("mini.icons").setup()

			local statusline = require("mini.statusline")
			local icons = require("mini.icons")

			statusline.section_location = function()
				return "%2l:%-2v"
			end

			statusline.section_filename = function()
				return "%f"
			end

			statusline.section_fileinfo = function()
				local filetype = vim.bo.filetype

				-- Don't show anything if there is no filetype
				if filetype == "" then
					return ""
				end

				-- Add filetype icon
				filetype = icons.get("filetype", filetype) .. " " .. filetype

				local size = vim.fn.getfsize(vim.fn.getreg("%"))
				if size < 1024 then
					size = string.format("%dB", size)
				elseif size < 1048576 then
					size = string.format("%.2fKiB", size / 1024)
				else
					size = string.format("%.2fMiB", size / 1048576)
				end

				return string.format("%s %s", filetype, size)
			end

			statusline.setup({
				use_icons = vim.g.have_nerd_font,
			})

			require("mini.misc").setup({ make_global = { "put", "put_text" } })
		end,
	},
})
