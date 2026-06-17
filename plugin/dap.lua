-- nvim-dap + nvim-dap-view
vim.api.nvim_create_autocmd("User", {
  pattern = "PackChanged",
  callback = function(ev)
    local name = ev.data.spec.name
    if name == "nvim-dap" or name == "nvim-dap-view" then
      vim.cmd.packadd(name)
    end
  end,
})

vim.schedule(function()
  -- Ensure nvim-dap is fully loaded (plugin/ scripts run, listeners registered)
  vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" })
  vim.cmd.packadd("nvim-dap")

  -- Now load dap-view and dependencies
  vim.pack.add({
    { src = "https://github.com/igorlfs/nvim-dap-view", version = vim.version.range("1.*") },
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/mfussenegger/nvim-dap-python",
    "https://github.com/leoluz/nvim-dap-go",
    "https://github.com/theHamsta/nvim-dap-virtual-text",
    "https://github.com/williamboman/mason.nvim",
  })

  require("mason-nvim-dap").setup({
    ensure_installed = { "codelldb" },
    automatic_setup = true,
  })
  -- nvim-dap-view config
  require("dap-view").setup({
    winbar = {
      sections = { "console", "watches", "scopes", "exceptions", "breakpoints", "threads", "repl" },
      show = true,
      default_section = "console",
      show_keymap_hints = true,
    },
    windows = {
      size = 15,
      position = "below",
      terminal = { hide = true },
    },
    virtual_text = {
      enabled = true,
    },
    auto_toggle = true,
  })

  local dap = require("dap")
  local dap_python = require("dap-python")
  local dap_go = require("dap-go")

  require("nvim-dap-virtual-text").setup({ commented = true })
  dap_python.setup("python3")
  dap_go.setup()

  local install_root_dir = vim.fn.stdpath("data") .. "/mason"
  local extension_path = install_root_dir .. "/packages/codelldb/extension/"
  local codelldb_path = extension_path .. "adapter/codelldb"

  if vim.loop.os_uname().sysname == "Windows_NT" then
    codelldb_path = codelldb_path .. ".exe"
  end

  if not dap.adapters["codelldb"] then
    dap.adapters["codelldb"] = {
      type = "server",
      host = "127.0.0.1",
      port = "${port}",
      executable = {
        command = codelldb_path,
        args = { "--port", "${port}" },
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
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        port = 13000,
      },
      {
        type = "codelldb",
        request = "attach",
        name = "Attach to process",
        pid = function()
          return require("dap.utils").pick_process()
        end,
        cwd = "${workspaceFolder}",
        port = 13000,
      },
    }
  end
end)

-- DAP keymaps
local map = vim.keymap.set
map("n", "<F5>", function()
  require("dap").continue()
end, { desc = "Run/Continue" })
map("n", "<F7>", function()
  require("dap").step_into()
end, { desc = "Step Into" })
map("n", "<F4>", function()
  require("dap").run_last()
end, { desc = "Run Last" })
map("n", "<F9>", function()
  require("dap").step_out()
end, { desc = "Step Out" })
map("n", "<F8>", function()
  require("dap").step_over()
end, { desc = "Step Over" })
map("n", "<F10>", function()
  require("dap").terminate()
end, { desc = "Terminate" })
map("n", "<leader>du", function()
  require("dap-view").toggle()
end, { desc = "Toggle DAP View" })
map("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })
map("n", "<leader>dB", function()
  local condition = vim.fn.input("Breakpoint condition (optional): ")
  local hit_condition = vim.fn.input("Hit count (optional): ")
  condition = condition ~= "" and condition or nil
  hit_condition = hit_condition ~= "" and hit_condition or nil
  require("dap").toggle_breakpoint(condition, hit_condition)
end, { desc = "Advanced Breakpoint" })
