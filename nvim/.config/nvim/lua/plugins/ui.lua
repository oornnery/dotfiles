-- UI helpers. Statusline is lua/statusline.lua (pure Lua, no lualine).
return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
      { "<leader>bP", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffers left" },
    },
    opts = {
      options = {
        mode = "buffers",
        themable = true,
        numbers = "none",
        close_command = "bdelete %d",
        right_mouse_command = "bdelete %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = { style = "icon", icon = "▎" },
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(_, _, diagnostics)
          local icons = { error = " ", warning = " ", info = " ", hint = " " }
          local result = {}
          for severity, count in pairs(diagnostics) do
            if count > 0 then
              result[#result + 1] = icons[severity] .. count
            end
          end
          return table.concat(result, " ")
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Explorer",
            text_align = "center",
            separator = true,
          },
          {
            filetype = "oil",
            text = "Oil",
            text_align = "center",
            separator = true,
          },
          {
            filetype = "Trouble",
            text = "Trouble",
            text_align = "center",
            separator = true,
          },
        },
        show_buffer_icons = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = "thin",
        always_show_bufferline = false,
        hover = { enabled = true, delay = 150, reveal = { "close" } },
        sort_by = "insert_after_current",
      },
    },
  },

  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = function()
      local bg = "#1e1e2e"
      local ok, theme = pcall(require, "theme")
      if ok and theme.colors and theme.colors.bg then
        bg = theme.colors.bg
      end

      return {
        stages = "fade_in_slide_out",
        timeout = 3000,
        max_width = 80,
        render = "compact",
        background_colour = bg,
      }
    end,
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  {
    "folke/noice.nvim",
    cmd = "Noice",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    keys = {
      {
        "<leader>nn",
        function()
          require("noice").cmd("history")
        end,
        desc = "Noice history",
      },
      {
        "<leader>nl",
        function()
          require("noice").cmd("last")
        end,
        desc = "Last message",
      },
      {
        "<leader>ne",
        function()
          require("noice").cmd("errors")
        end,
        desc = "Noice errors",
      },
      {
        "<leader>nd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Dismiss messages",
      },
      {
        "<leader>np",
        function()
          require("noice").cmd("pick")
        end,
        desc = "Pick messages",
      },
      {
        "<leader>nf",
        function()
          require("noice").cmd("fzf")
        end,
        desc = "Find messages",
      },
      {
        "<leader>nD",
        function()
          require("noice").cmd("disable")
        end,
        desc = "Disable Noice",
      },
      {
        "<leader>nE",
        function()
          require("noice").cmd("enable")
        end,
        desc = "Enable Noice",
      },
      {
        "<S-Enter>",
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end,
        mode = "c",
        desc = "Redirect cmdline",
      },
      {
        "<C-f>",
        function()
          if not require("noice.lsp").scroll(4) then
            return "<C-f>"
          end
        end,
        mode = { "n", "i", "s" },
        expr = true,
        silent = true,
        desc = "Scroll docs forward",
      },
      {
        "<C-b>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<C-b>"
          end
        end,
        mode = { "n", "i", "s" },
        expr = true,
        silent = true,
        desc = "Scroll docs backward",
      },
    },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
      },
      messages = { enabled = true },
      popupmenu = { enabled = true },
      notify = { enabled = true },
      lsp = {
        progress = { enabled = true },
        hover = { enabled = true },
        signature = { enabled = true },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      routes = {
        {
          filter = { event = "msg_show", kind = "search_count" },
          opts = { skip = true },
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      delay = function(ctx)
        return ctx.plugin and 0 or 200
      end,
      icons = { mappings = true },
      plugins = {
        marks = true,
        registers = true,
        spelling = { enabled = true, suggestions = 20 },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      win = {
        no_overlap = true,
        padding = { 1, 2 },
        title = true,
        title_pos = "center",
      },
      layout = { width = { min = 20 }, spacing = 3 },
      show_help = true,
      show_keys = true,
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>a", group = "ai" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code/quickfix" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunk" },
        { "<leader>m", group = "markdown" },
        { "<leader>n", group = "notifications" },
        { "<leader>p", group = "persistence" },
        { "<leader>s", group = "split" },
        { "<leader>t", group = "toggle" },
      })
    end,
  },
}
