return {
  { "sitiom/nvim-numbertoggle" },
  { "mluders/comfy-line-numbers.nvim" },
  { "folke/twilight.nvim" },
  {
    "code-biscuits/nvim-biscuits",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  { "axieax/urlview.nvim" },
  { "jbyuki/venn.nvim" },
  {
    "nguyenvukhang/nvim-toggler",
    keys = {
      {
        "<leader>tg",
        function()
          require("nvim-toggler").toggle()
        end,
        mode = { "n", "v" },
        desc = "Toggle values",
      },
    },
  },
  { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" },
  {
    "sphamba/smear-cursor.nvim",
    opts = { -- Default  Range
      stiffness = 0.8, -- 0.6      [0, 1]
      trailing_stiffness = 0.6, -- 0.45     [0, 1]
      stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
      trailing_stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
      damping = 0.95, -- 0.85     [0, 1]
      damping_insert_mode = 0.95, -- 0.9      [0, 1]
      distance_stop_animating = 0.5, -- 0.1      > 0
    },
  },
}
