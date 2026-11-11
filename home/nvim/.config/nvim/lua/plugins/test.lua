-- Tests from inside the editor: neotest. <leader>T prefix.
local function nt(fn)
  return function()
    fn(require("neotest"))
  end
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "fredrikaverpil/neotest-golang",
      "rouge8/neotest-rust",
    },
    keys = {
      { "<leader>Tt", nt(function(n) n.run.run() end), desc = "Run nearest test" },
      { "<leader>Tf", nt(function(n) n.run.run(vim.fn.expand("%")) end), desc = "Run file" },
      { "<leader>Tl", nt(function(n) n.run.run_last() end), desc = "Run last" },
      { "<leader>Ts", nt(function(n) n.summary.toggle() end), desc = "Toggle summary" },
      { "<leader>To", nt(function(n) n.output.open({ enter = true }) end), desc = "Show output" },
      { "<leader>TO", nt(function(n) n.output_panel.toggle() end), desc = "Toggle output panel" },
      { "<leader>Tx", nt(function(n) n.run.stop() end), desc = "Stop" },
    },
    config = function()
      local adapters = {}
      for _, name in ipairs({ "neotest-python", "neotest-jest", "neotest-vitest", "neotest-golang", "neotest-rust" }) do
        local ok, adapter = pcall(require, name)
        if ok then
          table.insert(adapters, adapter)
        end
      end
      require("neotest").setup({ adapters = adapters })
    end,
  },
}
