-- ~/.config/nvim/lua/plugins/harpoon.lua
-- ThePrimeagen/harpoon — pin 4 files, jump with <leader>1..4.
-- Wildly faster than telescope-then-pick for the 3-4 files you touch the most.

return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      local harpoon = require("harpoon")
      return {
        { "<leader>ha", function() harpoon:list():add() end,                      desc = "Harpoon add file" },
        { "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon menu" },
        { "<leader>1",  function() harpoon:list():select(1) end,                  desc = "Harpoon → 1" },
        { "<leader>2",  function() harpoon:list():select(2) end,                  desc = "Harpoon → 2" },
        { "<leader>3",  function() harpoon:list():select(3) end,                  desc = "Harpoon → 3" },
        { "<leader>4",  function() harpoon:list():select(4) end,                  desc = "Harpoon → 4" },
        { "<leader>hp", function() harpoon:list():prev() end,                     desc = "Harpoon prev" },
        { "<leader>hn", function() harpoon:list():next() end,                     desc = "Harpoon next" },
      }
    end,
    opts = {
      settings = {
        save_on_toggle = true,   -- persist list when quick menu closes
        sync_on_ui_close = true, -- write to disk when menu closes
      },
    },
    config = function(_, opts)
      require("harpoon"):setup(opts)
    end,
  },
}
