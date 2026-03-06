-- [[ Setting options ]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Options
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

vim.cmd.colorscheme("tokyonight")


if vim.uv.os_uname().sysname == "Windows_NT" then
	vim.o.shell = "powershell"
end

vim.diagnostic.config({ jump = { float = true } })
vim.opt.complete = ".,w,b,u,t"
vim.opt.pumheight = 10

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

if vim.g.have_nerd_font then
	local signs = { ERROR = " ", WARN = " ", INFO = " ", HINT = " " }
	local diagnostic_signs = {}
	for type, icon in pairs(signs) do
		diagnostic_signs[vim.diagnostic.severity[type]] = icon
	end
	vim.diagnostic.config({ signs = { text = diagnostic_signs } })
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = vim.keymap.set
		local opts = { noremap = true, silent = true, buffer = event.buf }

		-- Включаем omnifunc для LSP автодополнения
		vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = event.buf })

		map("n", "gd", vim.lsp.buf.definition, opts)
		map("n", "gI", vim.lsp.buf.implementation, opts)
		map("n", "K", vim.lsp.buf.hover, opts)
		map("n", "<leader>cs", vim.lsp.buf.workspace_symbol, opts)
		map("n", "<leader>vd", vim.diagnostic.open_float, opts)
		map("n", "[d", vim.diagnostic.goto_next, opts)
		map("n", "]d", vim.diagnostic.goto_prev, opts)
		map("n", "<leader>gr", vim.lsp.buf.references, opts)
		map("n", "<leader>cr", vim.lsp.buf.rename, opts)
		map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		map("n", "<leader>lf", vim.lsp.buf.format, opts)
		map("i", "<C-k>", vim.lsp.buf.signature_help, opts)

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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

-- [[ Utils ]]
local lazygit_win = nil
local lazygit_buf = nil

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
	if lazygit_win and vim.api.nvim_win_is_valid(lazygit_win) then
		vim.api.nvim_win_close(lazygit_win, true)
		lazygit_win = nil
		return
	end

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

	vim.fn.setqflist({}, " ", { title = "rg Search", items = qf_list })
	vim.cmd("copen")
end
-- [[ Utils ]]

-- [[ Autocommands ]]
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
-- [[ Autocommands ]]

-- [[ Keymaps ]]
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

map("n", "<leader>bd", function()
	vim.api.nvim_buf_delete(0, {})
end, { desc = "Buffer delete" })

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
map("n", "<leader>t", toggle_terminal, { desc = "Toggle Terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

map("n", "<leader>e", function()
	local netrw_open = false
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "netrw" then
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
map("n", "<leader>sg", rg_search_project, { noremap = true, silent = true })
map("n", "<leader>qq", "<cmd>silent! xa<cr><cmd>qa<cr>", { desc = "Quit All" })

if vim.fn.executable("lazygit") == 1 then
	map("n", "<leader>gg", toggle_lazygit, { desc = "Lazygit (Root Dir)" })
end
-- [[ Keymaps ]]

-- [[ vim.pack setup ]]
-- Bootstrap plugins with vim.pack (Neovim 0.12+)

local pack_path = vim.fn.stdpath("data") .. "/site/pack/packer"

local function ensure_dir(path)
	vim.fn.mkdir(path, "p")
end

ensure_dir(pack_path .. "/start")
ensure_dir(pack_path .. "/opt")

local function clone_or_update(plugin, path)
	local name = plugin:match("/([^/]+)$")
	local dest = path .. "/start/" .. name

	if not vim.loop.fs_stat(dest) then
		print("Installing " .. name .. "...")
		vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/" .. plugin .. ".git", dest })
	else
		-- Optional: update plugins on startup
		-- vim.fn.system({ "git", "-C", dest, "pull" })
	end

	vim.opt.rtp:prepend(dest)
	return name
end

-- Load all plugins in start/ (auto-loaded)
local mason = clone_or_update("williamboman/mason.nvim", pack_path)
local mason_lspconfig = clone_or_update("williamboman/mason-lspconfig.nvim", pack_path)
local mason_tool_installer = clone_or_update("WhoIsSethDaniel/mason-tool-installer.nvim", pack_path)
local lspconfig = clone_or_update("neovim/nvim-lspconfig", pack_path)
local dap = clone_or_update("mfussenegger/nvim-dap", pack_path)
local nvim_nio = clone_or_update("nvim-neotest/nvim-nio", pack_path)
local dapui = clone_or_update("rcarriga/nvim-dap-ui", pack_path)
local treesitter = clone_or_update("nvim-treesitter/nvim-treesitter", pack_path)
local flash = clone_or_update("folke/flash.nvim", pack_path)
local auto_dark = clone_or_update("f-person/auto-dark-mode.nvim", pack_path)
local mini = clone_or_update("echasnovski/mini.nvim", pack_path)
local snippets = clone_or_update("rafamadriz/friendly-snippets", pack_path)
local tokyonight = clone_or_update( "folke/tokyonight.nvim", pack_path)

-- Load optional plugins after cloning
require("mason").setup()
require("mason-lspconfig").setup()

-- [[ LSP Configuration ]]
local servers = {
	gopls = {},
	ruff = {},
	basedpyright = {
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
	},
	lua_ls = {
		settings = {
			Lua = {
				completion = { callSnippet = "Replace" },
			},
		},
	},
	clangd = {
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

for server_name, server_config in pairs(servers) do
	vim.lsp.config(server_name, server_config)
end

-- [[ mason-tool-installer ]]
require("mason-tool-installer").setup({
	ensure_installed = {
		"gopls",
		"ruff",
		"basedpyright",
		"lua-language-server",
		"clangd",
	},
})

-- [[ DAP Configuration ]]
local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

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
map("n", "<F5>", function() dap.continue() end, { desc = "Run/Continue" })
map("n", "<F7>", function() dap.step_into() end, { desc = "Step Into" })
map("n", "<F8>", function() dap.step_over() end, { desc = "Step Over" })
map("n", "<F9>", function() dap.step_out() end, { desc = "Step Out" })
map("n", "<F10>", function() dap.terminate() end, { desc = "Terminate" })
map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
map("n", "<leader>du", function() dapui.toggle() end, { desc = "Toggle DAP UI" })

-- [[ Treesitter ]]
require("nvim-treesitter").setup({
	ensure_installed = { "lua", "python", "go", "c", "cpp" },
	highlight = { enable = true },
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		local ok = pcall(vim.treesitter.get_parser, 0, "go")
		if ok then
			vim.treesitter.start()
		end
	end,
})

-- [[ flash.nvim ]]
require("flash").setup()
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash" })
map({ "n", "o", "x" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
map("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" })
map({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
map("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle Flash Search" })

-- [[ auto-dark-mode.nvim ]]
require("auto-dark-mode").setup({
	update_interval = 1000,
})

-- [[ mini.nvim ]]
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

require("mini.completion").setup()

local statusline = require("mini.statusline")
local icons = require("mini.icons")

statusline.section_location = function() return "%2l:%-2v" end
statusline.section_filename = function() return "%f" end
statusline.section_fileinfo = function()
	local filetype = vim.bo.filetype
	if filetype == "" then return "" end
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
statusline.setup({ use_icons = vim.g.have_nerd_font })

require("mini.misc").setup({ make_global = { "put", "put_text" } })
