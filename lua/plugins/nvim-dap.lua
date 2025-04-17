return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
    "mfussenegger/nvim-dap-python",
    "theHamsta/nvim-dap-virtual-text",
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
        require("dapui").close()
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
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    local dap_python = require("dap-python")

    require("dapui").setup({})
    require("nvim-dap-virtual-text").setup({
      commented = true,
    })
    dap_python.setup("python3")

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
  end,
}
