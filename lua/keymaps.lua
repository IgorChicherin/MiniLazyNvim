-- [[ Basic Keymaps ]]

local map = vim.keymap.set

-- Clear highlights + close floating windows
map("n", "<Esc>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end)

-- Search (Snacks)
local function snacks_picker()
  vim.pack.add({ "https://github.com/folke/snacks.nvim" })
  return require("snacks")
end

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
map("n", "<leader>x", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })

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
map("n", "<leader>e", function()
  snacks_picker().explorer()
end, { desc = "Open file explorer" })

map("n", "<leader><leader>", function()
  snacks_picker().picker.smart()
end, { desc = "Find file" })

-- Quit
map("n", "<leader>qq", "<cmd>silent! xa<cr><cmd>qa<cr>", { desc = "Quit All" })

map("n", "<leader>sf", function()
  snacks_picker().picker.files()
end, { desc = "[S]earch [F]ile" })
map("n", "<leader>sp", function()
  snacks_picker().picker.projects()
end, { desc = "[S]earch [P]roject" })
map("n", "<leader>sb", function()
  snacks_picker().picker.buffers()
end, { desc = "[S]earch [B]uffer" })
map("n", "<leader>sg", function()
  snacks_picker().picker.grep()
end, { desc = "[S]earch [G]rep" })
map("n", "<leader>sc", function()
  snacks_picker().picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [C]onfig file" })
map("n", "<leader>sh", function()
  snacks_picker().picker.command_history()
end, { desc = "[S]earch command [h]istory" })
map("n", "<leader>sC", function()
  snacks_picker().picker.commands()
end, { desc = "[S]earch [C]ommands" })
map("n", "<leader>sH", function()
  snacks_picker().picker.help()
end, { desc = "[S]earch [H]elp" })
map("n", "<leader>sk", function()
  snacks_picker().picker.keymaps()
end, { desc = "[S]earch [k]eymaps" })
map("n", "<leader>sm", function()
  snacks_picker().picker.marks()
end, { desc = "[S]earch [m]arks" })
map("n", "<leader>sq", function()
  snacks_picker().picker.qflist()
end, { desc = "[S]earch [q]uickfix" })
map("n", "<leader>sr", function()
  snacks_picker().picker.registers()
end, { desc = "[S]earch [r]egisters" })
map("n", "<leader>uC", function()
  snacks_picker().picker.colorschemes()
end, { desc = "[U]I [C]olorschemes" })
map("n", "<leader>sGl", function()
  snacks_picker().picker.git_log()
end, { desc = "[S]earch [G]it [L]og" })
map("n", "<leader>sGs", function()
  snacks_picker().picker.git_status()
end, { desc = "[S]earch [G]it [S]tatus" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function()
  snacks_picker().bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function()
  snacks_picker().bufdelete.other()
end, { desc = "Delete Other Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- floating terminal
map("n", "<c-/>", function()
  snacks_picker().terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "Terminal (Root Dir)" })
map("n", "<c-_>", function()
  snacks_picker().terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "which_key_ignore" })

-- Terminal Mappings
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- Format
map("n", "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })

-- Sessions (persistence)
map("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Load session for current dir" })

map("n", "<leader>qS", function()
  require("persistence").select()
end, { desc = "Find session" })

map("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, { desc = "Load last session" })

-- Diagnostic navigation
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

-- Toggles
vim.schedule(function()
  local toggle = snacks_picker().toggle
  toggle.option("spell", { name = "Spelling" }):map("<leader>us")
  toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
  toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
  toggle.diagnostics():map("<leader>ud")
  toggle.line_number():map("<leader>ul")
  toggle
    .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" })
    :map("<leader>uc")
  toggle
    .option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
    :map("<leader>uA")
  toggle.treesitter():map("<leader>uT")
  toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
  toggle.dim():map("<leader>uD")
  toggle.animate():map("<leader>ua")
  toggle.indent():map("<leader>ug")
  toggle.scroll():map("<leader>uS")
  toggle.profiler():map("<leader>dpp")
  toggle.profiler_highlights():map("<leader>dph")
  toggle
    .new({
      id = "format_on_save",
      name = "Format on Save (global)",
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
      name = "Format on Save (buffer)",
      get = function()
        return not vim.b.disable_autoformat
      end,
      set = function(state)
        vim.b.disable_autoformat = not state
      end,
    })
    :map("<leader>uF")
  toggle.zoom():map("<leader>wm"):map("<leader>uZ")
  toggle.zen():map("<leader>uz")
end)

-- windows
map("n", "<leader>w", "<c-w>", { desc = "Windows", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- LazyGit
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function()
    snacks_picker().lazygit({ cwd = vim.uv.cwd() })
  end, { desc = "Lazygit (Root Dir)" })
  map("n", "<leader>gG", function()
    snacks_picker().lazygit()
  end, { desc = "Lazygit (cwd)" })
  map("n", "<leader>gf", function()
    snacks_picker().picker.git_log_file()
  end, { desc = "Git Current File History" })
  map("n", "<leader>gl", function()
    snacks_picker().picker.git_log({ cwd = vim.uv.cwd() })
  end, { desc = "Git Log" })
  map("n", "<leader>gL", function()
    snacks_picker().picker.git_log()
  end, { desc = "Git Log (cwd)" })
end
