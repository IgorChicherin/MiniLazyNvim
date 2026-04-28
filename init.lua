-- [[ Neovim 0.12 Configuration ]]
-- Uses vim.pack (built-in plugin manager), vim.lsp.config/enable (native LSP),
-- and other 0.12 features.

-- ============================================================
-- Options
-- ============================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeout = true
vim.opt.timeoutlen = 800
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.path:append("**")
vim.opt.cmdheight = 0

if vim.loop.os_uname().sysname == "Windows_NT" then
	vim.opt.shell = "powershell.exe"
	vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"

	vim.opt.shellquote = ""
	vim.opt.shellxquote = ""
end

-- Neovim 0.12: diagnostic jump config uses float key
vim.diagnostic.config({ jump = { float = true } })

vim.opt.complete = ".,w,b,u,t"
vim.opt.completeopt = "menuone,noselect,fuzzy"
vim.opt.pumheight = 10

-- Let `mini.completion` drive insert completion to avoid conflicts with
-- prompt/picker UIs that install their own completion handlers.
vim.opt.autocomplete = false

-- Neovim 0.12: inline diff in diffopt
vim.opt.diffopt:append("inline:char")

local function set_colorscheme(scheme)
	local ok = pcall(vim.cmd, "colorscheme " .. scheme)
	if not ok then
		vim.cmd.colorscheme("default")
		vim.api.nvim_set_hl(0, "FlashLabel", {
			fg = "#ffffff",
			bg = "#ff007c",
			bold = true,
		})
	else
		vim.cmd.colorscheme(scheme)
	end
end


if vim.g.have_nerd_font then
	local signs = { ERROR = " ", WARN = " ", INFO = " ", HINT = " " }
	local diagnostic_signs = {}
	for type, icon in pairs(signs) do
		diagnostic_signs[vim.diagnostic.severity[type]] = icon
	end
	vim.diagnostic.config({ signs = { text = diagnostic_signs } })
end


-- ============================================================
-- vim.pack — Built-in Plugin Manager (Neovim 0.12+)
-- ============================================================

vim.cmd("packadd nvim.undotree")
require("vim._core.ui2").enable()

vim.pack.add({
	-- LSP (configs loaded from nvim-lspconfig runtime)
	{ src = "https://github.com/folke/tokyonight.nvim" },

	{ src = "https://github.com/neovim/nvim-lspconfig.git" },

	-- Treesitter
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter.git", build = ":TSUpdate" },

	-- DAP
	{ src = "https://github.com/mfussenegger/nvim-dap.git" },
	{ src = "https://github.com/nvim-neotest/nvim-nio.git" },
	{ src = "https://github.com/igorlfs/nvim-dap-view" },

	-- UI / UX
	{ src = "https://github.com/folke/flash.nvim.git" },
	{ src = "https://github.com/f-person/auto-dark-mode.nvim.git" },
	{ src = "https://github.com/echasnovski/mini.nvim.git" },
	{ src = "https://github.com/rafamadriz/friendly-snippets.git" },
	{ src = "https://github.com/folke/snacks.nvim.git" }
})

set_colorscheme("tokyonight")

local function snacks_picker()
	vim.pack.add({ "https://github.com/folke/snacks.nvim" })
	return require("snacks")
end


-- PackUpdate command
vim.api.nvim_create_user_command("PackUpdate", function()
	vim.notify("Updating plugins...", vim.log.levels.INFO)
	vim.pack.update()
end, { desc = "Update all plugins via vim.pack" })

-- ============================================================
-- LSP Configuration (Neovim 0.12 native API)
-- ============================================================

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

-- Global LSP config for all servers
vim.lsp.config("*", {
	capabilities = {
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true,
				},
			},
		},
	},
})

-- Server-specific configs
vim.lsp.config("gopls", {})

vim.lsp.config("ruff", {})

vim.lsp.config("basedpyright", {
	settings = {
		python = { pythonPath = get_python() },
	},
	basedpyright = {
		analysis = {
			autoSearchPaths = true,
			diagnosticMode = "workspace",
			useLibraryCodeForTypes = true,
		},
	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			completion = { callSnippet = "Replace" },
		},
	},
})

vim.lsp.config("clangd", {
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

vim.lsp.config('intelephense', {
	cmd = { 'intelephense', '--stdio' },
	filetypes = { 'php' },
	root_markers = { 'composer.json', '.git' },
})

-- LSP keymaps (attached on LspAttach)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = vim.keymap.set
		local opts = { noremap = true, silent = true, buffer = event.buf }

		-- Route LSP completion through `mini.completion`.
		vim.api.nvim_set_option_value("omnifunc", "v:lua.MiniCompletion.completefunc_lsp", { buf = event.buf })

		map("n", "gd", vim.lsp.buf.definition, opts)
		map("n", "gI", vim.lsp.buf.implementation, opts)
		map("n", "K", vim.lsp.buf.hover, opts)
		map("n", "<leader>cs", vim.lsp.buf.workspace_symbol, opts)
		map("n", "<leader>vd", vim.diagnostic.open_float, opts)
		map("n", "[d", vim.diagnostic.goto_next, opts)
		map("n", "]d", vim.diagnostic.goto_prev, opts)
		map("n", "<leader>gr", vim.lsp.buf.references, opts)
		map("n", "grt", vim.lsp.buf.type_definition, opts) -- 0.12
		map("n", "<leader>cr", vim.lsp.buf.rename, opts)
		map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		map("n", "<leader>lf", vim.lsp.buf.format, opts)
		map("i", "<C-k>", vim.lsp.buf.signature_help, opts)

		-- Neovim 0.12: document highlight
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
			local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
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
		end
	end,
})

-- Enable LSP servers
vim.lsp.enable({ "gopls", "ruff", "basedpyright", "lua_ls", "clangd", "intelephense" })

-- ============================================================
-- Treesitter (Neovim 0.12)
-- ============================================================
require("nvim-treesitter").setup({
	ensure_installed = { "lua", "python", "go", "c", "cpp", "php" },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})

-- Ensure treesitter highlight runs on filetype
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "go", "lua", "python", "c", "cpp", "php" },
	callback = function(args)
		local lang = vim.treesitter.language.get_lang(args.match)
		if lang and pcall(vim.treesitter.get_parser, args.buf, lang) then
			vim.treesitter.start(args.buf, lang)
		end
	end,
})

-- ============================================================
-- DAP Configuration
-- ============================================================
local dap = require("dap")
local dapview = require("dap-view")

dapview.setup()

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}",
	},
}

dap.configurations.go = {
	{
		type = "go",
		request = "launch",
		name = "Debug",
		program = "${file}",
	},
}

-- DAP keymaps
local map = vim.keymap.set
map("n", "<F5>", function() dap.continue() end, { desc = "Run/Continue" })
map("n", "<F7>", function() dap.step_into() end, { desc = "Step Into" })
map("n", "<F8>", function() dap.step_over() end, { desc = "Step Over" })
map("n", "<F9>", function() dap.step_out() end, { desc = "Step Out" })
map("n", "<F10>", function() dap.terminate() end, { desc = "Terminate" })
map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
map("n", "<leader>du", function() dapview.toggle() end, { desc = "Toggle DAP UI" })

-- ============================================================
-- Autocommands
-- ============================================================
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})



-- ============================================================
-- Keymaps
-- ============================================================
local map = vim.keymap.set

map("n", "<Esc>", function()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).relative == "win" then
			vim.api.nvim_win_close(win, false)
		end
	end
end)

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map({ "n", "i", "v" }, "<C-s>", "<cmd>w!<cr>", { desc = "Save file" })

map("n", "<leader>bd", function() snacks_picker().bufdelete() end, { desc = "Buffer delete" })
map("n", "<leader>bo", snacks_picker().bufdelete.other, { desc = "Delete Other Buffers" })

map("n", "<leader>x", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

map("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 then
		local ci = vim.fn.complete_info({ "selected" })
		if ci.selected == -1 then
			return "<C-n><C-y>"
		else
			return "<C-y>"
		end
	end
	return "<CR>"
end, { expr = true, desc = "Confirm completion or newline" })

map("v", "<C-c>", '"+y')
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Windows movements
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

map("n", "<leader>u", require("undotree").open, { desc = "Open file explorer" })
map("n", "<leader><leader>", snacks_picker().picker.files, { desc = "Find file" })
map("n", "<leader>qq", "<cmd>silent! xa<cr><cmd>qa<cr>", { desc = "Quit All" })
map("n", "<leader>e", function() snacks_picker().explorer() end, { desc = "Open file explorer" })
map("n", "<leader>f", vim.lsp.buf.format, { desc = "Code [F]ormat" })

-- Terminal Mappings
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- floating terminal
map("n", "<c-/>", function()
	snacks_picker().terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "Terminal (Root Dir)" })
map("n", "<c-_>", function()
	snacks_picker().terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "which_key_ignore" })


-- Snacks
map("n", "<leader>sf", snacks_picker().picker.files, { desc = "[S]earch [F]ile" })
map("n", "<leader>sp", snacks_picker().picker.projects, { desc = "[S]earch [P]roject" })
map("n", "<leader>sb", snacks_picker().picker.buffers, { desc = "[S]earch [B]uffer" })
map("n", "<leader>sg", snacks_picker().picker.grep, { desc = "[S]earch [G]rep" })
map("n", "<leader>sc", function() snacks_picker().picker.files({ cwd = vim.fn.stdpath("config") }) end,
	{ desc = "[S]earch [C]onfig file" })
map("n", "<leader>sh", snacks_picker().picker.command_history, { desc = "[S]earch command [h]istory" })
map("n", "<leader>sC", snacks_picker().picker.commands, { desc = "[S]earch [C]ommands" })
map("n", "<leader>sH", snacks_picker().picker.help, { desc = "[S]earch [H]elp" })
map("n", "<leader>sk", snacks_picker().picker.keymaps, { desc = "[S]earch [k]eymaps" })
map("n", "<leader>sm", snacks_picker().picker.marks, { desc = "[S]earch [m]arks" })
map("n", "<leader>sq", snacks_picker().picker.qflist, { desc = "[S]earch [q]uickfix" })
map("n", "<leader>sr", snacks_picker().picker.registers, { desc = "[S]earch [r]egisters" })
map("n", "<leader>uC", snacks_picker().picker.colorschemes, { desc = "[U]I [C]olorschemes" })
map("n", "<leader>sGl", snacks_picker().picker.git_log, { desc = "[S]earch [G]it [L]og" })
map("n", "<leader>sGs", snacks_picker().picker.git_status, { desc = "[S]earch [G]it [S]tatus" })

-- Buffer navigation
map("n", "H", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "L", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Neovim 0.12: plugin update keymap
map("n", "<leader>pu", "<cmd>PackUpdate<CR>", { desc = "Update plugins" })

if vim.fn.executable("lazygit") == 1 then
	map("n", "<leader>gg", function() snacks_picker().lazygit() end, { desc = "Lazygit (Root Dir)" })
end

-- ============================================================
-- flash.nvim
-- ============================================================
require("flash").setup()
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash" })
map({ "n", "o", "x" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
map("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" })
map({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
map("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle Flash Search" })

-- ============================================================
-- auto-dark-mode.nvim
-- ============================================================
require("auto-dark-mode").setup({
	update_interval = 1000,
})

-- ============================================================
-- mini.nvim
-- ============================================================
require("mini.basics").setup()
require("mini.move").setup()
require("mini.pairs").setup()

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
	custom_textobjects = {
		o = ai.gen_spec.treesitter({ a = { "@block.outer", "@conditional.outer", "@loop.outer" }, i = { "@block.inner", "@conditional.inner", "@loop.inner" } }),
		f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
		t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
		d = { "%f[%d]%d+" },
		e = { { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" }, "^().*()$" },
		u = ai.gen_spec.function_call(),
		U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
	},
})

require("mini.notify").setup()
require("mini.git").setup()
require("mini.icons").setup()
-- require("mini.tabline").setup()

local fuzzy_process_items = function(items, base)
	return MiniCompletion.default_process_items(items, base, {
		filtersort = "fuzzy",
	})
end

require("mini.completion").setup({
	lsp_completion = {
		source_func = "omnifunc",
		auto_setup = false,
		process_items = fuzzy_process_items,
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "snacks_input", "snacks_picker_input", "snacks_picker_list", "snacks_picker_preview" },
	callback = function()
		vim.b.minicompletion_disable = true
	end,
})

-- local statusline = require("mini.statusline")
-- local icons = require("mini.icons")
--
-- -- Neovim 0.12: statusline section_location uses new API
-- statusline.section_location = function() return "%2l:%-2v" end
-- statusline.section_filename = function() return "%f" end
-- statusline.section_fileinfo = function()
-- 	local filetype = vim.bo.filetype
-- 	if filetype == "" then return "" end
-- 	filetype = icons.get("filetype", filetype) .. " " .. filetype
-- 	local size = vim.fn.getfsize(vim.fn.getreg("%"))
-- 	if size < 1024 then
-- 		size = string.format("%dB", size)
-- 	elseif size < 1048576 then
-- 		size = string.format("%.2fKiB", size / 1024)
-- 	else
-- 		size = string.format("%.2fMiB", size / 1048576)
-- 	end
-- 	return string.format("%s %s", filetype, size)
-- end
-- statusline.setup({ use_icons = vim.g.have_nerd_font })

require("mini.misc").setup({ make_global = { "put", "put_text" } })
