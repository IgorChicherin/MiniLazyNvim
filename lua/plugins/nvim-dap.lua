return {
  "mfussenegger/nvim-dap",
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
      end,
      desc = "Terminate",
    },
  },
}
