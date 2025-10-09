return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' }, -- if you use standalone mini plugins
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {},
  config = function()
    require("render-markdown").setup()
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost" }, {
      pattern = { "*.md", "copilot-*" },
      callback = function(args)
        vim.bo[args.buf].filetype = "markdown"
        require("render-markdown").buf_enable(args.buf)
      end,
    })
  end,
}
