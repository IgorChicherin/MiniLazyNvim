return {
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
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
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
}
