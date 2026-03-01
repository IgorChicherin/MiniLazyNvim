-- [[ Basic Keymaps ]]
-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`

local map = vim.keymap.set

map("n", "<Esc>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end)

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Omnifunc

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

-- Diagnostic keymaps
map("n", "<leader>x", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Terminal
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
      vim.api.nvim_wdesc = "Toggle terminal"
      in_close(found_win, false)
    else
      vim.cmd("sb " .. term_buf)
      vim.cmd("startinsert")
    end
  else
    vim.cmd("sp | term")
  end
end

map("n", "<leader>t", toggle_terminal, { desc = "Toggle terminal" })
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

-- Buffers
map("n", "<leader>bd", function()
  vim.api.nvim_buf_delete(0, {})
end, { desc = "Buffer delete" })

-- Quit
map("n", "<leader>qq", "<cmd>silent! xa<cr><cmd>qa<cr>", { desc = "Quit All" })

-- Search
local function grep_input()
  local input = vim.fn.input("RG search: ")
  if input ~= "" then
    -- call ripgrep directly
    vim.cmd("vimgrep /" .. input .. "/gj **/*")
    vim.cmd("copen")
  end
end

map("n", "<leader>sg", grep_input, { noremap = true, desc = "Grep word" })

-- Lazy
map("n", "<leader>l", "<cmd>:Lazy<CR>", { desc = "Lazy" })

-- Mason
map("n", "<leader>cm", "<cmd>:Mason<CR>", { desc = "Mason" })

-- Sessions
-- load the session for the current directory
map("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Load session for current dir" })

-- Select a session to load
map("n", "<leader>qS", function()
  require("persistence").select()
end, { desc = "Find session" })

local lazygit_buf = nil
local lazygit_win = nil

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

vim.keymap.set("n", "<leader>gg", toggle_lazygit, { desc = "Toggle LazyGit" })

vim.keymap.set("n", "<leader>gg", function()
  vim.cmd("enew")
  vim.fn.termopen({ "lazygit" })
  vim.cmd("startinsert")
end, { desc = "Open LazyGit (tab)" })

map("n", "[e", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
end, { desc = "Go to previous diagnostics ERROR" })
map("n", "]e", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
end, { desc = "Go to next diagnostics ERROR" })

map("n", "[w", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARNING, wrap = true })
end, { desc = "Go to previous diagnostics WARNING" })
map("n", "]w", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARNING, wrap = true })
end, { desc = "Go to next diagnostics WARNING" })
