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

-- Diagnostic keymaps
map("n", "<leader>x", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Windows movements
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Files
map("n", "<leader>e", "<cmd>lua MiniFiles.open()<CR>", { desc = "Open file explorer" })
map("n", "<leader><leader>", "<cmd>Pick files<CR>", { desc = "Find file" })

-- Quit
map("n", "<leader>qq", "<cmd>silent! xa<cr><cmd>qa<cr>", { desc = "Quit All" })

-- Search
map("n", "<leader>sf", Snacks.picker.files, { desc = "[S]earch [F]ile" })
map("n", "<leader>sb", Snacks.picker.buffers, { desc = "[S]earch [B]uffer" })
map("n", "<leader>sg", Snacks.picker.grep, { desc = "[S]earch [g]rep" })
map("n", "<leader>sc", function()
  Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [C]onfig file" })
map("n", "<leader>sh", Snacks.picker.command_history, { desc = "[S]earch command [h]istory" })
map("n", "<leader>sC", Snacks.picker.commands, { desc = "[S]earch [C]ommands" })
map("n", "<leader>sH", Snacks.picker.help, { desc = "[S]earch [H]elp" })
map("n", "<leader>sk", Snacks.picker.keymaps, { desc = "[S]earch [k]eymaps" })
map("n", "<leader>sm", Snacks.picker.marks, { desc = "[S]earch [m]arks" })
map("n", "<leader>sq", Snacks.picker.qflist, { desc = "[S]earch [q]uickfix" })
map("n", "<leader>sr", Snacks.picker.registers, { desc = "[S]earch [r]egisters" })
map("n", "<leader>uC", Snacks.picker.colorschemes, { desc = "[U]I [C]olorschemes" })
map("n", "<leader>sGl", Snacks.picker.git_log, { desc = "[S]earch [G]kt [L]og" })
map("n", "<leader>sGs", Snacks.picker.git_status, { desc = "[S]earch [G]it [S]tatus" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- floating terminal
map("n", "<c-/>", function()
  Snacks.terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "Terminal (Root Dir)" })
map("n", "<c-_>", function()
  Snacks.terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "which_key_ignore" })

-- Terminal Mappings
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- AI
map("n", "<leader>a", "<cmd>:Gen<cr>", { desc = "AI prompt" })

-- Lazy
map("n", "<leader>l", "<cmd>:Lazy<CR>", { desc = "Lazy" })

-- Mason
map("n", "<leader>cm", "<cmd>:Mason<CR>", { desc = "Mason" })

-- LazyGit
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function()
    Snacks.lazygit({ cwd = vim.uv.cwd() })
  end, { desc = "Lazygit (Root Dir)" })
  map("n", "<leader>gG", function()
    Snacks.lazygit()
  end, { desc = "Lazygit (cwd)" })
  map("n", "<leader>gf", function()
    Snacks.picker.git_log_file()
  end, { desc = "Git Current File History" })
  map("n", "<leader>gl", function()
    Snacks.picker.git_log({ cwd = vim.uv.cwd() })
  end, { desc = "Git Log" })
  map("n", "<leader>gL", function()
    Snacks.picker.git_log()
  end, { desc = "Git Log (cwd)" })
end

-- VenvSelect
map("n", "<leader>cv", "<cmd>VenvSelect<cr>", { desc = "Select venv" })

-- toggle options
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle
  .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" })
  :map("<leader>uc")
Snacks.toggle
  .option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
  :map("<leader>uA")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.animate():map("<leader>ua")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.scroll():map("<leader>uS")
Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")

-- windows
map("n", "<leader>w", "<c-w>", { desc = "Windows", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
Snacks.toggle.zen():map("<leader>uz")

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
