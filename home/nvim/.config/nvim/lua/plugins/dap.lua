-- Debugging: nvim-dap with adapters from Mason. <leader>D prefix, F5 to start.
local function dap(method, ...)
  local args = { ... }
  return function()
    require("dap")[method](unpack(args))
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      { "<F5>", dap("continue"), desc = "Debug: start/continue" },
      { "<F10>", dap("step_over"), desc = "Debug: step over" },
      { "<F11>", dap("step_into"), desc = "Debug: step into" },
      { "<S-F11>", dap("step_out"), desc = "Debug: step out" },
      { "<leader>Db", dap("toggle_breakpoint"), desc = "Toggle breakpoint" },
      { "<leader>Dc", dap("continue"), desc = "Start/continue" },
      { "<leader>Dr", dap("repl_toggle"), desc = "Toggle REPL" },
      { "<leader>Dl", dap("run_last"), desc = "Run last" },
      { "<leader>Dt", dap("terminate"), desc = "Terminate" },
      {
        "<leader>Du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle UI",
      },
    },
    config = function()
      local has = function(cmd)
        return vim.fn.executable(cmd) == 1
      end
      -- Only adapters whose language is on this machine.
      local adapters = {}
      if has("python3") then table.insert(adapters, "python") end
      if has("node") then table.insert(adapters, "js") end
      if has("go") then table.insert(adapters, "delve") end
      if has("cargo") or has("gcc") or has("clang") then table.insert(adapters, "codelldb") end
      if has("bash") and has("node") then table.insert(adapters, "bash") end

      require("mason-nvim-dap").setup({
        ensure_installed = adapters,
        automatic_installation = false,
        handlers = {}, -- default setup for every installed adapter
      })

      local d, ui = require("dap"), require("dapui")
      ui.setup()
      require("nvim-dap-virtual-text").setup({})
      d.listeners.after.event_initialized["dapui"] = ui.open
      d.listeners.before.event_terminated["dapui"] = ui.close
      d.listeners.before.event_exited["dapui"] = ui.close
    end,
  },
}
